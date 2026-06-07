import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  List<Order> get activeOrders =>
      _orders.where((o) => o.status != 'selesai' && o.status != 'dibatalkan').toList();

  List<Order> get completedOrders =>
      _orders.where((o) => o.status == 'selesai' || o.status == 'dibatalkan').toList();

  Future<void> loadOrders(int userId) async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseService.database;
    final results = await db.query('orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    _orders = results.map((m) => Order.fromMap(m)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await DatabaseService.database;
    final results = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    return results.map((m) => OrderItem.fromMap(m)).toList();
  }

  Future<int> createOrder({
    required int userId,
    required int addressId,
    required int ongkir,
    required List<CartItem> cartItems,
    required List<Product> products,
    required String courier,
    required String paymentMethod,
    int? voucherId,
    int voucherDiscount = 0,
  }) async {
    final db = await DatabaseService.database;

    int subtotal = 0;
    for (final item in cartItems) {
      final product = products.firstWhere((p) => p.id == item.productId);
      subtotal += product.effectivePrice * item.qty;
    }

    final total = subtotal + ongkir - voucherDiscount;

    final order = Order(
      userId: userId,
      addressId: addressId,
      ongkir: ongkir,
      voucherId: voucherId,
      voucherDiscount: voucherDiscount,
      subtotal: subtotal,
      total: total,
      status: 'menunggu_pembayaran',
      courier: courier,
      paymentMethod: paymentMethod,
      paymentDeadline: DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
    );

    final orderId = await db.insert('orders', order.toMap());

    for (final item in cartItems) {
      final product = products.firstWhere((p) => p.id == item.productId);
      final orderItem = OrderItem(
        orderId: orderId,
        productId: item.productId,
        productName: product.name,
        price: product.effectivePrice,
        qty: item.qty,
        subtotal: product.effectivePrice * item.qty,
        variantSize: item.variantSize,
        variantColor: item.variantColor,
      );
      await db.insert('order_items', orderItem.toMap());

      await db.update('products',
        {'stock': product.stock - item.qty, 'sold_count': product.soldCount + item.qty},
        where: 'id = ?',
        whereArgs: [item.productId],
      );
    }

    if (voucherId != null) {
      final usedCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT used_count FROM vouchers WHERE id = ?', [voucherId]),
      ) ?? 0;
      await db.update('vouchers', {'used_count': usedCount + 1}, where: 'id = ?', whereArgs: [voucherId]);
    }

    await loadOrders(userId);
    return orderId;
  }

  Future<void> payOrder(int orderId, int userId) async {
    final db = await DatabaseService.database;
    await db.update('orders', {
      'status': 'diproses',
      'paid_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [orderId]);

    await Future.delayed(const Duration(milliseconds: 500));
    await db.update('orders', {
      'status': 'dikirim',
      'tracking_number': 'SUM${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    }, where: 'id = ?', whereArgs: [orderId]);

    await loadOrders(userId);
  }

  Future<void> confirmReceived(int orderId, int userId) async {
    final db = await DatabaseService.database;
    await db.update('orders', {
      'status': 'selesai',
    }, where: 'id = ?', whereArgs: [orderId]);
    await loadOrders(userId);
  }

  Future<void> cancelOrder(int orderId, int userId) async {
    final db = await DatabaseService.database;

    final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    for (final item in items) {
      final productId = item['product_id'] as int;
      final qty = item['qty'] as int;
      await db.rawUpdate('UPDATE products SET stock = stock + ? WHERE id = ?', [qty, productId]);
    }

    await db.update('orders', {'status': 'dibatalkan'}, where: 'id = ?', whereArgs: [orderId]);
    await loadOrders(userId);
  }

  Order? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}
