import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_image.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return AppColors.warning;
      case 'diproses': return Colors.blue;
      case 'dikirim': return Colors.purple;
      case 'selesai': return AppColors.brand;
      case 'dibatalkan': return AppColors.sale;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] as int?;
    final orderProvider = context.read<OrderProvider>();
    final order = orderId != null ? orderProvider.getOrderById(orderId) : null;

    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Detail Pesanan', showBackButton: true),
              Expanded(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pesanan tidak ditemukan',
                  actionLabel: 'Kembali',
                  onAction: () => Navigator.maybePop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final formatter = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PageHeader(
              title: 'Pesanan #${order.id}',
              showBackButton: true,
            ),
            Expanded(
              child: FutureBuilder(
                future: orderProvider.getOrderItems(orderId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
                  }
                  final items = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    children: [
                      _buildStatusTracker(order),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'Status',
                        child: StatusBadge(label: order.statusLabel, color: _statusColor(order.status)),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        title: 'Item Pesanan',
                        child: Column(
                          children: items.map((item) {
                            final product = context.read<ProductProvider>().getProductById(item.productId);
                            final imageUrl = product?.images.isNotEmpty == true ? product!.images[0] : '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
                                    clipBehavior: Clip.antiAlias,
                                    child: AppImage(
                                      src: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: const Icon(Icons.image, color: AppColors.textMuted, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName, style: AppText.body(size: 13, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text('${item.qty} × Rp ${formatter.format(item.price)}', style: AppText.caption(size: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  Text('Rp ${formatter.format(item.subtotal)}', style: AppText.body(size: 13, weight: FontWeight.w700)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        title: 'Pembayaran',
                        child: Column(
                          children: [
                            _row('Subtotal', 'Rp ${formatter.format(order.subtotal)}'),
                            _row('Ongkir', 'Rp ${formatter.format(order.ongkir)}'),
                            if ((order.voucherDiscount ?? 0) > 0)
                              _row('Diskon', '-Rp ${formatter.format(order.voucherDiscount)}', valueColor: AppColors.sale),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: AppColors.divider)),
                            _row('Total', 'Rp ${formatter.format(order.total)}', bold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        title: 'Pengiriman',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _row('Kurir', order.courier ?? '-'),
                            if (order.trackingNumber != null) _row('No Resi', order.trackingNumber!),
                            _row('Metode', order.paymentMethod ?? '-'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        title: 'Tanggal',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _row('Dibuat', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order.createdAt))),
                            if (order.paidAt != null) _row('Dibayar', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order.paidAt!))),
                          ],
                        ),
                      ),
                      if (order.status == 'menunggu_pembayaran') ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  onPressed: () => _showCancelDialog(order),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.sale, side: const BorderSide(color: AppColors.sale)),
                                  child: Text('Batalkan', style: AppText.button(size: 13, color: AppColors.sale)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => _showPayDialog(order),
                                  child: const Text('Bayar Sekarang'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (order.status == 'dikirim') ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => _showConfirmReceivedDialog(order),
                            child: const Text('Konfirmasi Diterima'),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTracker(dynamic order) {
    final steps = ['Bayar', 'Proses', 'Kirim', 'Selesai'];
    final statuses = ['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai'];
    int currentStep = order.status == 'dibatalkan' ? -1 : statuses.indexOf(order.status);
    final isCancelled = order.status == 'dibatalkan';

    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep && !isCancelled;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isCancelled ? AppColors.sale.withValues(alpha: 0.1) : (isCompleted ? AppColors.brand : AppColors.surfaceAlt),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCancelled ? Icons.close : (isCompleted ? Icons.check : null),
                        color: isCompleted ? Colors.white : AppColors.textMuted,
                        size: 14,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: isCompleted && index < currentStep ? AppColors.brand : AppColors.surfaceAlt,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final isActive = i == currentStep;
              return SizedBox(
                width: 60,
                child: Text(steps[i], textAlign: TextAlign.center, style: AppText.caption(size: 10, color: isActive ? AppColors.textPrimary : AppColors.textMuted, weight: isActive ? FontWeight.w600 : FontWeight.w500)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.title(size: 14)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  void _showPayDialog(dynamic order) {
    final formatter = NumberFormat('#,###', 'id_ID');
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Konfirmasi Pembayaran', style: AppText.title(size: 16)),
      content: Text('Bayar pesanan ini sebesar Rp ${formatter.format(order.total)}?', style: AppText.body(size: 13, color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); context.read<OrderProvider>().payOrder(order.id!, order.userId); },
          child: const Text('Bayar'),
        ),
      ],
    ));
  }

  void _showCancelDialog(dynamic order) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Batalkan Pesanan', style: AppText.title(size: 16)),
      content: Text('Yakin ingin membatalkan pesanan ini?', style: AppText.body(size: 13, color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Tidak', style: AppText.body(size: 13, color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); context.read<OrderProvider>().cancelOrder(order.id!, order.userId); Navigator.pop(this.context); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
          child: const Text('Ya, Batalkan'),
        ),
      ],
    ));
  }

  void _showConfirmReceivedDialog(dynamic order) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Konfirmasi Diterima', style: AppText.title(size: 16)),
      content: Text('Apakah pesanan sudah kamu terima?', style: AppText.body(size: 13, color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Belum', style: AppText.body(size: 13, color: AppColors.textSecondary))),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<OrderProvider>().confirmReceived(order.id!, order.userId);
            ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Pesanan selesai!')));
          },
          child: const Text('Ya, Diterima'),
        ),
      ],
    ));
  }
}
