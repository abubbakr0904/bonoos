import 'dart:developer';
import 'package:bonoos/core/api/list_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefManager {
  final _kToken = SharedModel.accessToken;

  final _kRefresh = SharedModel.refreshToken;
  final _kBase = SharedModel.base;
  final _kUserId = 'userId';
  final _kBranchId = 'branch_id';

  SharedPreferences preferences;

  PrefManager(this.preferences);

  set token(String? value) => preferences.setString(_kToken, value ?? "");

  set baseUrl(String? value) {
    log('set BaseUrl $value');
    preferences.setString(_kBase, value ?? "");
  }

  set refresh(String? value) => preferences.setString(_kRefresh, value ?? "");

  set id(int? value) => preferences.setInt(_kUserId, value ?? 0);

  String? get token => preferences.getString(_kToken);

  String? get baseUrl {
    final val = preferences.getString(_kBase);
    log('got BaseUrl:$val');
    return val;
  }

  String? get refresh => preferences.getString(_kRefresh);

  int? get id => preferences.getInt(_kUserId);

  int? get branch => preferences.getInt(_kBranchId);

  set branch(int? value) {
    if (value == null) {
      return;
    }
    preferences.setInt(_kBranchId, value);
  }

  int get authExpiresIn => preferences.getInt(SharedModel.authExpiresIn) ?? 0;

  String? get authSessionJson =>
      preferences.getString(SharedModel.authSessionJson);

  /// Verify-otp javobidagi maydonlar va `data` JSON (keyinchalik ishlatish uchun).
  Future<void> persistAuthSession({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required int userId,
    required bool isNewUser,
    String? phoneDigits,
    required String rawDataJson,
  }) async {
    final pendingQuestions = preferences.getBool(SharedModel.newUser) ?? false;
    await preferences.setString(_kToken, accessToken);
    await preferences.setString(_kRefresh, refreshToken);
    await preferences.setInt(_kUserId, userId);
    await preferences.setInt(SharedModel.authExpiresIn, expiresIn);
    await preferences.setBool(
        SharedModel.newUser, pendingQuestions || isNewUser);
    await preferences.setString(SharedModel.authSessionJson, rawDataJson);
    // Telegram login da raqam ilovaga kelmaydi.
    if (phoneDigits != null) {
      await preferences.setString(SharedModel.useName, phoneDigits);
    }
  }

  Future<bool> logout() async => await preferences.clear();
}
