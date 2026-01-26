import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(params.userId, params.newPassword);
  }
}

class ChangePasswordParams extends Equatable {
  final String userId;
  final String newPassword;

  const ChangePasswordParams({required this.userId, required this.newPassword});

  @override
  List<Object> get props => [userId, newPassword];
}
