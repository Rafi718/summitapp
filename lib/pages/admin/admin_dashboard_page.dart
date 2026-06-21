import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/admin_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      admin.loadDashboard();
      if (admin.allOrders.isEmpty) admin.loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final formatter = NumberFormat('#,###', 'id_ID');
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
    final metrics = admin.metrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Admin Panel', showBackButton: true),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (metrics != null) ...[
                    _sectionLabel('Ringkasan Bisnis'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.45,
                      children: [
                        _MetricCard(
                          label: 'Profit Hari Ini',
                          value: currency.format(metrics.todayProfit),
                          icon: Icons.today,
                          color: AppColors.success,
                        ),
                        _MetricCard(
                          label: 'Revenue Hari Ini',
                          value: currency.format(metrics.todayRevenue),
                          icon: Icons.payments_outlined,
                          color: AppColors.brand,
                        ),
                        _MetricCard(
                          label: 'Profit Bulan Ini',
                          value: currency.format(metrics.monthlyProfit),
                          icon: Icons.trending_up,
                          color: AppColors.success,
                        ),
                        _MetricCard(
                          label: 'Revenue Bulan Ini',
                          value: currency.format(metrics.monthlyRevenue),
                          icon: Icons.calendar_today,
                          color: AppColors.brand,
                        ),
                        _MetricCard(
                          label: 'Total Profit',
                          value: currency.format(metrics.totalProfit),
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.success,
                        ),
                        _MetricCard(
                          label: 'Total Revenue',
                          value: currency.format(metrics.totalRevenue),
                          icon: Icons.payments_outlined,
                          color: AppColors.brand,
                        ),
                        _MetricCard(
                          label: 'Total Order',
                          value: '${metrics.totalOrders}',
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.info,
                        ),
                        _MetricCard(
                          label: 'Order Aktif',
                          value: '${metrics.activeOrders}',
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _MetricCard(
                      label: 'Produk Terjual (lifetime)',
                      value: '${metrics.productsSold} item',
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary,
                      compact: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (admin.isLoading && metrics == null)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.brand))),
                  _sectionLabel('Menu Admin'),
                  const SizedBox(height: 12),
                  _AdminCard(
                    icon: Icons.analytics_outlined,
                    title: 'Laporan Penjualan & Profit',
                    subtitle: 'Lihat revenue, profit, margin, grafik tren per hari',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminSalesReport),
                  ),
                  const SizedBox(height: 16),
                  _AdminCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Manajemen Order',
                    subtitle: 'Lihat semua order, update status & input resi',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
                  ),
                  const SizedBox(height: 16),
                  _AdminCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Kelola Produk',
                    subtitle: 'Tambah, edit, atau hapus produk',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminProducts),
                  ),
                  const SizedBox(height: 16),
                  _AdminCard(
                    icon: Icons.category_outlined,
                    title: 'Kelola Kategori',
                    subtitle: 'Atur kategori produk',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.adminCategories),
                  ),
                  const SizedBox(height: 24),
                  _buildRecentOrders(admin, formatter, dateFormatter),
                  const SizedBox(height: 24),
                  _buildTopProducts(admin),
                  const SizedBox(height: 24),
                  _buildLowStock(admin),
                  const SizedBox(height: 24),
                  const _SectionLabel('Zona Berbahaya'),
                  const SizedBox(height: 12),
                  _AdminCard(
                    icon: Icons.restart_alt,
                    title: 'Reset Data ke Default',
                    subtitle: 'Hapus semua produk, kategori, voucher & pesanan, lalu isi ulang dari seed',
                    destructive: true,
                    onTap: () => _confirmReset(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(AdminProvider admin, NumberFormat formatter, DateFormat dateFormatter) {
    final recent = admin.allOrders.take(5).toList();
    if (recent.isEmpty && !admin.isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabelInline('Order Terbaru'),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
              child: Text('Lihat semua', style: AppText.caption(size: 11, color: AppColors.brand, weight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...recent.map((order) {
          final user = admin.userMap[order.userId];
          final date = DateTime.tryParse(order.createdAt);
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrderDetail, arguments: {'orderId': order.id}),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order #${order.id}', style: AppText.body(size: 13, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(user?.name ?? 'User #${order.userId}', style: AppText.caption(size: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rp ${formatter.format(order.total)}', style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.brand)),
                      Text(date != null ? dateFormatter.format(date) : '', style: AppText.caption(size: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTopProducts(AdminProvider admin) {
    if (admin.topProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabelInline('Produk Terlaris'),
        const SizedBox(height: 10),
        ...admin.topProducts.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final p = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('$index', style: AppText.body(size: 12, weight: FontWeight.w700, color: AppColors.brand)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(p.productName, style: AppText.body(size: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Text('${p.totalQty} terjual', style: AppText.caption(size: 11, color: AppColors.textSecondary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLowStock(AdminProvider admin) {
    if (admin.lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabelInline('Stok Menipis (< 10)'),
        const SizedBox(height: 10),
        ...admin.lowStockProducts.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Expanded(child: Text(p.name, style: AppText.body(size: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.sale.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('Stok ${p.stock}', style: AppText.caption(size: 11, color: AppColors.sale, weight: FontWeight.w700)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return _SectionLabel(text);
  }

  Widget _sectionLabelInline(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: AppText.label(size: 10, color: AppColors.brand, letterSpacing: 0.8)),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset semua data?', style: AppText.title(size: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tindakan ini akan menghapus:', style: AppText.body(size: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ..._resetBullets.map((b) => Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text('• $b', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
                )),
            const SizedBox(height: 12),
            Text('Akun user tetap aman. Data akan diisi ulang dari seed.', style: AppText.caption(size: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppText.body(size: 13, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sale),
            child: const Text('Reset Sekarang'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final authService = context.read<AuthProvider>().service;
    final productProvider = context.read<ProductProvider>();
    final adminProvider = context.read<AdminProvider>();
    if (!context.mounted) return;

    try {
      await authService.resetSeed();
      await productProvider.loadProducts();
      await adminProvider.loadDashboard();
      await adminProvider.loadAllOrders();
      messenger.showSnackBar(
        const SnackBar(content: Text('Data berhasil direset ke default'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Reset gagal: $e'), backgroundColor: AppColors.sale),
      );
    }
  }

  static const _resetBullets = [
    'Semua produk',
    'Semua kategori',
    'Semua voucher',
    'Semua pesanan & riwayat',
    'Keranjang & wishlist',
  ];
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool compact;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppText.caption(size: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppText.body(size: compact ? 15 : 14, weight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.sale.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: AppText.label(size: 10, color: AppColors.sale, letterSpacing: 0.8)),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Divider(color: AppColors.divider, height: 1),
          ),
        ),
      ],
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.sale : AppColors.brand;
    final iconBg = destructive ? AppColors.sale.withValues(alpha: 0.08) : AppColors.brand.withValues(alpha: 0.08);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: destructive ? AppColors.sale.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 88,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title(size: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppText.caption(size: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
