import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';

class UserResetPassword implements UseCase<Unit, UserResetPasswordParams> {
  final AuthRepository authRepository;

  const UserResetPassword(this.authRepository);

  @override
  Future<Either<Failure, Unit>> call(UserResetPasswordParams params) async {
    return await authRepository.resetPassword(
      email: params.email,
    );
  }
}

class UserResetPasswordParams {
  final String email;

  UserResetPasswordParams({
    required this.email,
  });
}
