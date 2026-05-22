import 'dart:convert';
import 'dart:io';

import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/routes/app_pages.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/auth/domain/repository/auth_repository.dart';
import 'package:bonoos/features/notification/notifications_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Globally defined plugin so background and foreground isolates can both use it
final FlutterLocalNotificationsPlugin _globalLocalNotifications =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  final messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      // 1. Request permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint("Notification permission granted: ${settings.authorizationStatus}");

        // 2. Set foreground presentation options for iOS to show banners automatically
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 3. Initialize local notifications for foreground displaying
        await _initLocalNotifications();

        // 4. Fetch token, save it to SharedPreferences, and sync with backend
        await _getAndSyncToken();

        // 5. Initialize FCM push message listeners (foreground, background, terminated states)
        await _initPushCallbacks();

        // 6. Listen to token refresh events
        _listenToTokenRefresh();
      } else {
        debugPrint("Notification permission denied.");
      }
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  }

  Future<void> _getAndSyncToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        debugPrint("\n[FCM TOKEN] -----------------------------------------");
        debugPrint("FCM TOKEN: $token");
        debugPrint("-----------------------------------------------------\n");

        final prefs = inject<SharedPreferences>();
        await prefs.setString('fcm_token', token);

        // Sync session token with the backend
        await _syncTokenWithBackend();
      }
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
    }
  }

  Future<void> _syncTokenWithBackend() async {
    try {
      await inject<AuthRepository>().registerClientSession();
      debugPrint("FCM token successfully registered in backend session");
    } catch (e) {
      debugPrint("Error syncing FCM token with backend session: $e");
    }
  }

  void _listenToTokenRefresh() {
    messaging.onTokenRefresh.listen((String token) async {
      debugPrint("FCM TOKEN (Refreshed): $token");
      final prefs = inject<SharedPreferences>();
      await prefs.setString('fcm_token', token);
      await _syncTokenWithBackend();
    });
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _globalLocalNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _createAndroidNotificationChannel();
    }
  }

  Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bonoos_high_importance_channel',
      'Bonoos Notifications',
      description: 'This channel is used for Bonoos push notifications.',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin =
        _globalLocalNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> _initPushCallbacks() async {
    // 1. App is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM Foreground Message received: ${message.messageId}");
      _showGlobalNotification(message);
    });

    // 2. App in background and opened via notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("FCM Message opened app from background: ${message.messageId}");
      _handleMessageTap(message);
    });

    // 3. App terminated and launched via notification click
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("FCM Message launched app from terminated: ${initialMessage.messageId}");
      Future.delayed(const Duration(milliseconds: 1000), () {
        _handleMessageTap(initialMessage);
      });
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint("Local Notification tapped with payload: ${response.payload}");
    _navigateToNotifications();
  }

  void _handleMessageTap(RemoteMessage message) {
    debugPrint("FCM Notification tapped: ${message.data}");
    _navigateToNotifications();
  }

  void _navigateToNotifications() {
    try {
      final context = rootNavigatorKey.currentState?.context;
      if (context != null) {
        context.push(NotificationsScreen.routeName);
      } else {
        debugPrint("Error: Could not navigate, rootNavigatorKey context is null.");
      }
    } catch (e) {
      debugPrint("Navigation error: $e");
    }
  }
}

// Global function to show notification on screen (handles title/body parsing fallbacks)
Future<void> _showGlobalNotification(RemoteMessage message) async {
  // Extract title and body with multiple fallbacks for data-only payloads
  final String title = message.notification?.title ?? 
                       message.data['title'] ?? 
                       message.data['message_title'] ?? 
                       message.data['subject'] ?? 
                       'Bonoos';
  final String body = message.notification?.body ?? 
                      message.data['body'] ?? 
                      message.data['message'] ?? 
                      message.data['text'] ?? 
                      message.data['content'] ?? 
                      '';

  // If no content, don't show an empty notification
  if (message.notification == null && message.data.isEmpty) {
    return;
  }

  const androidDetails = AndroidNotificationDetails(
    'bonoos_high_importance_channel',
    'Bonoos Notifications',
    channelDescription: 'This channel is used for Bonoos push notifications.',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  final payload = jsonEncode(message.data);

  await _globalLocalNotifications.show(
    message.hashCode,
    title,
    body,
    details,
    payload: payload,
  );
}

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("FCM Background Message received: ${message.messageId}");
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized
  }

  // Initialize local notifications for background isolate if not already initialized
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _globalLocalNotifications.initialize(
    initSettings,
  );

  // Display notification ONLY if it does not contain a standard notification payload.
  // If message.notification != null, the OS system tray handles it automatically
  // when the app is in the background or terminated to avoid duplicates.
  if (message.notification == null) {
    await _showGlobalNotification(message);
  }
}
