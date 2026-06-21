import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  @override
  void initState() {
    super.initState();
    // Reset filters so all products are visible in admin view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().setSearchQuery('');
      context.read<ProductProvider>().setCategory(0);
      context.read<ProductProvider>().setSortBy('terbaru');
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.adminProductForm),
        backgroundColor: AppColors.brand,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Produk', style: AppText.button(size: 13)),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Kelola Produk', showBackButton: true),
            _buildSearchBar(productProvider),
            Expanded(
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                  : productProvider.products.isEmpty
                      ? EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'Belum ada produk',
                          description: 'Tambahkan produk pertama dengan tombol di bawah',
                          actionLabel: 'Tambah Produk',
                          onAction: () => Navigator.pushNamed(context, AppRoutes.adminProductForm),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products[index];
                            final category = productProvider.categories
                                .where((c) => c.id == product.categoryId)
                                .firstOrNull;
                            return _ProductCard(
                              product: product,
                              categoryName: category?.name ?? '-',
                              onEdit: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminProductForm,
                                arguments: {'productId': product.id},
                              ),
                              onDelete: () => _confirmDelete(context, product.id!, product.name),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ProductProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: provider.setSearchQuery,
        style: AppText.body(size: 14),
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: AppText.body(size: 14, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int productId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Produk', style: AppText.title(size: 16)),
        content: Text('Hapus "$productName"? Tindakan ini tidak dapat dibatalkan.', style: AppText.body(size: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await context.read<ProductProvider>().deleteProduct(productId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Produk berhasil dihapus'),
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

class _ProductCard extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: AppImage(
              src: imageUrl,
              fit: BoxFit.cover,
              placeholder: const Icon(Icons.image, color: AppColors.textMuted, size: 24),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(size: 14, weight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: product.isActive ? 'Aktif' : 'Non-aktif',
                        color: product.isActive ? AppColors.success : AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.brand} · $categoryName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption(size: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Rp ${_currencyFormat.format(product.effectivePrice)}',
                        style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Rp ${_currencyFormat.format(product.price)}',
                          style: AppText.caption(size: 11, color: AppColors.textMuted).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                      const Spacer(),
                      Text('Stok: ${product.stock}', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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

final _currencyFormat = NumberFormat('#,###', 'id_ID');