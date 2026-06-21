import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../home/alpine_theme.dart';
import '../home/widgets/shared_widgets.dart';

/// Preset date ranges the owner can quickly switch between.
enum RangePreset { hariIni, mingguIni, bulanIni, tahunIni, custom }

class AdminSalesReportPage extends StatefulWidget {
  const AdminSalesReportPage({super.key});

  @override
  State<AdminSalesReportPage> createState() => _AdminSalesReportPageState();
}

class _AdminSalesReportPageState extends State<AdminSalesReportPage> {
  RangePreset _preset = RangePreset.bulanIni;
  DateTime _start = DateTime.now().subtract(const Duration(days: 29));
  DateTime _end = DateTime.now();
  SalesReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _applyPreset(RangePreset.bulanIni);
  }

  void _applyPreset(RangePreset preset) {
    final now = DateTime.now();
    setState(() {
      _preset = preset;
      switch (preset) {
        case RangePreset.hariIni:
          _start = DateTime(now.year, now.month, now.day);
          _end = now;
          break;
        case RangePreset.mingguIni:
          // Week starts on Sunday (Minggu) per Indonesian calendar convention.
          // Dart's weekday: Mon=1..Sun=7. Sunday (7) % 7 = 0 → start = today;
          // Monday (1) % 7 = 1 → start = yesterday (Sunday), etc.
          _start = now.subtract(Duration(days: now.weekday % 7));
          _start = DateTime(_start.year, _start.month, _start.day);
          _end = now;
          break;
        case RangePreset.bulanIni:
          _start = DateTime(now.year, now.month, 1);
          _end = now;
          break;
        case RangePreset.tahunIni:
          _start = DateTime(now.year, 1, 1);
          _end = now;
          break;
        case RangePreset.custom:
          // Keep existing _start/_end; user will pick via date picker.
          break;
      }
    });
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final admin = context.read<AdminProvider>();
    final report = await admin.loadSalesReport(_start, _end);
    if (!mounted) return;
    setState(() {
      _report = report;
      _isLoading = false;
    });
  }


  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
      _preset = RangePreset.custom;
    });
    _loadReport();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(title: 'Laporan Penjualan', showBackButton: true),
            _buildPresetChips(),
            if (_preset == RangePreset.custom) _buildCustomRangeBar(dateFormatter),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                  : _report == null
                      ? const Center(child: Text('Tidak ada data'))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          children: [
                            _buildSummaryCards(currency),
                            const SizedBox(height: 24),
                            _buildChartSection(currency),
                            const SizedBox(height: 24),
                            _buildDailyTable(currency, dateFormatter),
                            const SizedBox(height: 24),
                            _buildTopByProfit(currency),
                            const SizedBox(height: 24),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Preset filter chips
  // ---------------------------------------------------------------------------
  Widget _buildPresetChips() {
    final presets = [
      (RangePreset.hariIni, 'Hari Ini'),
      (RangePreset.mingguIni, 'Minggu Ini'),
      (RangePreset.bulanIni, 'Bulan Ini'),
      (RangePreset.tahunIni, 'Tahun Ini'),
      (RangePreset.custom, 'Custom'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: presets.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final (value, label) = presets[index];
            final selected = _preset == value;
            return ChoiceChip(
              label: Text(label, style: AppText.caption(size: 11, color: selected ? Colors.white : AppColors.textPrimary, weight: FontWeight.w600)),
              selected: selected,
              selectedColor: AppColors.brand,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: selected ? AppColors.brand : AppColors.border)),
              onSelected: (_) => _applyPreset(value),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomRangeBar(DateFormat dateFormatter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(child: _dateButton('Dari', _start, () => _pickDate(true))),
          const SizedBox(width: 8),
          Expanded(child: _dateButton('Sampai', _end, () => _pickDate(false))),
        ],
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, VoidCallback onTap) {
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Text(label, style: AppText.caption(size: 11, color: AppColors.textSecondary)),
            const SizedBox(width: 6),
            Expanded(child: Text(dateFormatter.format(date), style: AppText.body(size: 12, weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary cards
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCards(NumberFormat currency) {
    final r = _report!;
    final margin = r.marginPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Ringkasan'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            _SummaryCard(label: 'Total Revenue', value: currency.format(r.totalRevenue), icon: Icons.payments_outlined),
            _SummaryCard(label: 'Total Profit', value: currency.format(r.totalProfit), icon: Icons.trending_up),
            _SummaryCard(label: 'Total Cost (HPP)', value: currency.format(r.totalCost), icon: Icons.local_shipping_outlined),
            _SummaryCard(label: 'Avg Order Value', value: currency.format(r.aov), icon: Icons.shopping_cart_outlined),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _SummaryCard(label: 'Jumlah Order', value: '${r.totalOrders} order', icon: Icons.receipt_long_outlined, compact: true)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Item Terjual', value: '${r.totalItemsSold} item', icon: Icons.inventory_2_outlined, compact: true)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Margin', value: '$margin%', icon: Icons.percent, compact: true)),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Chart section — revenue & profit line chart
  // ---------------------------------------------------------------------------
  Widget _buildChartSection(NumberFormat currency) {
    final rows = _report!.dailyRows;
    if (rows.isEmpty || rows.every((r) => r.revenue == 0 && r.profit == 0)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Tren Penjualan'),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Center(child: Text('Belum ada transaksi di rentang ini', style: AppText.caption())),
          ),
        ],
      );
    }

    // Calculate max Y for chart scaling.
    double maxY = 0;
    for (final r in rows) {
      if (r.revenue > maxY) maxY = r.revenue.toDouble();
      if (r.profit > maxY) maxY = r.profit.toDouble();
    }
    maxY = maxY * 1.2; // 20% headroom.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Tren Penjualan'),
        const SizedBox(height: 8),
        Row(
          children: [
            _legendDot(AppColors.brand, 'Revenue'),
            const SizedBox(width: 12),
            _legendDot(AppColors.success, 'Profit'),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 240,
          padding: const EdgeInsets.only(right: 12, top: 12, bottom: 4),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                getDrawingHorizontalLine: (value) => FlLine(color: AppColors.divider, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _xLabelInterval(rows.length),
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= rows.length) return const SizedBox.shrink();
                      final date = DateTime.tryParse(rows[i].date);
                      if (date == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(DateFormat('dd/MM').format(date), style: AppText.caption(size: 9, color: AppColors.textMuted)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: maxY > 0 ? maxY / 4 : 1,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(_compactCurrency(value.toInt()), style: AppText.caption(size: 9, color: AppColors.textMuted));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxY == 0 ? 1 : maxY,
              lineBarsData: [
                _lineBarData(rows.map((r) => r.revenue.toDouble()).toList(), AppColors.brand),
                _lineBarData(rows.map((r) => r.profit.toDouble()).toList(), AppColors.success),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isRevenue = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isRevenue ? 'Revenue' : 'Profit'}\n${currency.format(spot.y.toInt())}',
                        AppText.caption(size: 10, color: isRevenue ? AppColors.brand : AppColors.success, weight: FontWeight.w700),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _xLabelInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 31) return 5;
    return 10;
  }

  String _compactCurrency(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).round()}rb';
    return '$value';
  }

  LineChartBarData _lineBarData(List<double> values, Color color) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppText.caption(size: 11, weight: FontWeight.w600)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Daily breakdown table
  // ---------------------------------------------------------------------------
  Widget _buildDailyTable(NumberFormat currency, DateFormat dateFormatter) {
    final rows = _report!.dailyRows;
    // Show in reverse chronological order (newest first).
    final displayRows = rows.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Detail per Hari'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text('Tanggal', style: AppText.caption(size: 10, weight: FontWeight.w700, color: AppColors.textSecondary))),
                    Expanded(flex: 2, child: Text('Revenue', style: AppText.caption(size: 10, weight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.right)),
                    Expanded(flex: 2, child: Text('Profit', style: AppText.caption(size: 10, weight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.right)),
                    Expanded(flex: 1, child: Text('Order', style: AppText.caption(size: 10, weight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              // Rows
              ...displayRows.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final isLast = i == displayRows.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider))),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(dateFormatter.format(DateTime.tryParse(r.date) ?? DateTime.now()), style: AppText.body(size: 11))),
                      Expanded(flex: 2, child: Text(currency.format(r.revenue), style: AppText.body(size: 11, weight: FontWeight.w600), textAlign: TextAlign.right)),
                      Expanded(flex: 2, child: Text(currency.format(r.profit), style: AppText.body(size: 11, weight: FontWeight.w600, color: r.profit > 0 ? AppColors.success : AppColors.textPrimary), textAlign: TextAlign.right)),
                      Expanded(flex: 1, child: Text('${r.orders}', style: AppText.body(size: 11), textAlign: TextAlign.right)),
                    ],
                  ),
                );
              }),
              if (displayRows.isEmpty)
                Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('Tidak ada transaksi', style: AppText.caption()))),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Top products by profit
  // ---------------------------------------------------------------------------
  Widget _buildTopByProfit(NumberFormat currency) {
    final top = _report!.topByProfit;
    if (top.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Produk Teruntung'),
        const SizedBox(height: 10),
        ...top.asMap().entries.map((entry) {
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
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
                  child: Text('$index', style: AppText.body(size: 12, weight: FontWeight.w700, color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.productName, style: AppText.body(size: 13, weight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${p.totalQty} terjual', style: AppText.caption(size: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(currency.format(p.totalProfit), style: AppText.body(size: 13, weight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: AppText.label(size: 10, color: AppColors.textSecondary, letterSpacing: 0.8)),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    const iconColor = AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppText.caption(size: 10, color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                Text(value, style: AppText.body(size: compact ? 13 : 14, weight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
