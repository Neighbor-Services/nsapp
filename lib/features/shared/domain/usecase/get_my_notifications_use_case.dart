import 'package:dartz/dartz.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/models/failure.dart';
import '../repository/shared_repository.dart';

class GetMyNotificationsUseCase extends UseCase {
  final SharedRepository repository;

  GetMyNotificationsUseCase(this.repository);
  @override
  Future<Either<Failure, List<NotificationData>>> call(params) async {
    final results = await repository.getMyNotifications();
    return results.fold((l) => Left(l), (r) => Right(r));
  }
}
