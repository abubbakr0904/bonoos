import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/entity/auditions_page.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:dartz/dartz.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, List<Category>>> fetchCategories();
  Future<Either<Failure, List<Audition>>> fetchAuditions(int categoryId);

  /// GET `/auditions?limit=&offset=` (home ro‘yxati, pagination).
  Future<Either<Failure, AuditionsPage>> fetchAuditionsPage({
    required int limit,
    required int offset,
  });

  /// POST `/client/auditions/{id}/favorite` — server holatini almashtiradi.
  Future<Either<Failure, Unit>> toggleAuditionFavorite(int auditionId);

  /// GET `/client/favorites/auditions` — foydalanuvchi sevimli audiolari.
  Future<Either<Failure, List<Audition>>> fetchFavoriteAuditions();

  /// Audioni ~70% tinglanganda chaqiriladi; muvaffaqiyat/xatolik UI ga chiqarilmaydi.
  Future<void> reportAuditionListen({
    required int auditionId,
    required int durationSeconds,
    required int auditionType,
  });
}
