import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    return await authRepository.signUpWithEmailPassword(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  UserSignUpParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}
