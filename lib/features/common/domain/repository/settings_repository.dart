import 'package:bonoos/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class SettingsRepository {
  Future<Either<Failure, String>> getAppLang();

  Future<Either<Failure, bool>> getAppOnBoard();
  Future<Either<Failure, bool>> saveAppOnBoard(bool onBoard);

  Future<Either<Failure, String>> setAppLang(String lang);
}
