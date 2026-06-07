import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Pesanan'),
              Expanded(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum login',
                  description: 'Login untuk melihat pesanan',
                  actionLabel: 'Login',
                  onAction: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders(auth.currentUser!.id!);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Pesanan'),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                tabs: const [Tab(text: 'Aktif'), Tab(text: 'Selesai'), Tab(text: 'Semua')],
              ),
            ),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  if (orderProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(orderProvider.activeOrders),
                      _buildOrderList(orderProvider.completedOrders),
                      _buildOrderList(orderProvider.orders),
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

  Widget _buildOrderList(List<dynamic> orders) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada pesanan',
        description: 'Pesananmu akan muncul di sini',
        actionLabel: 'Mulai Belanja',
        onAction: () => Navigator.pushNamed(context, '/main'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: orders.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildOrderCard(orders[index]),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final color = _statusColor(order.status);

    return DarkCard(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: {'orderId': order.id}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id}', style: AppText.body(size: 13, weight: FontWeight.w600)),
              StatusBadge(label: order.statusLabel, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text('Rp ${formatter.format(order.total)}', style: AppText.title(size: 18, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(order.createdAt)),
            style: AppText.caption(size: 11, color: AppColors.textMuted),
          ),
          if (order.status == 'menunggu_pembayaran') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => _showPayDialog(order),
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text('Bayar Sekarang', style: AppText.button(size: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPayDialog(dynamic order) {
    final formatter = NumberFormat('#,###', 'id_ID');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi Pembayaran', style: AppText.title(size: 16)),
        content: Text('Bayar pesanan #${order.id} sebesar Rp ${formatter.format(order.total)}?', style: AppText.body(size: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OrderProvider>().payOrder(order.id, order.userId);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(content: Text('Pembayaran berhasil!')),
              );
            },
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }
}
