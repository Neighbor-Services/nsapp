// import 'package:dartz/dartz.dart';
// import 'package:nsapp/core/helpers/use_case.dart';

// import '../../../../core/models/failure.dart';
// import '../repository/shared_repository.dart';

// class SendNotificationUseCase extends UseCase{
//   final SharedRepository repository;

//   SendNotificationUseCase(this.repository);
//   @override
//   Future<Either<Failure, bool>> call(params) async {
//     final results = await repository.sendNotification(params);
//     return results.fold((l) => Left(l), (r) => Right(r));
//   }

// }
