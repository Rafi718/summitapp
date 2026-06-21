import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category.dart' as models;
import '../../models/product.dart';
import 'alpine_theme.dart';
import 'widgets/section_label.dart';
import 'widgets/alpine_category_card.dart';
import 'widgets/alpine_product_card.dart';
import 'widgets/countdown_chip.dart';
import 'widgets/hero_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _getFirstName() {
    final auth = context.read<AuthProvider>();
    final name = auth.currentUser?.name ?? 'Pendaki';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final auth = context.watch<AuthProvider>();
    final userName = _getFirstName();
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(userName, isLoggedIn),
            ),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: HeroBanner()),
            SliverToBoxAdapter(child: _buildCategoriesSection(productProvider.categories)),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Flash Sale',
                trailing: CountdownChip(endsAt: DateTime.now().add(const Duration(hours: 6, minutes: 23))),
                action: 'Lihat semua',
                onAction: () {},
              ),
            ),
            SliverToBoxAdapter(child: _buildFlashSaleList(productProvider.onSaleProducts.take(6).toList())),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Populer',
                action: 'Lihat semua',
                onAction: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGrid(productProvider.popularProducts, crossAxisCount: 2),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Semua Produk',
                action: 'Lihat semua',
                onAction: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildGrid(productProvider.products, crossAxisCount: 2),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String userName, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logo/logo_app.png',
              width: 40, height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting(),
                  style: AppText.caption(size: 11, color: AppColors.textMuted),
                ),
                Text(
                  isLoggedIn ? userName : 'Masuk dulu',
                  style: AppText.title(size: 16, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _iconButton(Icons.notifications_none, () {}),
          const SizedBox(width: 8),
          _iconButton(Icons.bookmark_border, () => Navigator.pushNamed(context, '/wishlist')),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari peralatan pendakian...',
                  style: AppText.body(size: 13, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(List<models.Category> categories) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CategoryTile(
                category: categories[index],
                onTap: () => Navigator.pushNamed(
                  context, '/product-list',
                  arguments: {'categoryId': categories[index].id, 'categoryName': categories[index].name},
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFlashSaleList(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Belum ada flash sale', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }

  Widget _buildGrid(List<Product> products, {int crossAxisCount = 2}) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada produk', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length > 6 ? 6 : products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index], style: ProductCardStyle.grid);
      },
    );
  }
}
