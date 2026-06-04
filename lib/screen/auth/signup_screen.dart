import 'dart:ui';
import 'package:e_commerce/core/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/supabase_images.dart';
import '../../widget/my_button.dart';
import '../../widget/my_text_field.dart';

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
  double passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = passwordController.text;
    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    setState(() => passwordStrength = strength);
  }

  @override
  void dispose() {
    passwordController.removeListener(_checkPasswordStrength);
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
      '',
    );

    if (!mounted) return;

    if (auth.user != null) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Signup failed")),
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
          const _SignupBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppPadding.large),
              child: Column(
                children: [
                  const _SignupHeader(),
                  const SizedBox(height: 32),
                  _buildForm(auth, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthController auth, ThemeData theme) {
    return Form(
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
                Text("Create Account",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 8),
                _buildPasswordStrengthIndicator(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                auth.isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(text: "Sign Up", onTap: signup),
                const SizedBox(height: 24),
                const _DividerWithText(text: "OR"),
                const SizedBox(height: 24),
                _buildSocialLogin(),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: widget.onTap,
                  child: const Text("Already a User? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return MyTextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      hintText: 'Email',
      obscureText: false,
      prefixIcon: const Icon(Icons.mail_outline),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter an email';
        if (!value.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return MyTextField(
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
        if (value == null || value.length < 6) {
          return 'Password requires 6+ characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return LinearProgressIndicator(
      value: passwordStrength,
      backgroundColor: Colors.grey.shade300,
      color: passwordStrength <= 0.25
          ? Colors.red
          : passwordStrength <= 0.5
              ? Colors.orange
              : passwordStrength <= 0.75
                  ? Colors.yellow
                  : Colors.green,
    );
  }

  Widget _buildConfirmPasswordField() {
    return MyTextField(
      controller: confirmPasswordController,
      keyboardType: TextInputType.visiblePassword,
      hintText: 'Confirm Password',
      obscureText: !isPasswordVisible,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Confirm your password';
        return null;
      },
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _socialButton(Icons.g_mobiledata, () {}),
        _socialButton(Icons.apple, () {}),
      ],
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

class _SignupBackground extends StatelessWidget {
  const _SignupBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SupabaseImage(
            imageName: 'login_sofa.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      "LUXE",
      style: GoogleFonts.playfairDisplay(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
        color: Colors.brown.shade800,
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
