import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Admin Panel', showBackButton: true),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  _AdminCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Kelola Produk',
                    subtitle: 'Tambah, edit, atau hapus produk',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminProducts),
                  ),
                  const SizedBox(height: 16),
                  _AdminCard(
                    icon: Icons.category_outlined,
                    title: 'Kelola Kategori',
                    subtitle: 'Atur kategori produk',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminCategories),
                  ),
                  const SizedBox(height: 32),
                  const _SectionLabel('Zona Berbahaya'),
                  const SizedBox(height: 12),
                  _AdminCard(
                    icon: Icons.restart_alt,
                    title: 'Reset Data ke Default',
                    subtitle: 'Hapus semua produk, kategori, voucher & pesanan, lalu isi ulang dari seed',
                    destructive: true,
                    onTap: () => _confirmReset(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset semua data?', style: AppText.title(size: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tindakan ini akan menghapus:',
              style: AppText.body(size: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ..._resetBullets.map((b) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text('• $b', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
            )),
            const SizedBox(height: 12),
            Text(
              'Akun user tetap aman. Data akan diisi ulang dari seed.',
              style: AppText.caption(size: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
            child: const Text('Reset Sekarang'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Run the reset. Surface success/failure via SnackBar on the dashboard.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthProvider>().service.resetSeed();
      if (!context.mounted) return;
      await context.read<ProductProvider>().loadProducts();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Data berhasil direset ke default'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reset gagal: $e'),
          backgroundColor: AppColors.sale,
        ),
      );
    }
  }

  static const _resetBullets = [
    'Semua produk',
    'Semua kategori',
    'Semua voucher',
    'Semua pesanan & riwayat',
    'Keranjang & wishlist',
  ];
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.sale.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(text, style: AppText.label(size: 10, color: AppColors.sale, letterSpacing: 0.8)),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Divider(color: AppColors.divider, height: 1),
          ),
        ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.sale : AppColors.brand;
    final iconBg = destructive
        ? AppColors.sale.withValues(alpha: 0.08)
        : AppColors.brand.withValues(alpha: 0.08);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: destructive ? AppColors.sale.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 5,
              height: 88,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title(size: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.caption(size: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}