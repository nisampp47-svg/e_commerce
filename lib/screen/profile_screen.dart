

import 'package:e_commerce/services/supabase_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final SupabaseAuthService _authService = SupabaseAuthService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _authService.userName,
    );
    _emailController = TextEditingController(
      text: _authService.userEmail,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildMenuSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _IconButton(
            icon: Icons.chevron_left_rounded,
            onTap: () {},
          ),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D23),
              letterSpacing: -0.3,
            ),
          ),
          _IconButton(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar with edit button
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/200?img=11',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _,_) => const Icon(
                    Icons.person,
                    size: 52,
                    color: Color(0xFFB0BAC9),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  // Handle avatar edit
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3D7BFF),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Name (editable)
        GestureDetector(
          onTap: () {
            setState(() => _isEditingName = true);
          },
          child: _isEditingName
              ? SizedBox(
            width: 200,
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D23),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3D7BFF), width: 2),
                ),
              ),

              onTapOutside: (_) => setState(() => _isEditingName = false),
            ),
          )
              : Text(
            _nameController.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1D23),
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF8B95A5),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // Edit Profile Button
        GestureDetector(
          onTap: () {
            setState(() => _isEditingName = true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF3D7BFF),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D7BFF).withAlpha(35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionGroup(
            label: 'SHOPPING ACTIVITY',
            items: [
              _MenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'My Orders',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionGroup(
            label: 'ACCOUNT DETAILS',
            items: [
              _MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Shipping Addresses',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.credit_card_outlined,
                label: 'Payment Methods',
                onTap: () {},
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionGroup(
            label: 'SUPPORT & INFO',
            items: [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help Center',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                isLast: true,
                isDestructive: true,
                onTap: () async {
                  await _authService.signOut();

                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionGroup({
    required String label,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB0BAC9),
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF1A1D23)),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFE53935) : const Color(0xFF1A1D23);
    final iconBg = isDestructive
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFEEF3FF);
    final iconColor = isDestructive ? const Color(0xFFE53935) : const Color(0xFF3D7BFF);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: const Color(0xFFB0BAC9),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 68,
            endIndent: 0,
            color: Color(0xFFF0F2F5),
          ),
      ],
    );
  }
}