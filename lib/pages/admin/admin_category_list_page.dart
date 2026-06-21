import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/category.dart' as models;
import '../../providers/product_provider.dart';
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

IconData _iconFromName(String name) {
  const map = {
    'camping': Icons.cabin,
    'bedtime': Icons.bedtime_outlined,
    'backpack': Icons.backpack_outlined,
    'hiking': Icons.hiking,
    'style': Icons.checkroom_outlined,
    'lock': Icons.lock_outline,
    'light': Icons.lightbulb_outline,
    'airline_seat_flat': Icons.airline_seat_flat,
    'outdoor_grill': Icons.outdoor_grill_outlined,
    'category': Icons.category_outlined,
  };
  return map[name] ?? Icons.category_outlined;
}

class AdminCategoryListPage extends StatelessWidget {
  const AdminCategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.adminCategoryForm),
        backgroundColor: AppColors.brand,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Kategori', style: AppText.button(size: 13)),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Kelola Kategori', showBackButton: true),
            Expanded(
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                  : productProvider.categories.isEmpty
                      ? EmptyState(
                          icon: Icons.category_outlined,
                          title: 'Belum ada kategori',
                          description: 'Tambahkan kategori pertama',
                          actionLabel: 'Tambah Kategori',
                          onAction: () => Navigator.pushNamed(context, AppRoutes.adminCategoryForm),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: productProvider.categories.length,
                          itemBuilder: (context, index) {
                            final category = productProvider.categories[index];
                            final productCount = productProvider.products
                                .where((p) => p.categoryId == category.id)
                                .length;
                            return _CategoryCard(
                              category: category,
                              productCount: productCount,
                              onEdit: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminCategoryForm,
                                arguments: {'categoryId': category.id},
                              ),
                              onDelete: () => _confirmDelete(context, category),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, models.Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Kategori', style: AppText.title(size: 16)),
        content: Text(
          'Hapus "${category.name}"? Kategori yang masih digunakan produk tidak dapat dihapus.',
          style: AppText.body(size: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await context.read<ProductProvider>().deleteCategory(category.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Kategori berhasil dihapus'),
                    backgroundColor: error != null ? AppColors.sale : AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final models.Category category;
  final int productCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconFromName(category.icon);
    final imageUrl = category.image ?? AppAssets.categoryImages[category.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? AppImage(src: imageUrl, fit: BoxFit.cover, placeholder: Icon(icon, color: AppColors.brand, size: 24))
                : Icon(icon, color: AppColors.brand, size: 24),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name, style: AppText.body(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$productCount produk', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.sale),
                  tooltip: 'Hapus',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}