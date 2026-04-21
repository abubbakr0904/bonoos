// import 'dart:convert';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:locationtracking_app/core/routes/admin_app_pages.dart';
// import 'package:locationtracking_app/core/values/theme/theme_controller.dart';
// import 'package:locationtracking_app/export.dart';
// import 'package:locationtracking_app/features/common/domain/repository/NotificationRepository.dart';
//
// class NotificationService {
//   final messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//   final NotificationRepository _notificationRepository;
//
//   NotificationService(this._notificationRepository);
//
//   Future<void> init() async {
//     // Request permissions
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print("Notification permission granted");
//
//       // Get tokens based on platform and send to API
//       await _getTokensAndSendToAPI();
//
//       // Initialize local notifications for foreground handling
//       await _initLocalNotifications();
//
//       // Initialize push notifications
//       await initPushNotification();
//
//       // Listen to token refresh
//       listenToTokenRefresh();
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print("Provisional notification permission granted");
//       await _getTokensAndSendToAPI();
//       await _initLocalNotifications();
//       await initPushNotification();
//       listenToTokenRefresh();
//     } else {
//       print("Permission denied for notifications.");
//     }
//   }
//
//   Future<void> _getTokensAndSendToAPI() async {
//     try {
//       String? fcmToken = await messaging.getToken();
//       if (fcmToken != null) {
//         print("FCM Token: $fcmToken");
//
//         // Determine device type
//         String deviceType = Platform.isAndroid ? 'android' : 'ios';
//
//         // Send token to API
//         await _sendTokenToAPI(fcmToken, deviceType);
//       }
//     } catch (e) {
//       print("Error getting tokens: $e");
//     }
//   }
//
//   Future<void> _sendTokenToAPI(String token, String deviceType) async {
//     try {
//       final result = await _notificationRepository.registerDevicePushToken(
//         fcmToken: token,
//       );
//
//       result.fold(
//             (failure) => print("Failed to send token to API: $failure"),
//             (success) => print("Token sent to API successfully"),
//       );
//     } catch (e) {
//       print("Error sending token to API: $e");
//     }
//   }
//
//   Future<void> _initLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await _localNotifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTap,
//     );
//
//     // Create notification channels for Android with sound
//     if (Platform.isAndroid) {
//       await _createNotificationChannels();
//     }
//   }
//
//   Future<void> _createNotificationChannels() async {
//     // High importance channel with default sound
//     const AndroidNotificationChannel highImportanceChannel =
//     AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//       enableVibration: true,
//       playSound: true,
//     );
//
//     final androidPlugin =
//     _localNotifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//
//     await androidPlugin?.createNotificationChannel(highImportanceChannel);
//   }
//
//   void _onNotificationTap(NotificationResponse notificationResponse) {
//     // Handle local notification tap only
//     final String? payload = notificationResponse.payload;
//     if (payload != null) {
//       // Parse payload and navigate accordingly
//       _handleNavigationFromPayload(payload);
//     } else {
//       // Default navigation
//       adminRootNavigatorKey.currentState?.context.go(AppRoutes.login);
//     }
//   }
//
//   void _handleNavigationFromPayload(String payload) {
//     // Parse your payload and navigate to appropriate screen
//     try {
//       // Parse the payload JSON
//       final Map<String, dynamic> payloadData = json.decode(payload);
//
//       // Navigate to task details
//       final TaskResponseModel task = TaskResponseModel(
//         itemId: int.parse(payloadData['id'].toString()),
//         title: payloadData['title'] ?? '',
//       );
//
//       adminRootNavigatorKey.currentState?.context.pushNamed(
//         AppRoutes.employeeTasksDetailScreen,
//         extra: {
//           "model": task,
//         },
//       );
//     } catch (e) {
//       print("Error parsing payload: $e");
//       // Fallback to login screen
//       adminRootNavigatorKey.currentState?.context.go(AppRoutes.login);
//     }
//   }
//
//   void handleMessage(RemoteMessage? message) {
//     if (message == null) return;
//
//     print("Handling message: ${message.messageId}");
//     print("Message data: ${message.data}");
//
//     // Only handle navigation for background/terminated app states
//     // Don't handle navigation for foreground notifications as they're handled by local notifications
//     try {
//       if (message.data.containsKey('id') && message.data.containsKey('title')) {
//         // Extract navigation data from message
//         final TaskResponseModel task = TaskResponseModel(
//           itemId: int.parse(message.data['id'].toString()),
//           title: message.data['title'] ?? '',
//         );
//
//         String route =
//             message.data['route'] ?? AppRoutes.employeeTasksDetailScreen;
//
//         adminRootNavigatorKey.currentState?.context.pushNamed(
//           route,
//           extra: {
//             "model": task,
//           },
//         );
//       } else {
//         // Fallback navigation
//         adminRootNavigatorKey.currentState?.context.go(AppRoutes.login);
//       }
//     } catch (e) {
//       print("Error handling message navigation: $e");
//       adminRootNavigatorKey.currentState?.context.go(AppRoutes.login);
//     }
//   }
//
//   Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//     required String payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.high,
//       priority: Priority.high,
//       enableVibration: true,
//       playSound: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       title,
//       body,
//       details,
//       payload: payload,
//     );
//   }
//
//   Future<void> _showForegroundNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//
//     if (notification == null) return;
//
//     // Create payload that matches the expected structure for _onNotificationTap
//     final payload = json.encode({
//       'type': 'task',
//       'id': message.data['id'] ?? '0',
//       'title':
//       message.data['title'] ?? notification.title ?? 'New Notification',
//       'route': message.data['route'] ?? AppRoutes.employeeTasksDetailScreen,
//       ...message.data,
//     });
//
//     await _showLocalNotification(
//       title: notification.title ?? 'New Notification',
//       body: notification.body ?? 'You have a new notification',
//       payload: payload,
//     );
//   }
//
//   Future<void> initPushNotification() async {
//     // Handle notification when app is terminated and opened via notification
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//
//     // Handle notification when app is in background and opened via notification
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//
//     // Handle notification when app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Received foreground message: $message");
//       print("Received foreground message: ${message.data}");
//       print("Received foreground message: ${message.notification?.title}");
//       print("Received foreground message: ${message.notification?.body}");
//
//       // Only show local notification, don't handle navigation here
//       // Navigation will be handled by _onNotificationTap when user taps the local notification
//       _showForegroundNotification(message);
//     });
//
//     // Handle background messages (when app is in background but not terminated)
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }
//
//   // Token refresh handling
//   void listenToTokenRefresh() {
//     messaging.onTokenRefresh.listen((String token) async {
//       print("Token refreshed: $token");
//
//       // Send updated token to API
//       String deviceType = Platform.isAndroid ? 'android' : 'ios';
//       await _sendTokenToAPI(token, deviceType);
//     });
//   }
// }
//
// // Top-level function for background message handling
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling background message: ${message.messageId}");
//
//   // Handle background message processing here
//   // Don't handle navigation in background handler
// }
