import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/playlist/domain/entity/audition.dart';
import 'package:bonoos/features/playlist/domain/entity/auditions_page.dart';
import 'package:bonoos/features/playlist/domain/entity/category.dart';
import 'package:bonoos/features/playlist/domain/repository/playlist_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<Category>>> fetchCategories() async {
    try {
      final raw = await _dio.get(ListAPI.categories);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(
            BadResponseFailure(message: 'Kategoriyalar ma\'lumoti yo\'q.'));
      }
      final categories = list
          .whereType<Map>()
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(categories);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Audition>>> fetchAuditions(int categoryId) async {
    try {
      final raw = await _dio.get(
        ListAPI.auditions,
        queryParameters: {'category_id': categoryId},
      );
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final auditions = _parseAuditionsList(map['data']);
      if (auditions == null) {
        return const Left(
            BadResponseFailure(message: 'Auditionlar ma\'lumoti yo\'q.'));
      }
      return Right(auditions);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuditionsPage>> fetchAuditionsPage({
    required int limit,
    required int offset,
  }) async {
    try {
      final raw = await _dio.get(
        ListAPI.auditions,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final page = _parseAuditionsPage(map['data']);
      if (page == null) {
        return const Left(
            BadResponseFailure(message: 'Auditionlar ma\'lumoti yo\'q.'));
      }
      return Right(page);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleAuditionFavorite(int auditionId) async {
    try {
      await _dio.post(
        ListAPI.clientAuditionFavorite(auditionId),
        data: <String, dynamic>{},
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Audition>>> fetchFavoriteAuditions() async {
    try {
      final raw = await _dio.get(ListAPI.clientFavoriteAuditions);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final auditions = _parseAuditionsList(map['data']);
      if (auditions == null) {
        return const Left(
            BadResponseFailure(message: 'Sevimlilar ma\'lumoti yo\'q.'));
      }
      return Right(auditions);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<void> reportAuditionListen({
    required int auditionId,
    required int durationSeconds,
    required int auditionType,
  }) async {
    try {
      final now = DateTime.now();
      final day = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}T00:00:00Z';
      await _dio.post(
        ListAPI.clientAuditionListen(auditionId),
        data: <String, dynamic>{
          'duration': durationSeconds,
          'audition_type': auditionType,
          'day': day,
        },
      );
    } catch (_) {
      // Fire-and-forget: foydalanuvchi load yoki xato xabarini ko‘rmaydi.
    }
  }

  /// `data` — to‘g‘ridan-to‘g‘ri ro‘yxat yoki `{ items, limit, offset, total }`.
  /// Bo‘sh / `items: null` → bo‘sh ro‘yxat.
  @override
  Future<Either<Failure, CategoryPurchase>> purchaseCategory(int categoryId, int priceId) async {
    try {
      final response = await _dio.post(
        ListAPI.clientCategoryPurchase(categoryId),
        data: <String, dynamic>{'price_id': priceId},
      );
      final data = (response.data as Map?)?['data'];
      final link = data is Map ? data['payment_link'] as String? : null;
      final paymentId = data is Map ? (data['payment_id'] as num?)?.toInt() : null;
      if (link == null || link.isEmpty || paymentId == null) {
        return const Left(BadResponseFailure(message: 'To\'lov havolasi olinmadi.'));
      }
      return Right(CategoryPurchase(paymentId: paymentId, paymentLink: link));
    } on DioException catch (e) {
      // 409 — tarif sotuvdan olingan, 404 — tarif topilmadi: ro‘yxatni yangilash kerak.
      final code = e.response?.statusCode;
      if (code == 409 || code == 404) {
        return const Left(ServerFailure(
            message: 'Bu tarif hozir mavjud emas. Ro\'yxatni yangilab, boshqa tarifni tanlang.'));
      }
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentStatus>> fetchPaymentStatus(int paymentId) async {
    try {
      final raw = await _dio.get(ListAPI.clientPayment(paymentId));
      final data = ((raw as Response<dynamic>).data as Map?)?['data'];
      final status = data is Map ? data['status'] as String? : null;
      if (status == null) {
        return const Left(BadResponseFailure(message: 'To\'lov holati olinmadi.'));
      }
      final expires = data is Map ? data['access_expires_at'] as String? : null;
      return Right(PaymentStatus(
        status: status,
        accessExpiresAt: expires == null ? null : DateTime.tryParse(expires),
      ));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  List<Audition>? _parseAuditionsList(dynamic dataRaw) {
    if (dataRaw is List) {
      return dataRaw
          .whereType<Map>()
          .map((e) => Audition.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (dataRaw is Map) {
      final m = Map<String, dynamic>.from(dataRaw);
      final items = m['items'];
      if (items == null) {
        return [];
      }
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => Audition.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return null;
    }
    if (dataRaw == null) {
      return [];
    }
    return null;
  }

  AuditionsPage? _parseAuditionsPage(dynamic dataRaw) {
    if (dataRaw is Map) {
      final m = Map<String, dynamic>.from(dataRaw);
      final list = _parseAuditionsList(dataRaw);
      if (list == null) return null;
      final limit = (m['limit'] as num?)?.toInt() ?? 0;
      final offset = (m['offset'] as num?)?.toInt() ?? 0;
      final total = (m['total'] as num?)?.toInt() ?? 0;
      return AuditionsPage(
        items: list,
        limit: limit,
        offset: offset,
        total: total,
      );
    }
    if (dataRaw is List) {
      final list = _parseAuditionsList(dataRaw);
      if (list == null) return null;
      return AuditionsPage(
        items: list,
        limit: list.length,
        offset: 0,
        total: list.length,
      );
    }
    if (dataRaw == null) {
      return const AuditionsPage(items: [], limit: 0, offset: 0, total: 0);
    }
    return null;
  }

  Failure _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
        message: 'Internet aloqasi yo\'q yoki vaqt tugadi.',
      );
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = m['message']?.toString() ?? m['error']?.toString() ?? m['detail']?.toString();
    }
    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Kirish talab qilinadi.');
    }
    return ServerFailure(message: msg ?? 'So\'rov bajarilmadi.');
  }
}
