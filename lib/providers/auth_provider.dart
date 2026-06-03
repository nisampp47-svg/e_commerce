import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_auth_service.dart'; // Verify your path matches

class AuthController extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  User? user;
  bool isLoading = false;
  String? errorMessage;

  // Sync user state on initialization and listen to changes
  AuthController() {
    user = _authService.currentUser;
    _authService.authStateChanges.listen((data) {
      user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      user = result.user;
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "An unexpected error occurred.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await _authService.createAccount(
        email: email,
        password: password,
        name: name,
      );

      user = result.user;
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = "An unexpected error occurred.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    user = null;
    notifyListeners();
  }
}
