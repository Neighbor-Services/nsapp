import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/models/failure.dart';
import '../repository/shared_repository.dart';

class GetMyNotificationsUseCase extends UseCase {
  final SharedRepository repository;

  GetMyNotificationsUseCase(this.repository);
  @override
  Future<Either<Failure, List<NotificationData>>> call(dynamic params) async {
    final int page = (params is int) ? params : 1;
    final results = await repository.getMyNotifications(page: page);
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}


