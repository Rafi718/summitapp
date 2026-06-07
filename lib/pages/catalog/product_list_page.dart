import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String _sortBy = 'terbaru';

  final List<String> _sortOptions = ['terbaru', 'termurah', 'termahal', 'terlaris', 'rating'];
  final Map<String, String> _sortLabels = {
    'terbaru': 'Terbaru',
    'termurah': 'Termurah',
    'termahal': 'Termahal',
    'terlaris': 'Terlaris',
    'rating': 'Rating Tertinggi',
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
      appBar: AppBar(
        title: Text(categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortRow(),
          Expanded(
            child: productProvider.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Belum ada produk', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: productProvider.products[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sortOptions.map((sort) {
                  final isSelected = _sortBy == sort;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_sortLabels[sort]!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _sortBy = sort);
                        context.read<ProductProvider>().setSortBy(sort);
                      },
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
