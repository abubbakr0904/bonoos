import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/home/domain/entity/quote_dto.dart';
import 'package:dartz/dartz.dart';

abstract class QuotesRepository {
  Future<Either<Failure, List<QuoteDto>>> fetchQuotes();
}
