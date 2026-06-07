import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _banners = [
    {'title': 'Flash Sale Gear Pendakian', 'subtitle': 'Diskon hingga 40%', 'color': AppTheme.accentOrange},
    {'title': 'Peralatan Baru Hadir!', 'subtitle': 'Koleksi Naturehike & Deuter', 'color': AppTheme.primaryGreen},
    {'title': 'Gratis Ongkir!', 'subtitle': 'Minimal belanja Rp 200.000', 'color': const Color(0xFF1565C0)},
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summit App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productProvider.loadProducts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerCarousel(),
                    const SizedBox(height: 20),
                    _buildCategoryRow(theme),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Diskon Spesial', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList(productProvider.onSaleProducts),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Produk Terlaris', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildHorizontalProductList(productProvider.popularProducts),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Semua Produk', onTap: () {}),
                    const SizedBox(height: 12),
                    _buildProductGrid(productProvider.products),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [banner['color'] as Color, (banner['color'] as Color).withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(banner['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(banner['subtitle'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(ThemeData theme) {
    final productProvider = context.read<ProductProvider>();
    final categories = productProvider.categories.take(6).toList();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/main'),
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text('Lainnya', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
            );
          }

          final cat = categories[index];
          final icons = [Icons.cabin, Icons.bedtime, Icons.backpack, Icons.hiking, Icons.style, Icons.lock];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/product-list', arguments: {'categoryId': cat.id});
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icons[index], color: theme.colorScheme.primary, size: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(cat.name, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onTap, child: const Text('Lihat Semua')),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List<dynamic> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tidak ada produk', style: TextStyle(color: Colors.grey)),
      );
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return SizedBox(width: 170, child: ProductCard(product: products[index], compact: true));
        },
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: products.take(6).length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
    );
  }
}
