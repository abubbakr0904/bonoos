import 'dart:convert';
import 'dart:io';

import 'package:bonoos/di.dart';
import 'package:bonoos/features/medicine/medicine_models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class MedicineService {
  MedicineService._();

  static const _storageKey = 'medicine_reminders_v1';
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);
  }

  static Future<List<MedicineItem>> loadMedicines() async {
    final prefs = inject<SharedPreferences>();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) return const [];
    final items = parsed
        .whereType<Map<String, dynamic>>()
        .map(MedicineItem.fromJson)
        .toList();
    items.sort((a, b) => '${a.hour}:${a.minute}'.compareTo('${b.hour}:${b.minute}'));
    return items;
  }

  static Future<MedicineItem> createMedicine(MedicineDraft draft) async {
    await _requestPermissionsIfNeeded();
    final medicines = await loadMedicines();
    final id = _generateId(medicines);
    final item = MedicineItem(
      id: id,
      name: draft.name,
      hour: draft.hour,
      minute: draft.minute,
      enabled: true,
    );
    await _scheduleNotification(item);
    final updated = [...medicines, item];
    await _save(updated);
    return item;
  }

  static Future<MedicineItem> updateMedicine(MedicineItem existing, MedicineDraft draft) async {
    await _requestPermissionsIfNeeded();
    final medicines = await loadMedicines();
    final index = medicines.indexWhere((e) => e.id == existing.id);
    if (index < 0) return existing;

    final updated = existing.copyWith(
      name: draft.name,
      hour: draft.hour,
      minute: draft.minute,
    );
    medicines[index] = updated;
    if (updated.enabled) {
      await _scheduleNotification(updated);
    } else {
      await _notifications.cancel(updated.id);
    }
    await _save(medicines);
    return updated;
  }

  static Future<void> toggleMedicine(MedicineItem item, bool enabled) async {
    final medicines = await loadMedicines();
    final index = medicines.indexWhere((e) => e.id == item.id);
    if (index < 0) return;
    final next = item.copyWith(enabled: enabled);
    medicines[index] = next;
    if (enabled) {
      await _scheduleNotification(next);
    } else {
      await _notifications.cancel(next.id);
    }
    await _save(medicines);
  }

  static Future<void> deleteMedicine(int id) async {
    final medicines = await loadMedicines();
    final updated = medicines.where((e) => e.id != id).toList();
    await _notifications.cancel(id);
    await _save(updated);
  }

  static Future<void> syncMedicinesWithEngine() async {
    final medicines = await loadMedicines();
    for (final medicine in medicines) {
      if (medicine.enabled) {
        await _scheduleNotification(medicine);
      } else {
        await _notifications.cancel(medicine.id);
      }
    }
  }

  static Future<void> _save(List<MedicineItem> medicines) async {
    final prefs = inject<SharedPreferences>();
    final json = jsonEncode(medicines.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }

  static Future<void> _scheduleNotification(MedicineItem item) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, item.hour, item.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      item.id,
      'Dori ichish vaqti',
      '${item.name} dorisini ichish vaqti bo\'ldi',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Dori eslatmalari',
          channelDescription: 'Dorilarni ichish vaqti haqida bildirishnomalar',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily at the same time
    );
  }

  static int _generateId(List<MedicineItem> current) {
    final used = current.map((e) => e.id).toSet();
    var candidate = 1000 + (DateTime.now().millisecondsSinceEpoch % 10000);
    while (used.contains(candidate)) {
      candidate += 1;
    }
    return candidate;
  }

  static Future<void> _requestPermissionsIfNeeded() async {
    if (!Platform.isAndroid) return;
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }
}
