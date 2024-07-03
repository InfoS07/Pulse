import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabaseClient;

  SupabaseService(String supabaseUrl, String supabaseAnonKey)
      : supabaseClient = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<void> setAuthToken(String token) async {
    //supabaseClient.auth.setAuth(token);
  }
}
