import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../providers/admin_provider.dart';
import '../../models/order.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminOrderListPage extends StatefulWidget {
  const AdminOrderListPage({super.key});

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  String _filterStatus = 'semua';
  String _searchQuery = '';

  final _statusFilters = [
    ('semua', 'Semua'),
    ('menunggu_pembayaran', 'Menunggu'),
    ('diproses', 'Diproses'),
    ('dikirim', 'Dikirim'),
    ('selesai', 'Selesai'),
    ('dibatalkan', 'Batal'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final formatter = NumberFormat('#,###', 'id_ID');
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    final filtered = admin.allOrders.where((order) {
      final statusMatch = _filterStatus == 'semua' || order.status == _filterStatus;
      final user = admin.userMap[order.userId];
      final query = _searchQuery.toLowerCase();
      final searchMatch = query.isEmpty ||
          order.id.toString().contains(query) ||
          (user?.name.toLowerCase().contains(query) ?? false) ||
          (user?.email.toLowerCase().contains(query) ?? false);
      return statusMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Manajemen Order', showBackButton: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari ID order atau nama/email customer',
                  hintStyle: AppText.caption(size: 12, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: AppText.body(size: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _statusFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final (value, label) = _statusFilters[index];
                  final selected = _filterStatus == value;
                  return ChoiceChip(
                    label: Text(label, style: AppText.caption(size: 11, color: selected ? Colors.white : AppColors.textPrimary, weight: FontWeight.w600)),
                    selected: selected,
                    selectedColor: AppColors.brand,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: selected ? AppColors.brand : AppColors.border)),
                    onSelected: (_) => setState(() => _filterStatus = value),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: admin.isLoading && admin.allOrders.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                  : filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Tidak ada order',
                          description: 'Belum ada order yang cocok dengan filter',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final order = filtered[index];
                            final user = admin.userMap[order.userId];
                            return _OrderCard(
                              order: order,
                              customerName: user?.name ?? 'User #${order.userId}',
                              formatter: formatter,
                              dateFormatter: dateFormatter,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminOrderDetail,
                                arguments: {'orderId': order.id},
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final String customerName;
  final NumberFormat formatter;
  final DateFormat dateFormatter;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.customerName,
    required this.formatter,
    required this.dateFormatter,
    required this.onTap,
  });

  Color get _statusColor {
    switch (order.status) {
      case 'menunggu_pembayaran':
        return AppColors.warning;
      case 'diproses':
        return AppColors.brand;
      case 'dikirim':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      case 'dibatalkan':
        return AppColors.sale;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(order.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order #${order.id}', style: AppText.body(size: 14, weight: FontWeight.w700)),
                const Spacer(),
                StatusBadge(label: order.statusLabel, color: _statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(customerName, style: AppText.body(size: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(date != null ? dateFormatter.format(date) : order.createdAt, style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Text('Rp ${formatter.format(order.total)}', style: AppText.body(size: 14, weight: FontWeight.w700, color: AppColors.brand)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
