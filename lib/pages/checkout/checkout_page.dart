import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address.dart';
import '../../models/product.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';
import '../../config/constants.dart';

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formatter = NumberFormat('#,###', 'id_ID');
  Address? _selectedAddress;
  String? _selectedCourier;
  int _ongkir = 0;
  String? _selectedPayment;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final auth = context.read<AuthProvider>();
    final address = await auth.service.getPrimaryAddress();
    final addresses = await auth.service.getAddresses();
    if (mounted) {
      setState(() {
        _selectedAddress = address ?? (addresses.isNotEmpty ? addresses.first : null);
      });
    }
  }

  void _showAddressPicker() async {
    final auth = context.read<AuthProvider>();
    final addresses = await auth.service.getAddresses();
    if (!mounted) return;

    final result = await showModalBottomSheet<Address>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: Text('Pilih Alamat', style: AppText.title(size: 16))),
                    GestureDetector(
                      onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/address-list').then((_) => _loadAddress()); },
                      child: Text('Kelola', style: AppText.caption(size: 12, color: AppColors.brand, weight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (addresses.isEmpty)
                const Padding(padding: EdgeInsets.all(32), child: Text('Belum ada alamat'))
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final addr = addresses[index];
                      return ListTile(
                        leading: Icon(addr.isPrimary ? Icons.check_circle : Icons.circle_outlined, color: AppColors.brand),
                        title: Text(addr.label, style: AppText.body(size: 14, weight: FontWeight.w600)),
                        subtitle: Text('${addr.recipientName} • ${addr.recipientPhone}\n${addr.fullAddress}, ${addr.city} ${addr.postalCode}', style: AppText.caption(size: 11, color: AppColors.textMuted)),
                        onTap: () => Navigator.pop(context, addr),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (result != null) setState(() => _selectedAddress = result);
  }

  void _showCourierPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text('Pilih Kurir', style: AppText.title(size: 16)))),
              const SizedBox(height: 8),
              ...AppConstants.courierServices.map((service) {
                return ListTile(
                  title: Text(service, style: AppText.body(size: 14)),
                  trailing: Text('Rp ${_formatter.format(AppConstants.ongkirFlat[service]!)}', style: AppText.body(size: 13, weight: FontWeight.w600)),
                  selected: _selectedCourier == service,
                  selectedTileColor: AppColors.brand.withValues(alpha: 0.05),
                  onTap: () {
                    setState(() {
                      _selectedCourier = service;
                      _ongkir = AppConstants.ongkirFlat[service]!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Align(alignment: Alignment.centerLeft, child: Text('Pilih Pembayaran', style: AppText.title(size: 16)))),
              const SizedBox(height: 8),
              ...AppConstants.paymentMethods.map((method) {
                return ListTile(
                  leading: Icon(
                    method.contains('Bank') ? Icons.account_balance_outlined : Icons.account_balance_wallet_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  title: Text(method, style: AppText.body(size: 14)),
                  trailing: _selectedPayment == method ? const Icon(Icons.check, color: AppColors.brand) : null,
                  onTap: () {
                    setState(() => _selectedPayment = method);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) return _snack('Pilih alamat dulu');
    if (_selectedCourier == null) return _snack('Pilih kurir dulu');
    if (_selectedPayment == null) return _snack('Pilih pembayaran dulu');

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.products;
    final orderProvider = context.read<OrderProvider>();

    if (auth.currentUser == null) return;

    await orderProvider.createOrder(
      userId: auth.currentUser!.id!,
      addressId: _selectedAddress!.id!,
      ongkir: _ongkir,
      cartItems: cart.items,
      products: products,
      courier: _selectedCourier!,
      paymentMethod: _selectedPayment!,
      voucherDiscount: cart.voucherDiscount,
    );

    // Refresh the product cache so the UI reflects the decreased stock
    // and increased sold_count. Without this, the product list/detail
    // pages still show the old stock from the in-memory cache.
    await productProvider.loadProducts();

    await cart.clearCart();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.sale));

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.read<ProductProvider>().products;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader('Checkout'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                children: [
                  _section('Alamat Pengiriman', _buildAddressSection()),
                  const SizedBox(height: 12),
                  _section('Pesanan', _buildOrderItems(cart, products)),
                  const SizedBox(height: 12),
                  _section('Kurir', _buildCourierSection()),
                  const SizedBox(height: 12),
                  _section('Pembayaran', _buildPaymentSection()),
                  const SizedBox(height: 12),
                  _section('Ringkasan', _buildOrderSummary(cart)),
                ],
              ),
            ),
            _buildBottomBar(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
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
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppText.display(size: 20))),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(title, style: AppText.title(size: 14)),
        ),
        child,
      ],
    );
  }

  Widget _buildAddressSection() {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      onTap: _showAddressPicker,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.brand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedAddress != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedAddress!.label, style: AppText.body(size: 13, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${_selectedAddress!.recipientName} • ${_selectedAddress!.recipientPhone}', style: AppText.caption(size: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text('${_selectedAddress!.fullAddress}, ${_selectedAddress!.city} ${_selectedAddress!.postalCode}', style: AppText.caption(size: 11, color: AppColors.textSecondary)),
                    ],
                  )
                : Text('Pilih alamat', style: AppText.body(size: 13, color: AppColors.textMuted)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildOrderItems(CartProvider cart, List<Product> products) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: cart.items.map<Widget>((item) {
          final product = products.firstWhereOrNull((p) => p.id == item.productId);
          if (product == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text('${item.qty}× ', style: AppText.body(size: 13, weight: FontWeight.w600)),
                Expanded(child: Text(product.name, style: AppText.body(size: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text('Rp ${_formatter.format(product.effectivePrice * item.qty)}', style: AppText.body(size: 13, weight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourierSection() {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      onTap: _showCourierPicker,
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedCourier != null
                ? Row(
                    children: [
                      Expanded(child: Text(_selectedCourier!, style: AppText.body(size: 13, weight: FontWeight.w500))),
                      Text('Rp ${_formatter.format(_ongkir)}', style: AppText.body(size: 13, weight: FontWeight.w600, color: AppColors.brand)),
                    ],
                  )
                : Text('Pilih kurir', style: AppText.body(size: 13, color: AppColors.textMuted)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      onTap: _showPaymentPicker,
      child: Row(
        children: [
          const Icon(Icons.payment_outlined, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedPayment != null
                ? Text(_selectedPayment!, style: AppText.body(size: 13, weight: FontWeight.w500))
                : Text('Pilih metode', style: AppText.body(size: 13, color: AppColors.textMuted)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row('Subtotal', 'Rp ${_formatter.format(cart.subtotal)}'),
          _row('Ongkir', _selectedCourier != null ? 'Rp ${_formatter.format(_ongkir)}' : '-'),
          if (cart.voucherDiscount > 0) _row('Diskon', '-Rp ${_formatter.format(cart.voucherDiscount)}', valueColor: AppColors.sale),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
          _row('Total', 'Rp ${_formatter.format(cart.total + _ongkir)}', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(size: 13, color: AppColors.textSecondary)),
          Text(value, style: AppText.body(
            size: bold ? 15 : 13,
            weight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.divider))),
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
                  Text('Rp ${_formatter.format(cart.total + _ongkir)}', style: AppText.title(size: 18, weight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48, width: 140,
              child: ElevatedButton(
                onPressed: _placeOrder,
                child: Text('Buat Pesanan', style: AppText.button(size: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
