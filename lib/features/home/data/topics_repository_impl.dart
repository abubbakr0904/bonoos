import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/home/domain/entity/topic.dart';
import 'package:bonoos/features/home/domain/entity/topic_question.dart';
import 'package:bonoos/features/home/domain/repository/topics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class TopicsRepositoryImpl implements TopicsRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<Topic>>> fetchTopics() async {
    try {
      final raw = await _dio.get(ListAPI.topics);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Right([]);
      }
      final items = list
          .whereType<Map>()
          .map((e) => Topic.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) {
          final c = a.sort.compareTo(b.sort);
          if (c != 0) return c;
          return a.id.compareTo(b.id);
        });
      return Right(items);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopicQuestion>>> fetchTopicQuestions(
    int topicId,
  ) async {
    try {
      final raw = await _dio.get(ListAPI.topicQuestions(topicId));
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Right([]);
      }
      final items = list
          .whereType<Map>()
          .map((e) => TopicQuestion.fromJson(Map<String, dynamic>.from(e)))
          .where((q) => q.status == null || q.status == 1)
          .toList()
        ..sort((a, b) {
          final c = a.sort.compareTo(b.sort);
          if (c != 0) return c;
          return a.id.compareTo(b.id);
        });
      return Right(items);
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
