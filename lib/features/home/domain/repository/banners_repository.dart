import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/home/domain/entity/client_banner_dto.dart';
import 'package:dartz/dartz.dart';

abstract class BannersRepository {
  Future<Either<Failure, List<ClientBannerDto>>> fetchAbuMarketBanners();
}
