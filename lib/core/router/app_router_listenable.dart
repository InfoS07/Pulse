import 'package:flutter/material.dart';
import 'package:pulse/features/auth/domain/repository/auth_repository.dart';
import 'package:pulse/init_dependencies.dart';

class AppRouterListenable extends ChangeNotifier {
  AppRouterListenable();

  final authRepository = serviceLocator<AuthRepository>();

  Future<void> signOut() => authRepository.signOut().then((_) {
        notifyListeners();
      });
}

final appRouterListenableProvider = AppRouterListenable();
