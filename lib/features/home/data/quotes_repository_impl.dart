import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/home/domain/entity/quote_dto.dart';
import 'package:bonoos/features/home/domain/repository/quotes_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<QuoteDto>>> fetchQuotes() async {
    try {
      final raw = await _dio.get(ListAPI.quotes);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(BadResponseFailure(message: 'Javob formati noto‘g‘ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final data = map['data'];
      if (data is! List) {
        return const Right(<QuoteDto>[]);
      }
      final list = <QuoteDto>[];
      for (final item in data) {
        if (item is Map) {
          list.add(QuoteDto.fromJson(Map<String, dynamic>.from(item)));
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
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = m['message']?.toString() ?? m['detail']?.toString();
    }
    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Ruxsat yo‘q.');
    }
    return ServerFailure(message: msg ?? 'Iqtiboslar yuklanmadi.');
  }
}
