import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/subscription/domain/entity/plan.dart';
import 'package:dartz/dartz.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<Plan>>> fetchPlans();
  Future<Either<Failure, String>> subscribe(int planId);
}
