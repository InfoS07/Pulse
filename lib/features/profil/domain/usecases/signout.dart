import 'package:pulse/core/router/app_router_listenable.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';

class SignOut {
  final AppRouterListenable appRouterListenable;

  SignOut(this.appRouterListenable);

  Future<void> call() async {
    return await appRouterListenable.signOut();
  }
}
