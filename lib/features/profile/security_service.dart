import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  SecurityService._();

  static bool isSplashActive = true;

  static const _storage = FlutterSecureStorage();
  static final _auth = LocalAuthentication();

  static const _pinKey = 'app_pin_code';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _pinEnabledKey = 'pin_enabled';

  static Future<bool> isPinSet() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await setPinEnabled(true);
  }

  static Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin == pin;
  }

  static Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
    await setPinEnabled(false);
  }

  static Future<bool> isPinEnabled() async {
    final val = await _storage.read(key: _pinEnabledKey);
    return val == 'true';
  }

  static Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(key: _pinEnabledKey, value: enabled.toString());
  }

  static Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  static Future<bool> authenticateBiometrically() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Ilovaga kirish uchun shaxsingizni tasdiqlang',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
