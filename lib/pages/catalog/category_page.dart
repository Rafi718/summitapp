import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class CategoryPage extends StatelessWidget {
  CategoryPage({super.key});

  final List<IconData> _categoryIcons = const [
    Icons.cabin, Icons.bedtime, Icons.backpack, Icons.hiking,
    Icons.style, Icons.lock, Icons.light, Icons.airline_seat_flat,
    Icons.outdoor_grill, Icons.category,
  ];

  final List<Color> _categoryColors = const [
    const Color(0xFF2E7D32), const Color(0xFF1565C0), const Color(0xFF6A1B9A),
    const Color(0xFFE65100), const Color(0xFF00695C), const Color(0xFFC62828),
    const Color(0xFFF9A825), const Color(0xFF4E342E), const Color(0xFF0277BD),
    const Color(0xFF546E7A),
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _buildCategoryCard(context, cat, index);
              },
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, dynamic cat, int index) {
    final color = _categoryColors[index % _categoryColors.length];
    final icon = _categoryIcons[index % _categoryIcons.length];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-list', arguments: {'categoryId': cat.id, 'categoryName': cat.name});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
