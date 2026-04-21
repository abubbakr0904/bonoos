import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/entity/activity.dart';
import 'package:bonoos/features/profile/domain/entity/income_range.dart';
import 'package:bonoos/features/profile/domain/entity/region.dart';
import 'package:bonoos/features/profile/domain/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, ClientProfile>> fetchMe() async {
    try {
      final raw = await _dio.get(ListAPI.clientProfileMe);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! Map) {
        return const Left(BadResponseFailure(message: 'Profil ma\'lumoti yo\'q.'));
      }
      return Right(ClientProfile.fromJson(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Region>>> fetchRegions() async {
    try {
      final raw = await _dio.get(ListAPI.regions);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(BadResponseFailure(message: 'Viloyatlar ma\'lumoti yo\'q.'));
      }
      final regions = list
          .whereType<Map>()
          .map((e) => Region.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(regions);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncomeRange>>> fetchIncomeRanges() async {
    try {
      final raw = await _dio.get(ListAPI.incomeRanges);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(BadResponseFailure(message: 'Daromad oralig\'lari ma\'lumoti yo\'q.'));
      }
      final ranges = list
          .whereType<Map>()
          .map((e) => IncomeRange.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(ranges);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'webp' => MediaType('image', 'webp'),
        'gif' => MediaType('image', 'gif'),
        _ => MediaType('image', 'jpeg'),
      };

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: mimeType,
        ),
      });

      final raw = await _dio.post(
        ListAPI.clientProfileUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! Map) {
        return const Left(BadResponseFailure(message: 'Rasm yuklanmadi.'));
      }
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        return const Left(BadResponseFailure(message: 'Rasm URL olinmadi.'));
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> fetchActivities() async {
    try {
      final raw = await _dio.get(ListAPI.activities);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(BadResponseFailure(message: 'Faoliyat turlari ma\'lumoti yo\'q.'));
      }
      final activities = list
          .whereType<Map>()
          .map((e) => Activity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(activities);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientProfile>> updateProfile({
    required String email,
    required String fullName,
    required String birthday,
    required String avatar,
    required String bio,
    required int regionId,
    required int incomeId,
    required int activityId,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'full_name': fullName,
        'birthday': birthday,
        'avatar': avatar,
        'bio': bio,
        'region_id': regionId,
        'income': incomeId,
        'activity_id': activityId,
      };
      final raw = await _dio.put(ListAPI.clientProfileUpdate, data: body);
      final response = raw as Response<dynamic>;
      final respBody = response.data;
      if (respBody is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(respBody);
      final data = map['data'];
      if (data is! Map) {
        return const Left(BadResponseFailure(message: 'Profil ma\'lumoti yo\'q.'));
      }
      return Right(ClientProfile.fromJson(Map<String, dynamic>.from(data)));
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
        message: 'Internet aloqasi yo\'q yoki vaqt tugadi.',
      );
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = m['message']?.toString() ?? m['detail']?.toString();
    }
    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Kirish talab qilinadi.');
    }
    return ServerFailure(message: msg ?? 'So\'rov bajarilmadi.');
  }
}
