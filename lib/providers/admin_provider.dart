import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/user.dart';
import '../models/product.dart';

class DashboardMetrics {
  final int totalRevenue;
  final int monthlyRevenue;
  final int todayRevenue;
  final int totalProfit;
  final int monthlyProfit;
  final int todayProfit;
  final int totalOrders;
  final int activeOrders;
  final int productsSold;

  const DashboardMetrics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.todayRevenue,
    required this.totalProfit,
    required this.monthlyProfit,
    required this.todayProfit,
    required this.totalOrders,
    required this.activeOrders,
    required this.productsSold,
  });
}

class TopProduct {
  final int productId;
  final String productName;
  final int totalQty;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.totalQty,
  });
}

/// One row in the daily sales breakdown table.
class DailySalesRow {
  final String date;
  final int revenue;
  final int cost;
  final int profit;
  final int orders;

  const DailySalesRow({
    required this.date,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.orders,
  });
}

/// Top product ranked by total profit (not just qty sold).
class TopProfitProduct {
  final int productId;
  final String productName;
  final int totalQty;
  final int totalProfit;

  const TopProfitProduct({
    required this.productId,
    required this.productName,
    required this.totalQty,
    required this.totalProfit,
  });
}

/// Aggregated sales report for a date range.
class SalesReport {
  final int totalRevenue;
  final int totalCost;
  final int totalProfit;
  final int totalOrders;
  final int totalItemsSold;
  final List<DailySalesRow> dailyRows;
  final List<TopProfitProduct> topByProfit;

  const SalesReport({
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.dailyRows,
    required this.topByProfit,
  });

  /// Average Order Value = revenue / orders.
  int get aov => totalOrders > 0 ? totalRevenue ~/ totalOrders : 0;

  /// Overall margin % = profit / revenue * 100.
  int get marginPercent {
    if (totalRevenue == 0) return 0;
    return ((totalProfit / totalRevenue) * 100).round();
  }
}

class AdminProvider extends ChangeNotifier {
  final AuthService _authService;

  AdminProvider({AuthService? authService}) : _authService = authService ?? AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardMetrics? _metrics;
  DashboardMetrics? get metrics => _metrics;

  List<TopProduct> _topProducts = [];
  List<TopProduct> get topProducts => _topProducts;

  List<Product> _lowStockProducts = [];
  List<Product> get lowStockProducts => _lowStockProducts;

  List<Order> _allOrders = [];
  List<Order> get allOrders => _allOrders;

  final Map<int, User> _userMap = {};
  Map<int, User> get userMap => _userMap;

  Future<void> loadDashboard() async {
    _setLoading(true);
    try {
      final db = await DatabaseService.database;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final monthStart = DateTime(now.year, now.month, 1).toIso8601String();

      // Revenue (order total includes ongkir & voucher discount).
      final revenueRow = await db.rawQuery(
        "SELECT COALESCE(SUM(total), 0) AS sum FROM orders WHERE status != 'dibatalkan'",
      );
      final totalRevenue = (revenueRow.first['sum'] as num?)?.toInt() ?? 0;

      final monthlyRow = await db.rawQuery(
        "SELECT COALESCE(SUM(total), 0) AS sum FROM orders WHERE status != 'dibatalkan' AND created_at >= ?",
        [monthStart],
      );
      final monthlyRevenue = (monthlyRow.first['sum'] as num?)?.toInt() ?? 0;

      final todayRow = await db.rawQuery(
        "SELECT COALESCE(SUM(total), 0) AS sum FROM orders WHERE status != 'dibatalkan' AND created_at >= ?",
        [todayStart],
      );
      final todayRevenue = (todayRow.first['sum'] as num?)?.toInt() ?? 0;

      // Profit = SUM((price - cost_price) * qty) from order_items joined
      // to non-cancelled orders. Uses the cost_price snapshot stored on
      // each order_item so historical profit is accurate.
      final profitRow = await db.rawQuery(
        "SELECT COALESCE(SUM((order_items.price - order_items.cost_price) * order_items.qty), 0) AS sum "
        "FROM order_items INNER JOIN orders ON orders.id = order_items.order_id "
        "WHERE orders.status != 'dibatalkan'",
      );
      final totalProfit = (profitRow.first['sum'] as num?)?.toInt() ?? 0;

      final monthlyProfitRow = await db.rawQuery(
        "SELECT COALESCE(SUM((order_items.price - order_items.cost_price) * order_items.qty), 0) AS sum "
        "FROM order_items INNER JOIN orders ON orders.id = order_items.order_id "
        "WHERE orders.status != 'dibatalkan' AND orders.created_at >= ?",
        [monthStart],
      );
      final monthlyProfit = (monthlyProfitRow.first['sum'] as num?)?.toInt() ?? 0;

      final todayProfitRow = await db.rawQuery(
        "SELECT COALESCE(SUM((order_items.price - order_items.cost_price) * order_items.qty), 0) AS sum "
        "FROM order_items INNER JOIN orders ON orders.id = order_items.order_id "
        "WHERE orders.status != 'dibatalkan' AND orders.created_at >= ?",
        [todayStart],
      );
      final todayProfit = (todayProfitRow.first['sum'] as num?)?.toInt() ?? 0;

      final totalOrdersRow = await db.rawQuery('SELECT COUNT(*) AS count FROM orders');
      final totalOrders = Sqflite.firstIntValue(totalOrdersRow) ?? 0;

      final activeOrdersRow = await db.rawQuery(
        "SELECT COUNT(*) AS count FROM orders WHERE status NOT IN ('selesai', 'dibatalkan')",
      );
      final activeOrders = Sqflite.firstIntValue(activeOrdersRow) ?? 0;

      final soldRow = await db.rawQuery(
        "SELECT COALESCE(SUM(order_items.qty), 0) AS sum FROM order_items "
        "INNER JOIN orders ON orders.id = order_items.order_id "
        "WHERE orders.status != 'dibatalkan'",
      );
      final productsSold = (soldRow.first['sum'] as num?)?.toInt() ?? 0;

      _metrics = DashboardMetrics(
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        todayRevenue: todayRevenue,
        totalProfit: totalProfit,
        monthlyProfit: monthlyProfit,
        todayProfit: todayProfit,
        totalOrders: totalOrders,
        activeOrders: activeOrders,
        productsSold: productsSold,
      );

      final topRows = await db.rawQuery(
        'SELECT product_id, product_name, SUM(qty) AS total_qty FROM order_items '
        'GROUP BY product_id ORDER BY total_qty DESC LIMIT 5',
      );
      _topProducts = topRows.map((row) => TopProduct(
        productId: row['product_id'] as int,
        productName: row['product_name'] as String? ?? '',
        totalQty: (row['total_qty'] as num?)?.toInt() ?? 0,
      )).toList();

      final lowStockRows = await db.query(
        'products',
        where: 'stock < ?',
        whereArgs: [10],
        orderBy: 'stock ASC',
        limit: 5,
      );
      _lowStockProducts = lowStockRows.map((m) => Product.fromMap(m)).toList();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Loads a full sales report for the given [start]..[end] date range
  /// (inclusive). Returns daily breakdown rows, top products by profit,
  /// and aggregate totals. Only counts non-cancelled orders.
  Future<SalesReport> loadSalesReport(DateTime start, DateTime end) async {
    final db = await DatabaseService.database;

    // Normalize to day boundaries: start = 00:00, end = 23:59:59.999
    final startStr = DateTime(start.year, start.month, start.day).toIso8601String();
    final endStr = DateTime(end.year, end.month, end.day, 23, 59, 59, 999).toIso8601String();

    // Aggregate totals for the range.
    final aggRow = await db.rawQuery(
      "SELECT "
      "  COALESCE(SUM(orders.total), 0) AS revenue, "
      "  COALESCE(SUM((oi.price - oi.cost_price) * oi.qty), 0) AS profit, "
      "  COALESCE(SUM(oi.cost_price * oi.qty), 0) AS cost, "
      "  COUNT(DISTINCT orders.id) AS order_count, "
      "  COALESCE(SUM(oi.qty), 0) AS items_sold "
      "FROM orders "
      "LEFT JOIN order_items oi ON oi.order_id = orders.id "
      "WHERE orders.status != 'dibatalkan' AND orders.created_at >= ? AND orders.created_at <= ?",
      [startStr, endStr],
    );
    final agg = aggRow.first;
    final totalRevenue = (agg['revenue'] as num?)?.toInt() ?? 0;
    final totalProfit = (agg['profit'] as num?)?.toInt() ?? 0;
    final totalCost = (agg['cost'] as num?)?.toInt() ?? 0;
    final totalOrders = (agg['order_count'] as int?) ?? 0;
    final totalItemsSold = (agg['items_sold'] as num?)?.toInt() ?? 0;

    // Daily breakdown. SQLite's substr extracts the date portion (YYYY-MM-DD)
    // from the ISO timestamp stored in created_at.
    final dailyRows = await db.rawQuery(
      "SELECT "
      "  substr(orders.created_at, 1, 10) AS day, "
      "  COALESCE(SUM(orders.total), 0) AS revenue, "
      "  COALESCE(SUM((oi.price - oi.cost_price) * oi.qty), 0) AS profit, "
      "  COALESCE(SUM(oi.cost_price * oi.qty), 0) AS cost, "
      "  COUNT(DISTINCT orders.id) AS order_count "
      "FROM orders "
      "LEFT JOIN order_items oi ON oi.order_id = orders.id "
      "WHERE orders.status != 'dibatalkan' AND orders.created_at >= ? AND orders.created_at <= ? "
      "GROUP BY day ORDER BY day ASC",
      [startStr, endStr],
    );

    // Build a complete list of dates in the range so the chart/table
    // shows zero-revenue days instead of skipping them.
    final rowMap = <String, DailySalesRow>{};
    for (final row in dailyRows) {
      final day = row['day'] as String? ?? '';
      rowMap[day] = DailySalesRow(
        date: day,
        revenue: (row['revenue'] as num?)?.toInt() ?? 0,
        cost: (row['cost'] as num?)?.toInt() ?? 0,
        profit: (row['profit'] as num?)?.toInt() ?? 0,
        orders: (row['order_count'] as int?) ?? 0,
      );
    }
    final fullRows = <DailySalesRow>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(endDay)) {
      final key = '${cursor.year.toString().padLeft(4, '0')}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      fullRows.add(rowMap[key] ?? DailySalesRow(date: key, revenue: 0, cost: 0, profit: 0, orders: 0));
      cursor = cursor.add(const Duration(days: 1));
    }

    // Top products by profit in the range.
    final topProfitRows = await db.rawQuery(
      "SELECT "
      "  oi.product_id AS product_id, "
      "  oi.product_name AS product_name, "
      "  SUM(oi.qty) AS total_qty, "
      "  SUM((oi.price - oi.cost_price) * oi.qty) AS total_profit "
      "FROM order_items oi "
      "INNER JOIN orders ON orders.id = oi.order_id "
      "WHERE orders.status != 'dibatalkan' AND orders.created_at >= ? AND orders.created_at <= ? "
      "GROUP BY oi.product_id ORDER BY total_profit DESC LIMIT 5",
      [startStr, endStr],
    );
    final topByProfit = topProfitRows.map((row) => TopProfitProduct(
      productId: row['product_id'] as int,
      productName: row['product_name'] as String? ?? '',
      totalQty: (row['total_qty'] as num?)?.toInt() ?? 0,
      totalProfit: (row['total_profit'] as num?)?.toInt() ?? 0,
    )).toList();

    return SalesReport(
      totalRevenue: totalRevenue,
      totalCost: totalCost,
      totalProfit: totalProfit,
      totalOrders: totalOrders,
      totalItemsSold: totalItemsSold,
      dailyRows: fullRows,
      topByProfit: topByProfit,
    );
  }

  Future<void> loadAllOrders() async {
    _setLoading(true);
    try {
      final db = await DatabaseService.database;
      final results = await db.query(
        'orders',
        orderBy: 'created_at DESC',
      );
      _allOrders = results.map((m) => Order.fromMap(m)).toList();

      _userMap.clear();
      final userIds = _allOrders.map((o) => o.userId).toSet();
      for (final userId in userIds) {
        final user = await _authService.getUserById(userId);
        if (user != null) _userMap[userId] = user;
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await DatabaseService.database;
    final results = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return results.map((m) => OrderItem.fromMap(m)).toList();
  }

  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? trackingNumber,
    String? paidAt,
  }) async {
    final db = await DatabaseService.database;
    final updates = <String, dynamic>{'status': status};
    if (trackingNumber != null) updates['tracking_number'] = trackingNumber;
    if (paidAt != null) updates['paid_at'] = paidAt;

    await db.update('orders', updates, where: 'id = ?', whereArgs: [orderId]);
    await loadAllOrders();
  }

  Future<void> cancelOrder(int orderId) async {
    final db = await DatabaseService.database;

    final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    for (final item in items) {
      final productId = item['product_id'] as int;
      final qty = item['qty'] as int;
      await db.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [qty, productId],
      );
    }

    await db.update('orders', {'status': 'dibatalkan'}, where: 'id = ?', whereArgs: [orderId]);
    await loadAllOrders();
    await loadDashboard();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
