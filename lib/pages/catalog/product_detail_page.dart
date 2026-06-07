import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';
import '../home/widgets/alpine_product_card.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final productId = args?['productId'] as int?;
    final productProvider = context.read<ProductProvider>();
    final product = productId != null ? productProvider.getProductById(productId) : null;

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Detail Produk', showBackButton: true),
              Expanded(
                child: EmptyState(
                  icon: Icons.image_outlined,
                  title: 'Produk tidak ditemukan',
                  actionLabel: 'Kembali',
                  onAction: () => Navigator.maybePop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final relatedProducts = productProvider.getRelatedProducts(productId!, product.categoryId);
    final formatter = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(product, formatter),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  _buildImageCarousel(product),
                  const SizedBox(height: 16),
                  _buildPriceSection(product, formatter),
                  const SizedBox(height: 8),
                  _buildInfoRow(product),
                  const SizedBox(height: 16),
                  _buildQtySelector(),
                  const SizedBox(height: 16),
                  _buildDescription(product),
                  if (product.sizeGuide != null) ...[
                    const SizedBox(height: 12),
                    _buildSizeGuide(product),
                  ],
                  if (relatedProducts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Produk Terkait', style: AppText.title(size: 16)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) => ProductCard(product: relatedProducts[index]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildBottomBar(product, formatter),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Product product, NumberFormat formatter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.arrow_back, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.favorite_border, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.share_outlined, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Product product) {
    final images = product.images.isNotEmpty ? product.images : [AppAssets.hero];
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(images[0], fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80, color: AppColors.textMuted),
          loadingBuilder: (context, child, p) => p == null ? child : Container(color: AppColors.surfaceAlt),
        ),
      ),
    );
  }

  Widget _buildPriceSection(Product product, NumberFormat formatter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Rp ${formatter.format(product.effectivePrice)}', style: AppText.display(size: 22, weight: FontWeight.w700)),
        if (product.isOnSale) ...[
          const SizedBox(width: 8),
          Text('Rp ${formatter.format(product.price)}', style: AppText.body(size: 13, color: AppColors.textMuted).copyWith(decoration: TextDecoration.lineThrough)),
        ],
      ],
    );
  }

  Widget _buildInfoRow(Product product) {
    return Row(
      children: [
        _infoChip(Icons.star_outline, '${product.rating}', AppColors.warning),
        const SizedBox(width: 12),
        _infoChip(Icons.shopping_bag_outlined, '${product.soldCount} terjual', AppColors.textMuted),
        const SizedBox(width: 12),
        _infoChip(Icons.inventory_2_outlined, 'Stok ${product.stock}', product.stock > 10 ? AppColors.brand : AppColors.sale),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppText.caption(size: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildQtySelector() {
    return Row(
      children: [
        Text('Jumlah', style: AppText.body(size: 14, weight: FontWeight.w500)),
        const Spacer(),
        Container(
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              _qtyBtn(Icons.remove, _qty > 1 ? () => setState(() => _qty--) : null),
              SizedBox(width: 36, child: Text('$_qty', textAlign: TextAlign.center, style: AppText.body(size: 14, weight: FontWeight.w600))),
              _qtyBtn(Icons.add, () => setState(() => _qty++)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: onTap == null ? AppColors.textMuted : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: AppText.title(size: 18, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(product.description, style: AppText.body(size: 13, color: AppColors.textSecondary, height: 1.6)),
        const SizedBox(height: 12),
        Row(
          children: [
            _detailItem('Berat', '${product.weight}g'),
            const SizedBox(width: 12),
            _detailItem('Brand', product.brand),
          ],
        ),
      ],
    );
  }

  Widget _detailItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.caption(size: 11, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value, style: AppText.body(size: 13, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeGuide(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brand.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.brand, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(product.sizeGuide!, style: AppText.caption(size: 12, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.divider))),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: product.stock > 0 ? () => _addToCart(product, buyNow: false) : null,
                  child: Text('Tambah Keranjang', style: AppText.button(size: 13, color: AppColors.textPrimary)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: product.stock > 0 ? () => _addToCart(product, buyNow: true) : null,
                  child: Text('Beli Sekarang', style: AppText.button(size: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(Product product, {required bool buyNow}) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login dulu')));
      return;
    }
    context.read<CartProvider>().addToCart(product.id!, qty: _qty);
    if (buyNow) {
      Navigator.pushNamed(context, '/cart');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan')));
    }
  }
}
