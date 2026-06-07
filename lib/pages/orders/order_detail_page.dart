import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../config/app_theme.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final orderId = args['orderId'] as int;
    final orderProvider = context.read<OrderProvider>();
    final order = orderProvider.getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    final formatter = NumberFormat('#,###', 'id_ID');

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: FutureBuilder(
        future: orderProvider.getOrderItems(orderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusTracker(order),
                const SizedBox(height: 20),
                _buildSection('Status Pesanan',
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(order.statusLabel, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection('Item Pesanan',
                  Column(
                    children: items.map((item) {
                      final product = context.read<ProductProvider>().getProductById(item.productId);
                      final imageUrl = product?.images.isNotEmpty == true ? product!.images[0] : '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('${item.qty}x Rp ${formatter.format(item.price)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            Text('Rp ${formatter.format(item.subtotal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection('Rincian Pembayaran',
                  Column(
                    children: [
                      _buildDetailRow('Subtotal', 'Rp ${formatter.format(order.subtotal)}'),
                      _buildDetailRow('Ongkos Kirim', 'Rp ${formatter.format(order.ongkir)}'),
                      if ((order.voucherDiscount ?? 0) > 0)
                        _buildDetailRow('Diskon Voucher', '-Rp ${formatter.format(order.voucherDiscount)}', valueColor: Colors.red),
                      const Divider(),
                      _buildDetailRow('Total', 'Rp ${formatter.format(order.total)}', bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection('Info Pengiriman',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Kurir', order.courier ?? '-'),
                      if (order.trackingNumber != null)
                        _buildDetailRow('No Resi', order.trackingNumber!),
                      _buildDetailRow('Metode Pembayaran', order.paymentMethod ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection('Tanggal',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Dibuat', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order.createdAt))),
                      if (order.paidAt != null)
                        _buildDetailRow('Dibayar', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order.paidAt!))),
                    ],
                  ),
                ),
                if (order.status == 'menunggu_pembayaran') ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Batalkan Pesanan'),
                                content: const Text('Yakin ingin membatalkan pesanan ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tidak'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      orderProvider.cancelOrder(order.id!, order.userId);
                                      Navigator.pop(this.context);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Ya, Batalkan'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text('Batalkan Pesanan'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Konfirmasi Pembayaran'),
                                content: Text('Bayar pesanan ini sebesar Rp ${formatter.format(order.total)}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      orderProvider.payOrder(order.id!, order.userId);
                                    },
                                    child: const Text('Bayar Sekarang'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Bayar Sekarang'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (order.status == 'dikirim') ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Diterima'),
                            content: const Text('Apakah pesanan sudah kamu terima?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Belum'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  orderProvider.confirmReceived(order.id!, order.userId);
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('Pesanan selesai!'), backgroundColor: AppTheme.primaryGreen),
                                  );
                                },
                                child: const Text('Ya, Sudah Diterima'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Konfirmasi Diterima'),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu_pembayaran': return Colors.orange;
      case 'diproses': return Colors.blue;
      case 'dikirim': return Colors.purple;
      case 'selesai': return AppTheme.primaryGreen;
      case 'dibatalkan': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusTracker(dynamic order) {
    final steps = ['Menunggu\nPembayaran', 'Diproses', 'Dikirim', 'Selesai'];
    final statuses = ['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai'];

    int currentStep;
    if (order.status == 'dibatalkan') {
      currentStep = -1;
    } else {
      currentStep = statuses.indexOf(order.status);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep && currentStep >= 0;
              final isCancelled = order.status == 'dibatalkan';
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isCancelled ? Colors.red : (isCompleted ? AppTheme.primaryGreen : Colors.grey[200]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCancelled ? Icons.close : (isCompleted ? Icons.check : null),
                        color: Colors.white, size: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[index], textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 10,
                      color: isCancelled ? Colors.red : (isCompleted ? AppTheme.primaryGreen : Colors.grey),
                      fontWeight: isCompleted || isCancelled ? FontWeight.bold : FontWeight.normal,
                    )),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(value, style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
            fontSize: 14,
          )),
        ],
      ),
    );
  }
}
