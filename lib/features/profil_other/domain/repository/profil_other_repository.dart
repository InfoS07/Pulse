import 'package:fpdart/fpdart.dart';
import 'package:pulse/core/common/entities/profil.dart';
import 'package:pulse/core/error/failures.dart';

abstract interface class OtherProfilRepository {
  Future<Either<Failure, Profil>> getProfil();
}
