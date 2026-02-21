import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetSubscriptionPlansUseCase {
  final SharedRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionPlan>>> call() async {
    return await repository.getSubscriptionPlans();
  }
}
