import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/entity/auditions_page.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:dartz/dartz.dart';

class CategoryPurchase {
  const CategoryPurchase({required this.paymentId, required this.paymentLink});

  final int paymentId;
  final String paymentLink;
}

/// GET `/client/payments/{id}` natijasi.
class PaymentStatus {
  const PaymentStatus({required this.status, this.accessExpiresAt});

  /// `pending | completed | failed | cancelled`
  final String status;

  /// To‘lov bajarilgach shu to‘lov bergan davr tugash sanasi (`null` — umrbod yoki hali yo‘q).
  final DateTime? accessExpiresAt;
}

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

  /// POST `/client/categories/{id}/purchase` `{price_id}` — tanlangan tarif uchun Payme havolasi.
  /// Ochiq to‘plamni ham sotib olish mumkin: muddat joriy muddat oxiridan uzayadi.
  Future<Either<Failure, CategoryPurchase>> purchaseCategory(int categoryId, int priceId);

  /// GET `/client/payments/{id}`.
  Future<Either<Failure, PaymentStatus>> fetchPaymentStatus(int paymentId);

  /// Audioni ~70% tinglanganda chaqiriladi; muvaffaqiyat/xatolik UI ga chiqarilmaydi.
  Future<void> reportAuditionListen({
    required int auditionId,
    required int durationSeconds,
    required int auditionType,
  });
}
