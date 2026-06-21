import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Profil'),
              Expanded(
                child: EmptyState(
                  icon: Icons.person_outline,
                  title: 'Belum login',
                  description: 'Login untuk mengakses akunmu',
                  actionLabel: 'Login',
                  onAction: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = auth.currentUser!;

    final accountMenu = <Widget>[
      _menuItem(context, icon: Icons.person_outline, title: 'Edit Profil', onTap: () => Navigator.pushNamed(context, '/edit-profile')),
      _menuItem(context, icon: Icons.location_on_outlined, title: 'Alamat Saya', onTap: () => Navigator.pushNamed(context, '/address-list')),
      _menuItem(context, icon: Icons.favorite_border, title: 'Wishlist', onTap: () => Navigator.pushNamed(context, '/wishlist')),
      if (user.isAdmin)
        _menuItem(context, icon: Icons.admin_panel_settings_outlined, title: 'Admin Panel', onTap: () => Navigator.pushNamed(context, '/admin')),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const PageHeader(title: 'Profil'),
            const SizedBox(height: 8),
            _buildProfileHeader(user),
            const SizedBox(height: 20),
            _buildMenuSection(context, accountMenu),
            const SizedBox(height: 12),
            _buildMenuSection(context, [
              _menuItem(context, icon: Icons.help_outline, title: 'FAQ', onTap: () {}),
              _menuItem(context, icon: Icons.chat_bubble_outline, title: 'WhatsApp CS', onTap: () {}),
              _menuItem(context, icon: Icons.info_outline, title: 'Tentang Summit App', onTap: () {}),
            ]),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, auth),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.sale, side: const BorderSide(color: AppColors.sale)),
                  child: Text('Logout', style: AppText.button(size: 14, color: AppColors.sale)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: user.photo != null
                ? Image.file(File(user.photo!), fit: BoxFit.cover)
                : const Icon(Icons.person, color: AppColors.brand, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: AppText.body(size: 16, weight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(user.email, style: AppText.caption(size: 12, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    // Wrap in Material(Colors.transparent) so the ListTile's ink splash
    // and background paint on a Material ancestor — otherwise the
    // surrounding Container in _buildMenuSection (which has its own
    // background color) hides those effects and Flutter throws an
    // assertion in debug mode.
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary, size: 20),
        title: Text(title, style: AppText.body(size: 14, weight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Logout', style: AppText.title(size: 16)),
      content: Text('Yakin ingin keluar?', style: AppText.body(size: 13, color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            auth.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
          child: const Text('Logout'),
        ),
      ],
    ));
  }
}
