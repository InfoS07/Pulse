import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
  Future<void> signOut();
}
