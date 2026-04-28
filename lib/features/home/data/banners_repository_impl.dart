import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/home/domain/entity/client_banner_dto.dart';
import 'package:bonoos/features/home/domain/repository/banners_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

/// Abumarket uchun alohida so‘rov — `BASE_URL` va ilova tokenlari ishlatilmaydi.
class BannersRepositoryImpl implements BannersRepository {
  static final Dio _publicDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
      },
      validateStatus: (s) => s != null && s > 0 && s < 500,
    ),
  );

  @override
  Future<Either<Failure, List<ClientBannerDto>>> fetchAbuMarketBanners() async {
    try {
      final response = await _publicDio.get(
        ListAPI.abuMarketBannersAllUrl,
        queryParameters: const {'type': 1},
      );
      if (response.statusCode != 200) {
        return Left(
          ServerFailure(message: 'Bannerlar yuklanmadi (${response.statusCode}).'),
        );
      }
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto‘g‘ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! List) {
        return const Right(<ClientBannerDto>[]);
      }
      final list = <ClientBannerDto>[];
      for (final item in data) {
        if (item is Map) {
          list.add(ClientBannerDto.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
        message: 'Internet aloqasi yo‘q yoki vaqt tugadi.',
      );
    }
    return const ServerFailure(message: 'Bannerlar yuklanmadi.');
  }
}
