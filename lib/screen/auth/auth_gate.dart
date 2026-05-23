import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_navigation_screen.dart';
import 'auth_toggle_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Check if valid session exists
        final session = snapshot.data?.session;
        if (session != null) {
          return MainNavigationScreen(onTap: () {});
        }

        // ❌ Not logged in → Auth screen
        return const LoginRegister();
      },
    );
  }
}