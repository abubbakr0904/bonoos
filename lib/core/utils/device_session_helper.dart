import 'dart:io';
import 'dart:math';

import 'package:bonoos/core/api/list_api.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `/auth/client/session` uchun body: `device_id`, `device_name`, `session_type`, `fcm_token`.
class DeviceSessionHelper {
  DeviceSessionHelper._();

  static const int _sessionType = 2;
  static const String _placeholderFcm = 'fcm-pending';

  /// `.env` da `FCM_TOKEN` bo‘lsa ishlatiladi, aks holda placeholder.
  static Future<Map<String, dynamic>> buildSessionPayload(SharedPreferences prefs) async {
    final fcm = _resolveFcmToken(prefs);
    final deviceId = await _deviceId(prefs);
    final deviceName = await _deviceName();

    return <String, dynamic>{
      'device_id': deviceId,
      'device_name': deviceName,
      'session_type': _sessionType,
      'fcm_token': fcm,
    };
  }

  static String _resolveFcmToken(SharedPreferences prefs) {
    final cached = prefs.getString('fcm_token');
    if (cached != null && cached.isNotEmpty) return cached;
    final fromEnv = dotenv.env['FCM_TOKEN']?.trim();
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return _placeholderFcm;
  }

  static Future<String> _deviceId(SharedPreferences prefs) async {
    final existing = prefs.getString(SharedModel.deviceClientId);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = 'bonoos-${DateTime.now().millisecondsSinceEpoch}-${Random.secure().nextInt(1 << 30)}';
    await prefs.setString(SharedModel.deviceClientId, id);
    return id;
  }

  static Future<String> _deviceName() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final a = await plugin.androidInfo;
        final name = '${a.brand} ${a.model}'.trim();
        return name.isEmpty ? 'Android' : name;
      }
      if (Platform.isIOS) {
        final i = await plugin.iosInfo;
        if (i.name.isNotEmpty) return i.name;
        return i.model;
      }
    } catch (_) {
      // ignore
    }
    return 'Unknown device';
  }
}
