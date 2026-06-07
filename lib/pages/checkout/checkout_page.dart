import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/address.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';

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

  Future<void> _showAddressPicker() async {
    final auth = context.read<AuthProvider>();
    final addresses = await auth.service.getAddresses();

    if (!mounted) return;

    final result = await showModalBottomSheet<Address>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Pilih Alamat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              if (addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Belum ada alamat. Tambahkan dulu ya.'),
                )
              else
                LimitedBox(
                  maxHeight: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final addr = addresses[index];
                      return ListTile(
                        leading: Icon(addr.isPrimary ? Icons.check_circle : Icons.circle_outlined, color: AppTheme.primaryGreen),
                        title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${addr.recipientName} - ${addr.recipientPhone}\n${addr.fullAddress}, ${addr.subdistrict}, ${addr.city} ${addr.postalCode}'),
                        onTap: () => Navigator.pop(context, addr),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/address-list').then((_) => _loadAddress());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Alamat Baru'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _selectedAddress = result);
    }
  }

  void _showCourierPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Pilih Kurir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ...AppConstants.courierServices.map((service) {
                return ListTile(
                  title: Text(service),
                  trailing: Text('Rp ${_formatter.format(AppConstants.ongkirFlat[service]!)}'),
                  selected: _selectedCourier == service,
                  onTap: () {
                    setState(() {
                      _selectedCourier = service;
                      _ongkir = AppConstants.ongkirFlat[service]!;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Pilih Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              ...AppConstants.paymentMethods.map((method) {
                return ListTile(
                  leading: Icon(
                    method.contains('Bank') ? Icons.account_balance : Icons.account_balance_wallet,
                    color: AppTheme.primaryGreen,
                  ),
                  title: Text(method),
                  selected: _selectedPayment == method,
                  trailing: _selectedPayment == method ? const Icon(Icons.check, color: AppTheme.primaryGreen) : null,
                  onTap: () {
                    setState(() => _selectedPayment = method);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedCourier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kurir pengiriman terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final products = context.read<ProductProvider>().products;
    final orderProvider = context.read<OrderProvider>();

    if (!auth.isLoggedIn || auth.currentUser == null) return;

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

    await cart.clearCart();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: AppTheme.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.read<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 16),
                  _buildOrderItems(cart, products),
                  const SizedBox(height: 16),
                  _buildCourierSection(),
                  const SizedBox(height: 16),
                  _buildPaymentSection(),
                  const SizedBox(height: 16),
                  _buildOrderSummary(cart),
                ],
              ),
            ),
          ),
          _buildBottomBar(cart),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return GestureDetector(
      onTap: _showAddressPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedAddress != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedAddress!.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_selectedAddress!.recipientName} - ${_selectedAddress!.recipientPhone}'),
                        Text('${_selectedAddress!.fullAddress}, ${_selectedAddress!.subdistrict}, ${_selectedAddress!.city} ${_selectedAddress!.postalCode}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    )
                  : const Text('Pilih alamat pengiriman'),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(dynamic cart, List<dynamic> products) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...cart.items.map((item) {
            final product = products.firstWhere(
              (p) => p.id == item.productId,
              orElse: () => null,
            );
            if (product == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('${item.qty}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(product.name, style: const TextStyle(fontSize: 14))),
                  Text('Rp ${_formatter.format(product.effectivePrice * item.qty)}'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCourierSection() {
    return GestureDetector(
      onTap: _showCourierPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedCourier != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedCourier!, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Rp ${_formatter.format(_ongkir)}', style: const TextStyle(color: AppTheme.primaryGreen)),
                      ],
                    )
                  : const Text('Pilih kurir pengiriman'),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return GestureDetector(
      onTap: _showPaymentPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedPayment != null
                  ? Text(_selectedPayment!, style: const TextStyle(fontWeight: FontWeight.w600))
                  : const Text('Pilih metode pembayaran'),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(dynamic cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal Produk', 'Rp ${_formatter.format(cart.subtotal)}'),
          _buildSummaryRow('Ongkos Kirim', _selectedCourier != null ? 'Rp ${_formatter.format(_ongkir)}' : '-'),
          if (cart.voucherDiscount > 0)
            _buildSummaryRow('Diskon Voucher', '-Rp ${_formatter.format(cart.voucherDiscount)}', isDiscount: true),
          const Divider(),
          _buildSummaryRow('Total', 'Rp ${_formatter.format(cart.total + _ongkir)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? Colors.red : (isBold ? AppTheme.primaryGreen : null),
            fontSize: isBold ? 16 : 14,
          )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(dynamic cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text('Rp ${_formatter.format(cart.total + _ongkir)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  child: const Text('Buat Pesanan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
