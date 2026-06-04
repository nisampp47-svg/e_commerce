import '../interfaces/auth_repository.dart';
import '../../../services/supabase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthService _authService = SupabaseAuthService();

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _authService.createAccount(email: email, password: password, name: name);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _authService.resetPassword(email: email);
  }
}
