
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_images.dart';
import '../../widget/my_button.dart';
import '../../widget/my_text_field.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    await context.read<AuthController>().login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    if (!mounted) return;
    final auth = context.read<AuthController>();

    if (auth.user != null) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SupabaseImage(
              imageName: 'login_sofa.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.white.withValues(alpha: 0.4))),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.large),
              child: Column(
                children: [
                  Text(
                    "LUXE",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: formKey,
                    child: ClipRRect(
                      borderRadius: AppRadius.largeBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(AppPadding.large),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: AppRadius.largeBorderRadius,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Welcome Back", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              MyTextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'Email',
                                obscureText: false,
                                prefixIcon: const Icon(Icons.mail_outline),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter your email';
                                  if (!value.contains('@')) return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              MyTextField(
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                hintText: 'Password',
                                obscureText: !isPasswordVisible,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                ),
                                validator: (value) {
                                  if (value == null || value.length < 6) return "Password must be at least 6 characters";
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
                              ),
                              const SizedBox(height: 16),
                              auth.isLoading
                                  ? const CircularProgressIndicator()
                                  : MyButton(text: "Login", onTap: login),
                              const SizedBox(height: 24),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text("OR"),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _socialButton(Icons.g_mobiledata, () {}),
                                  _socialButton(Icons.apple, () {}),
                                ],
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: widget.onTap,
                                child: const Text("Not a Member? Register Now"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}
