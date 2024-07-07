import 'package:pulse/core/router/app_router_listenable.dart';

class SignOut {
  final AppRouterListenable appRouterListenable;

  SignOut(this.appRouterListenable);

  Future<void> call() async {
    return await appRouterListenable.signOut();
  }
}
