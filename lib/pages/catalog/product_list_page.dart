import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';
import '../home/widgets/alpine_product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _sortBy = 'terbaru';

  final Map<String, String> _sortLabels = {
    'terbaru': 'Terbaru',
    'termurah': 'Termurah',
    'termahal': 'Termahal',
    'terlaris': 'Terlaris',
    'rating': 'Rating',
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final categoryId = args?['categoryId'] as int? ?? 0;
    final categoryName = args?['categoryName'] as String? ?? 'Produk';
    final productProvider = context.watch<ProductProvider>();

    if (productProvider.selectedCategoryId != categoryId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        productProvider.setCategory(categoryId);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(title: categoryName, showBackButton: true),
            _buildSortRow(),
            Expanded(
              child: productProvider.products.isEmpty
                  ? EmptyState(icon: Icons.inventory_2_outlined, title: 'Belum ada produk')
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) => ProductCard(product: productProvider.products[index], style: ProductCardStyle.grid),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sortLabels.entries.map((entry) {
                  final isSelected = _sortBy == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _sortBy = entry.key);
                        context.read<ProductProvider>().setSortBy(entry.key);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textPrimary : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(entry.value, style: AppText.caption(size: 12, color: isSelected ? Colors.white : AppColors.textPrimary, weight: FontWeight.w500)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
