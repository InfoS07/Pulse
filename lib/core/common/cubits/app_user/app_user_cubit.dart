import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pulse/core/common/entities/user.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserLoggedOut());
    } else {
      print("OneSignal login");
      OneSignal.login(user.uid);
      emit(AppUserLoggedIn(user));
    }
  }

  // Ajout d'une méthode pour simuler la vérification de l'état de connexion
  void checkUserLoggedIn() async {
    emit(AppUserChecking());
    // utiliser currentUser de CurrentUser pour obtenir l'utilisateur actuel

    //updateUser(user);
  }
}


/* class AppUserCubit extends Cubit<AppUserState> {
  final CurrentUser _currentUser;

  AppUserCubit(this._currentUser) : super(AppUserInitial());

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserLoggedOut());
    } else {
      emit(AppUserLoggedIn(user));
    }
  }

  void checkUserLoggedIn() async {
    emit(AppUserChecking());
    final res = await _currentUser(NoParams());
    res.fold(
      (failure) => updateUser(null),
      (user) => updateUser(user),
    );
  }
} */