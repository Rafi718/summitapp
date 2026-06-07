import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Wishlist', showBackButton: true),
            Expanded(
              child: !auth.isLoggedIn
                  ? EmptyState(icon: Icons.favorite_border, title: 'Belum login', description: 'Login untuk melihat wishlist', actionLabel: 'Login', onAction: () => Navigator.pushNamed(context, '/login'))
                  : EmptyState(icon: Icons.favorite_border, title: 'Wishlist kosong', description: 'Simpan produk favoritmu di sini'),
            ),
          ],
        ),
      ),
    );
  }
}
