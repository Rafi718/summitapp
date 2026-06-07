import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../../config/app_theme.dart';
import '../../widgets/product_card.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final productId = args['productId'] as int;
    final productProvider = context.read<ProductProvider>();
    final product = productProvider.getProductById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Produk')),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    final relatedProducts = productProvider.getRelatedProducts(productId, product.categoryId);
    final formatter = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(product, formatter),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceSection(product, formatter),
                  const SizedBox(height: 16),
                  _buildInfoRow(product),
                  const SizedBox(height: 20),
                  _buildQtySelector(),
                  const SizedBox(height: 20),
                  _buildDescription(product),
                  if (product.sizeGuide != null) ...[
                    const SizedBox(height: 16),
                    _buildSizeGuide(product),
                  ],
                  const SizedBox(height: 24),
                  if (relatedProducts.isNotEmpty) ...[
                    const Text('Produk Terkait', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(width: 170, child: ProductCard(product: relatedProducts[index], compact: true));
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildSliverAppBar(Product product, NumberFormat formatter) {
    final images = product.images.isNotEmpty
        ? product.images
        : ['https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600'];

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(images[index], fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 80, color: Colors.grey))
                );
              },
            ),
            if (product.isOnSale)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${product.discountPercent}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection(Product product, NumberFormat formatter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rp ${formatter.format(product.effectivePrice)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
        ),
        if (product.isOnSale) ...[
          const SizedBox(width: 8),
          Text(
            'Rp ${formatter.format(product.price)}',
            style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(Product product) {
    return Row(
      children: [
        _buildInfoChip(Icons.star, '${product.rating}', AppTheme.accentYellow),
        const SizedBox(width: 16),
        _buildInfoChip(Icons.shopping_bag, '${product.soldCount} terjual', Colors.grey),
        const SizedBox(width: 16),
        _buildInfoChip(Icons.inventory, 'Stok ${product.stock}', product.stock > 10 ? Colors.green : Colors.red),
        const Spacer(),
        Text(product.brand, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryGreen)),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildQtySelector() {
    return Row(
      children: [
        const Text('Jumlah: ', style: TextStyle(fontSize: 15)),
        IconButton.filled(
          onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(backgroundColor: Colors.grey[200]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        IconButton.filled(
          onPressed: () => setState(() => _qty++),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Deskripsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(product.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDetailItem('Berat', '${product.weight}g'),
            _buildDetailItem('Brand', product.brand),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeGuide(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(product.sizeGuide!, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: product.stock > 0 ? () {
                    final auth = context.read<AuthProvider>();
                    final cart = context.read<CartProvider>();
                    if (!auth.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Silakan login terlebih dahulu')),
                      );
                      return;
                    }
                    cart.addToCart(product.id!, qty: _qty);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} ditambahkan ke keranjang')),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                  ),
                  child: Text(
                    product.stock > 0 ? 'Tambah ke Keranjang' : 'Stok Habis',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: product.stock > 0 ? () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Silakan login terlebih dahulu')),
                      );
                      return;
                    }
                    context.read<CartProvider>().addToCart(product.id!, qty: _qty);
                    Navigator.pushNamed(context, '/cart');
                  } : null,
                  child: const Text('Beli Sekarang', style: TextStyle(fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
