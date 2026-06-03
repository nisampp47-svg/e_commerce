import 'package:e_commerce/core/app_constants.dart';
import 'package:e_commerce/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final authController = Provider.of<AuthController>(context, listen: false);
    _nameController = TextEditingController(text: authController.user?.email?.split('@').first ?? "User");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text("Profile"),
            actions: [
              IconButton(
                onPressed: () {}, // Go to settings
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(theme, authController),
                const SizedBox(height: 32),
                _buildMenuSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, AuthController auth) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          auth.user?.email ?? "no-email@example.com",
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBorderRadius),
          ),
          child: const Text("Edit Profile"),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: AppPadding.horizontalPadding,
      child: Column(
        children: [
          _buildMenuTile(Icons.inventory_2_outlined, "My Orders", () {}),
          _buildMenuTile(Icons.favorite_border, "Wishlist", () {}),
          _buildMenuTile(Icons.location_on_outlined, "Shipping Addresses", () {}),
          _buildMenuTile(Icons.credit_card_outlined, "Payment Methods", () {}),
          _buildMenuTile(Icons.help_outline, "Help Center", () {}),
          const Divider(height: 32),
          _buildMenuTile(
            Icons.logout,
            "Logout",
            () async {
              await Provider.of<AuthController>(context, listen: false).logout();
              if (context.mounted) context.go('/auth');
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smallBorderRadius),
    );
  }
}
