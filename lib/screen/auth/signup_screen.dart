import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widget/my_button.dart';
import '../../widget/my_text_field.dart';
import '../home_screen.dart';
// Update to your new provider file path if renamed

class SignupScreen extends StatefulWidget {
  final VoidCallback onTap;
  const SignupScreen({super.key, required this.onTap});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final auth = context.read<AuthController>();
    await auth.register(
      emailController.text.trim(),
      passwordController.text.trim(),
      '', // Passing empty string for name setup as placeholder
    );

    if (!mounted) return;

    if (auth.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomeScreen(categories: [], products: [])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Signup failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_sofa.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.white.withAlpha(115))),
          Positioned(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 1),
              child: Image.asset(
                'assets/images/green_chair.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Text(
                    "LUXE",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.brown.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: 450,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(80),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withAlpha(55)),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 20,
                                color: Colors.black.withAlpha(50),
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              MyTextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'Email',
                                obscureText: false,
                                prefixIcon: const Icon(Icons.mail_lock_outlined),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter an email';
                                  if (!value.contains('@')) return 'Enter a valid email';
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
                                  if (value == null || value.length < 6) return 'Password requires 6+ characters';
                                  return null;
                                },
                              ),
                              MyTextField(
                                controller: confirmPasswordController,
                                keyboardType: TextInputType.visiblePassword,
                                hintText: 'Confirm Password',
                                obscureText: !isPasswordVisible,
                                prefixIcon: const Icon(Icons.lock_outline),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Confirm your password';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              auth.isLoading
                                  ? const CircularProgressIndicator()
                                  : MyButton(text: "Sign Up", onTap: signup),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: widget.onTap,
                                    child: const Text(
                                      "Already a User ?",
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
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
}