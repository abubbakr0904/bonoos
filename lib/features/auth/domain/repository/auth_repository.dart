import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/auth/domain/entity/verify_otp_result.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  /// [phoneDigits] — 9 ta raqam (masalan `930374441`), `+998` qo'shilmaydi.
  Future<Either<Failure, Unit>> sendOtp({required String phoneDigits});

  /// [phoneDigits] — 9 raqam; [code] — 4 raqamli OTP.
  Future<Either<Failure, VerifyOtpResult>> verifyOtp({
    required String phoneDigits,
    required String code,
  });

  /// [code] — Telegram botdan olingan 6 raqamli bir martalik kod.
  Future<Either<Failure, VerifyOtpResult>> telegramVerify({required String code});

  /// OTP dan keyin sessiya ro'yxatdan o'tkazish (Bearer kerak — verify dan keyin).
  Future<Either<Failure, Unit>> registerClientSession();

  /// Hisobdan chiqish. Serverga logout + local ma'lumotlarni tozalash.
  Future<Either<Failure, Unit>> logout();
}
