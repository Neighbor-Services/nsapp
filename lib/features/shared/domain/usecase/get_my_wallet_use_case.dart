import 'package:dartz/dartz.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';

class GetMyWalletUseCase {
  final SharedRepository repository;

  GetMyWalletUseCase(this.repository);

  Future<Either<Failure, Wallet>> call() async {
    return await repository.getMyWallet();
  }
}
