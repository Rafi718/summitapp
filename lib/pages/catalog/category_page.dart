import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/product_provider.dart';
import '../../models/category.dart' as models;
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: productProvider.isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.textPrimary))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildAllProductsTile(context),
                        ...categories.asMap().entries.map((entry) {
                          return _buildCategoryCard(context, entry.value, entry.key);
                        }),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Kategori', style: AppText.display(size: 24)),
              ),
              _iconButton(Icons.search, () => Navigator.pushNamed(context, '/search')),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Jelajahi semua kategori peralatan outdoor',
            style: AppText.caption(size: 12, color: AppColors.textMuted),
          ),
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

  Widget _buildAllProductsTile(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-list', arguments: {'categoryId': 0, 'categoryName': 'Semua Produk'}),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -20, bottom: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.grid_view, size: 18, color: AppColors.textPrimary),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semua', style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1, letterSpacing: -0.3,
                      )),
                      const SizedBox(height: 2),
                      Text('Produk', style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1, letterSpacing: -0.3,
                      )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Lihat semua', style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500,
                          )),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, models.Category cat, int index) {
    final imageUrl = cat.image ?? AppAssets.categoryImages[cat.id] ?? AppAssets.hero;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-list', arguments: {'categoryId': cat.id, 'categoryName': cat.name});
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              src: imageUrl,
              fit: BoxFit.cover,
              placeholder: const Icon(Icons.terrain, color: AppColors.textMuted, size: 40),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    cat.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
