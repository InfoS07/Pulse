import 'package:pulse/core/services/graphql_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final GraphQLService graphQLService;

  AuthRemoteDataSourceImpl(this.supabaseClient, this.graphQLService);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null || response.session == null) {
        throw const ServerException('Login failed: User or session is null.');
      }

      final uid = response.user?.id;

      if (uid == null) {
        throw const ServerException('Login failed: User id is null.');
      }

      final userData = await supabaseClient
          .from('users')
          .select()
          .eq(
            'uid',
            uid,
          )
          .single();

      await _saveToken(response.session!.accessToken);
      await graphQLService.setToken(response.session!.accessToken);

      final profile_photo = await supabaseClient.storage
          .from('profil')
          .getPublicUrl(userData['profile_photo']);

      userData['profile_photo'] = profile_photo;

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final data = <String, dynamic>{
        "last_name": lastName,
        "first_name": firstName,
        "birth_date": "2000-01-01",
      };
      final response = await supabaseClient.auth
          .signUp(email: email, password: password, data: data);

      if (response.user == null || response.session == null) {
        throw const ServerException('Signup failed: User or session is null.');
      }

      final uid = response.user?.id;

      if (uid == null) {
        throw const ServerException('Login failed: User id is null.');
      }

      final userData = await supabaseClient
          .from('users')
          .select()
          .eq(
            'uid',
            uid,
          )
          .single();

      await _saveToken(response.session!.accessToken);
      await graphQLService.setToken(response.session!.accessToken);

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('accessToken'); // Optionally, clear the token on sign out
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient
            .from('users')
            .select()
            .eq(
              'uid',
              currentUserSession!.user.id,
            )
            .single();

        final profile_photo = await supabaseClient.storage
            .from('profil')
            .getPublicUrl(userData['profile_photo']);

        userData['profile_photo'] = profile_photo;

        return UserModel.fromJson(userData).copyWith(
          email: currentUserSession!.user.email,
        );
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
