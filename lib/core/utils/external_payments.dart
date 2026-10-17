import 'package:bonoos/di.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Store / Play review uchun berilgan test foydalanuvchi (`profile/me` → `is_test_user`).
/// Unga ilovada hech qanday to‘lov, narx, tarif yoki yopiq (pullik) kontent ko‘rsatilmaydi.
///
/// Qiymat SharedPreferences da saqlanadi — ilova qayta ochilganda profil yuklanguncha ham
/// to‘lovlar ko‘rinib qolmasin. `logout` da `preferences.clear()` bilan o‘chadi.
class PaymentVisibility {
  PaymentVisibility._();

  static const _kIsTestUser = 'is_test_user';

  static ValueNotifier<bool>? _isTestUser;

  /// `true` — test (review) foydalanuvchi; o‘zgarsa tab bar va boshqa joylar qayta chiziladi.
  static ValueNotifier<bool> get isTestUser =>
      _isTestUser ??= ValueNotifier<bool>(
        inject<SharedPreferences>().getBool(_kIsTestUser) ?? false,
      );

  /// Profil javobidan keladi (`fetchMe`, `updateProfile`).
  static Future<void> setTestUser(bool value) async {
    isTestUser.value = value;
    await inject<SharedPreferences>().setBool(_kIsTestUser, value);
  }

  /// Hisobdan chiqishda (prefs allaqachon tozalangan bo‘ladi).
  static void reset() => isTestUser.value = false;
}

/// Tashqi to‘lov (Payme), narxlar, «To‘plamlar» tabi va yopiq audiolar yashirilsinmi.
bool hideExternalPayments() => PaymentVisibility.isTestUser.value;
