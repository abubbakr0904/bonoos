import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/profile/domain/entity/activity.dart';
import 'package:bonoos/features/profile/domain/entity/client_profile.dart';
import 'package:bonoos/features/profile/domain/entity/income_range.dart';
import 'package:bonoos/features/profile/domain/entity/region.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ClientProfile>> fetchMe();
  Future<Either<Failure, List<Region>>> fetchRegions();
  Future<Either<Failure, List<IncomeRange>>> fetchIncomeRanges();
  Future<Either<Failure, List<Activity>>> fetchActivities();
  Future<Either<Failure, String>> uploadAvatar(String filePath);
  Future<Either<Failure, ClientProfile>> updateProfile({
    required String email,
    required String fullName,
    required String birthday,
    required String avatar,
    required String bio,
    required int regionId,
    required int incomeId,
    required int activityId,
  });
}
