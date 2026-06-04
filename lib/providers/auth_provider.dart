import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/service_locator.dart';
import '../data/repositories/interfaces/auth_repository.dart';
import '../services/supabase_auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = getIt<AuthRepository>();
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

      await _authRepository.signIn(
        email: email,
        password: password,
      );

      user = _authService.currentUser;
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

      await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      user = _authService.currentUser;
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
    await _authRepository.signOut();
    user = null;
    notifyListeners();
  }
}
