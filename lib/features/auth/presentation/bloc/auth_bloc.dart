import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/common/entities/user.dart';
import 'package:pulse/core/usecase/usercase.dart';
import 'package:pulse/features/auth/domain/usecases/current_user.dart';
import 'package:pulse/features/auth/domain/usecases/user_login.dart';
import 'package:pulse/features/auth/domain/usecases/user_reset_password.dart';
import 'package:pulse/features/auth/domain/usecases/user_sign_up.dart';
import 'package:pulse/features/profil/domain/usecases/signout.dart';
// Assurez-vous d'importer le package get_it

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final SignOut _signOut;
  final AppUserCubit _appUserCubit;
  final UserResetPassword _userResetPassword;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required SignOut signOut,
    required AppUserCubit appUserCubit,
    required UserResetPassword userResetPassword,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _signOut = signOut,
        _appUserCubit = appUserCubit,
        _userResetPassword = userResetPassword,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthSignOut>(_onSignOut);
    on<AuthResetPassword>(_onResetPassword);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUp(
    AuthSignUp event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    _appUserCubit.updateUser(null);
    emit(AuthInitial());
    await _signOut();
  }

  void _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    final res =
        await _userResetPassword(UserResetPasswordParams(email: event.email));

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => emit(AuthResetPasswordSuccess()),
    );
  }
}
