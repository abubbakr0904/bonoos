import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/alarm/alarm_models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmService {
  AlarmService._();

  static const _storageKey = 'alarm_items_v1';

  static Future<List<AlarmItem>> loadAlarms() async {
    final prefs = inject<SharedPreferences>();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) return const [];
    final items = parsed
        .whereType<Map<String, dynamic>>()
        .map(AlarmItem.fromJson)
        .toList();
    items.sort((a, b) => '${a.hour}:${a.minute}'.compareTo('${b.hour}:${b.minute}'));
    return items;
  }

  static Future<AlarmItem> createAlarm(AlarmDraft draft) async {
    await _requestPermissionsIfNeeded();
    final alarms = await loadAlarms();
    final id = _generateId(alarms);
    final item = AlarmItem.fromHourMinute(
      id: id,
      hour: draft.hour,
      minute: draft.minute,
      enabled: true,
      voiceAssetPath: draft.voiceAssetPath,
      voiceLabel: draft.voiceLabel,
    );
    await _setAlarm(item);
    final updated = [...alarms, item];
    await _save(updated);
    return item;
  }

  static Future<void> toggleAlarm(AlarmItem item, bool enabled) async {
    final alarms = await loadAlarms();
    final index = alarms.indexWhere((e) => e.id == item.id);
    if (index < 0) return;
    final next = item.copyWith(enabled: enabled);
    alarms[index] = next;
    if (enabled) {
      await _setAlarm(next);
    } else {
      await Alarm.stop(next.id);
    }
    await _save(alarms);
  }

  static Future<void> deleteAlarm(int id) async {
    final alarms = await loadAlarms();
    final updated = alarms.where((e) => e.id != id).toList();
    await Alarm.stop(id);
    await _save(updated);
  }

  /// Keyingi jiringlash vaqti (bugun yoki ertaga shu soat-daqiqada).
  static DateTime nextRingDateTime(AlarmItem item) {
    final now = DateTime.now();
    var dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      item.hour,
      item.minute,
    );
    if (!dateTime.isAfter(now)) {
      dateTime = dateTime.add(const Duration(days: 1));
    }
    return dateTime;
  }

  static Future<AlarmItem> updateAlarm(AlarmItem existing, AlarmDraft draft) async {
    await _requestPermissionsIfNeeded();
    final alarms = await loadAlarms();
    final index = alarms.indexWhere((e) => e.id == existing.id);
    if (index < 0) return existing;

    final updated = AlarmItem.fromHourMinute(
      id: existing.id,
      hour: draft.hour,
      minute: draft.minute,
      enabled: existing.enabled,
      voiceAssetPath: draft.voiceAssetPath,
      voiceLabel: draft.voiceLabel,
    );
    alarms[index] = updated;
    if (updated.enabled) {
      await _setAlarm(updated);
    } else {
      await Alarm.stop(updated.id);
    }
    await _save(alarms);
    return updated;
  }

  static Future<void> syncAlarmsWithEngine() async {
    await _requestPermissionsIfNeeded();
    final alarms = await loadAlarms();
    for (final alarm in alarms) {
      if (alarm.enabled) {
        await _setAlarm(alarm);
      } else {
        await Alarm.stop(alarm.id);
      }
    }
  }

  static Future<void> _save(List<AlarmItem> alarms) async {
    final prefs = inject<SharedPreferences>();
    final json = jsonEncode(alarms.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  static Future<void> _setAlarm(AlarmItem item) async {
    final alarmSettings = AlarmSettings(
      id: item.id,
      dateTime: _nextDateTime(item.hour, item.minute),
      assetAudioPath: item.voiceAssetPath,
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: false,
      volumeSettings: VolumeSettings.fade(
        fadeDuration: Duration(seconds: 5),
        volume: 0.9,
        volumeEnforced: true,
      ),
      notificationSettings: const NotificationSettings(
        title: 'Bonoos budilnik',
        body: 'Uyg\'onish vaqti bo\'ldi',
        stopButton: 'To\'xtatish',
      ),
      payload: jsonEncode({'voiceLabel': item.voiceLabel}),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  static DateTime _nextDateTime(int hour, int minute) {
    final now = DateTime.now();
    var dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!dateTime.isAfter(now)) {
      dateTime = dateTime.add(const Duration(days: 1));
    }
    return dateTime;
  }

  static int _generateId(List<AlarmItem> current) {
    final used = current.map((e) => e.id).toSet();
    var candidate = DateTime.now().millisecondsSinceEpoch % 2000000000;
    if (candidate <= 1) candidate = 2;
    while (used.contains(candidate) || candidate == -1 || candidate == 0) {
      candidate += 1;
    }
    return candidate;
  }

  static Future<void> _requestPermissionsIfNeeded() async {
    if (!Platform.isAndroid) return;
    final notificationStatus = await Permission.notification.status;
    if (notificationStatus.isDenied) {
      await Permission.notification.request();
    }
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
    if (exactAlarmStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }
}
