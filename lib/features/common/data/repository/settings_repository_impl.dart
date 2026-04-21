import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/common/domain/repository/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SharedPreferences _preferences = inject<SharedPreferences>();

  @override
  Future<Either<Failure, String>> getAppLang() async {
    String lang = _preferences.getString(SharedModel.lang) ?? 'uz';
    return Right(lang);
  }

  @override
  Future<Either<Failure, String>> setAppLang(String lang) async {
    await _preferences.setString(SharedModel.lang, lang);
    return Right(lang);
  }

  @override
  Future<Either<Failure, bool>> getAppOnBoard() async {
    bool lang = _preferences.getBool(SharedModel.onBoard) ?? false;
    return Right(lang);
  }

  @override
  Future<Either<Failure, bool>> saveAppOnBoard(bool onBoard) async {
    await _preferences.setBool(SharedModel.onBoard, onBoard);
    return Right(onBoard);
  }
}
