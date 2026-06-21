import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/address.dart';
import '../../models/user.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminOrderDetailPage extends StatefulWidget {
  const AdminOrderDetailPage({super.key});

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  Order? _order;
  List<OrderItem> _items = [];
  Address? _address;
  User? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as int?;
    if (orderId == null) return;

    final admin = context.read<AdminProvider>();
    final authService = context.read<AuthProvider>().service;

    // Ensure orders are loaded; if not, fetch them.
    if (admin.allOrders.isEmpty) {
      await admin.loadAllOrders();
    }

    final order = admin.allOrders.where((o) => o.id == orderId).firstOrNull;
    if (order == null || !mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final items = await admin.getOrderItems(orderId);
    final address = await authService.getAddressById(order.addressId);
    final customer = admin.userMap[order.userId] ?? await authService.getUserById(order.userId);

    if (!mounted) return;
    setState(() {
      _order = order;
      _items = items;
      _address = address;
      _customer = customer;
      _isLoading = false;
    });
  }

  Future<void> _confirmPayment() async {
    if (_order == null) return;
    await context.read<AdminProvider>().updateOrderStatus(
      _order!.id!,
      'diproses',
      paidAt: DateTime.now().toIso8601String(),
    );
    await _load();
  }

  Future<void> _shipOrder() async {
    if (_order == null) return;
    final resi = await _showResiDialog();
    if (resi == null || resi.isEmpty || !mounted) return;
    await context.read<AdminProvider>().updateOrderStatus(
      _order!.id!,
      'dikirim',
      trackingNumber: resi,
    );
    await _load();
  }

  Future<void> _completeOrder() async {
    if (_order == null) return;
    await context.read<AdminProvider>().updateOrderStatus(_order!.id!, 'selesai');
    await _load();
  }

  Future<void> _cancelOrder() async {
    if (_order == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Batalkan order?', style: AppText.title(size: 16)),
        content: Text('Stok produk akan dikembalikan.', style: AppText.body(size: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AdminProvider>().cancelOrder(_order!.id!);
      await _load();
    }
  }

  Future<String?> _showResiDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Input Nomor Resi', style: AppText.title(size: 16)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nomor Resi',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
            : _order == null
                ? Column(
                    children: [
                      const PageHeader(title: 'Detail Order', showBackButton: true),
                      const Expanded(child: Center(child: Text('Order tidak ditemukan'))),
                    ],
                  )
                : Column(
                    children: [
                      PageHeader(title: 'Order #${_order!.id}', showBackButton: true),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 12),
                            _buildInfoCard('Customer', [
                              _infoRow('Nama', _customer?.name ?? 'User #${_order!.userId}'),
                              _infoRow('Email', _customer?.email ?? '-'),
                            ]),
                            const SizedBox(height: 12),
                            _buildInfoCard('Alamat Pengiriman', [
                              _infoRow('Label', _address?.label ?? '-'),
                              _infoRow('Penerima', '${_address?.recipientName ?? '-'} • ${_address?.recipientPhone ?? '-'}'),
                              _infoRow('Alamat', '${_address?.fullAddress ?? '-'}, ${_address?.city ?? '-'} ${_address?.postalCode ?? ''}'),
                            ]),
                            const SizedBox(height: 12),
                            _buildInfoCard('Detail Pengiriman', [
                              _infoRow('Kurir', _order!.courier ?? '-'),
                              _infoRow('No. Resi', _order!.trackingNumber ?? '-'),
                              _infoRow('Metode Bayar', _order!.paymentMethod ?? '-'),
                            ]),
                            const SizedBox(height: 12),
                            _buildItemsCard(formatter),
                            const SizedBox(height: 12),
                            _buildSummaryCard(formatter, dateFormatter),
                            const SizedBox(height: 24),
                            _buildActions(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color color;
    switch (_order!.status) {
      case 'menunggu_pembayaran':
        color = AppColors.warning;
        break;
      case 'diproses':
        color = AppColors.brand;
        break;
      case 'dikirim':
        color = AppColors.info;
        break;
      case 'selesai':
        color = AppColors.success;
        break;
      case 'dibatalkan':
        color = AppColors.sale;
        break;
      default:
        color = AppColors.textMuted;
    }

    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status', style: AppText.caption(size: 11, color: AppColors.textSecondary)),
                Text(_order!.statusLabel, style: AppText.body(size: 15, weight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.title(size: 14)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: AppText.caption(size: 11, color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: AppText.body(size: 13))),
        ],
      ),
    );
  }

  Widget _buildItemsCard(NumberFormat formatter) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Item Pesanan', style: AppText.title(size: 14)),
          const SizedBox(height: 10),
          ..._items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('${item.qty}×', style: AppText.body(size: 13, weight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.productName, style: AppText.body(size: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Text('Rp ${formatter.format(item.subtotal)}', style: AppText.body(size: 13, weight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat formatter, DateFormat dateFormatter) {
    final date = DateTime.tryParse(_order!.createdAt);

    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan', style: AppText.title(size: 14)),
          const SizedBox(height: 10),
          _summaryRow('Tanggal', date != null ? dateFormatter.format(date) : _order!.createdAt),
          _summaryRow('Subtotal', 'Rp ${formatter.format(_order!.subtotal)}'),
          _summaryRow('Ongkir', 'Rp ${formatter.format(_order!.ongkir)}'),
          if ((_order!.voucherDiscount ?? 0) > 0)
            _summaryRow('Diskon', '-Rp ${formatter.format(_order!.voucherDiscount)}', valueColor: AppColors.sale),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
          _summaryRow('Total', 'Rp ${formatter.format(_order!.total)}', bold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppText.body(size: 13, color: AppColors.textSecondary)),
          Text(value, style: AppText.body(size: 13, weight: bold ? FontWeight.w700 : FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final status = _order!.status;
    final canCancel = status != 'selesai' && status != 'dibatalkan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == 'menunggu_pembayaran')
          ElevatedButton(
            onPressed: _confirmPayment,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, minimumSize: const Size(double.infinity, 48)),
            child: const Text('Konfirmasi Pembayaran'),
          ),
        if (status == 'diproses')
          ElevatedButton(
            onPressed: _shipOrder,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, minimumSize: const Size(double.infinity, 48)),
            child: const Text('Kirim Paket + Input Resi'),
          ),
        if (status == 'dikirim')
          ElevatedButton(
            onPressed: _completeOrder,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(double.infinity, 48)),
            child: const Text('Tandai Selesai'),
          ),
        if (canCancel) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _cancelOrder,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.sale, side: const BorderSide(color: AppColors.sale), minimumSize: const Size(double.infinity, 48)),
            child: const Text('Batalkan Order'),
          ),
        ],
      ],
    );
  }
}
