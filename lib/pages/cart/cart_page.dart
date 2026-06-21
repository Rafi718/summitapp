import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _voucherController = TextEditingController();
  final _formatter = NumberFormat('#,###', 'id_ID');

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final cart = context.read<CartProvider>();
    final code = _voucherController.text.trim();
    if (code.isEmpty) return;

    cart.applyVoucher(code).then((error) {
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.sale),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher berhasil diterapkan')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>().products;
    final auth = context.watch<AuthProvider>();

    if (products.isNotEmpty) {
      cart.setProductCache(products);
    }

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Keranjang'),
              Expanded(
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Belum login',
                  description: 'Login untuk mulai belanja',
                  actionLabel: 'Login',
                  onAction: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: cart.items.isEmpty
            ? Column(
                children: [
                  const PageHeader(title: 'Keranjang'),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Keranjang kosong',
                      description: 'Yuk tambahkan peralatan pendakian',
                      actionLabel: 'Mulai Belanja',
                      onAction: () => Navigator.pushNamed(context, '/main'),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  PageHeader(
                    title: 'Keranjang',
                    subtitle: '${cart.itemCount} item',
                    trailing: cart.items.isNotEmpty
                        ? GestureDetector(
                            onTap: () => cart.clearCart(),
                            child: Text('Hapus semua', style: AppText.caption(size: 12, color: AppColors.sale, weight: FontWeight.w500)),
                          )
                        : null,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      itemCount: cart.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == cart.items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildVoucherSection(cart),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCartItem(cart.items[index], products, cart),
                        );
                      },
                    ),
                  ),
                  _buildBottomCheckout(cart),
                ],
              ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, List<Product> products, CartProvider cart) {
    final product = products.firstWhereOrNull((p) => p.id == item.productId);
    if (product == null) return const SizedBox.shrink();

    final imageUrl = product.images.isNotEmpty ? product.images[0] : '';

    return Dismissible(
      key: Key('cart_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.sale, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => cart.removeItem(item.id!),
      child: DarkCard(
        color: AppColors.background,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 72, height: 72,
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppText.body(size: 13, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('Rp ${_formatter.format(product.effectivePrice)}', style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.brand)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildQtyRow(item, cart),
                const SizedBox(height: 8),
                Text('Rp ${_formatter.format(product.effectivePrice * item.qty)}', style: AppText.caption(size: 11, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyRow(dynamic item, CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(Icons.remove, () => cart.updateQty(item.id, item.qty - 1)),
          SizedBox(
            width: 28,
            child: Text('${item.qty}', textAlign: TextAlign.center, style: AppText.body(size: 13, weight: FontWeight.w600)),
          ),
          _qtyButton(Icons.add, () => cart.updateQty(item.id, item.qty + 1)),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26, height: 26,
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildVoucherSection(CartProvider cart) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voucher Diskon', style: AppText.title(size: 14)),
          const SizedBox(height: 12),
          if (cart.appliedVoucherCode != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.brand, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cart.appliedVoucherCode!, style: AppText.body(size: 13, weight: FontWeight.w600, color: AppColors.brand)),
                        Text('Diskon Rp ${_formatter.format(cart.voucherDiscount)}', style: AppText.caption(size: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cart.removeVoucher(),
                    child: const Icon(Icons.close, size: 16, color: AppColors.textPrimary),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode voucher',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: AppText.body(size: 13),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _applyVoucher,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                    child: Text('Pakai', style: AppText.button(size: 12)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: AppText.caption(size: 11, color: AppColors.textMuted)),
                  Text('Rp ${_formatter.format(cart.total)}', style: AppText.title(size: 18, weight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              width: 140,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                child: Text('Checkout', style: AppText.button(size: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
