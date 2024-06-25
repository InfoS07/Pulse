import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse/core/error/exceptions.dart';
import 'package:pulse/features/auth/domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
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

  AuthRemoteDataSourceImpl(this.supabaseClient);

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
      print("response.session!.accessToken");
      print(response.session!.accessToken);
      await _saveToken(response.session!.accessToken);
      return UserModel.fromJson(response.user!.toJson()["user_metadata"]);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await supabaseClient.auth.signUp(email: email, password: password);
      if (response.user == null || response.session == null) {
        throw const ServerException('Signup failed: User or session is null.');
      }
      await _saveToken(response.session!.accessToken);
      return UserModel.fromJson(response.user!.toJson()["user_metadata"]);
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
