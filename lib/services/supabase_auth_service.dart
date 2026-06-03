import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current session and user
  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  String get userName => currentUser?.userMetadata?['name'] ?? "No Name";

  String get userEmail => currentUser?.email ?? "";

  /// Login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Create Account
  Future<AuthResponse> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name, // Store display name in user_metadata
      },
    );
  }

  /// Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Reset Password
  Future<void> resetPassword({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Delete Account
  Future<void> deleteAccount() async {
    if (currentUser == null) return;
    // Note: Supabase user deletion typically requires an edge function or admin API via backend,
    // but users can unsubscribe/sign out locally. To completely purge records instantly safely:
    await _supabase.auth.signOut();
  }
}