import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  int _userId = 0;
  bool _isLoading = false;
  String? _appliedVoucherCode;
  int _voucherDiscount = 0;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get appliedVoucherCode => _appliedVoucherCode;
  int get voucherDiscount => _voucherDiscount;
  int? get userId => _userId == 0 ? null : _userId;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.qty);

  int get subtotal {
    return _items.fold(0, (sum, item) {
      final product = _getCachedProduct(item.productId);
      if (product != null) {
        return sum + (product.effectivePrice * item.qty);
      }
      return sum;
    });
  }

  int get total {
    final sub = subtotal;
    final discount = _voucherDiscount > sub ? sub : _voucherDiscount;
    return sub - discount;
  }

  final Map<int, Product> _productCache = {};

  Product? _getCachedProduct(int productId) {
    return _productCache[productId];
  }

  void setProductCache(List<Product> products) {
    for (final p in products) {
      _productCache[p.id!] = p;
    }
  }

  Future<void> loadCart(int userId) async {
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseService.database;
    final results = await db.query('cart_items', where: 'user_id = ?', whereArgs: [userId]);
    _items = results.map((m) => CartItem.fromMap(m)).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(int productId, {int qty = 1, String? variantSize, String? variantColor}) async {
    final db = await DatabaseService.database;

    String whereStr = 'user_id = ? AND product_id = ?';
    List<dynamic> whereArgs = [_userId, productId];

    if (variantSize != null) {
      whereStr += ' AND variant_size = ?';
      whereArgs.add(variantSize);
    } else {
      whereStr += ' AND variant_size IS NULL';
    }

    if (variantColor != null) {
      whereStr += ' AND variant_color = ?';
      whereArgs.add(variantColor);
    } else {
      whereStr += ' AND variant_color IS NULL';
    }

    final existing = await db.query('cart_items', where: whereStr, whereArgs: whereArgs);

    if (existing.isNotEmpty) {
      final item = CartItem.fromMap(existing.first);
      await db.update('cart_items',
        {'qty': item.qty + qty},
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } else {
      final item = CartItem(
        userId: _userId,
        productId: productId,
        qty: qty,
        variantSize: variantSize,
        variantColor: variantColor,
      );
      await db.insert('cart_items', item.toMap());
    }

    await loadCart(_userId);
  }

  Future<void> updateQty(int itemId, int qty) async {
    final db = await DatabaseService.database;
    if (qty <= 0) {
      await db.delete('cart_items', where: 'id = ?', whereArgs: [itemId]);
    } else {
      await db.update('cart_items', {'qty': qty}, where: 'id = ?', whereArgs: [itemId]);
    }
    await loadCart(_userId);
  }

  Future<void> removeItem(int itemId) async {
    final db = await DatabaseService.database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [itemId]);
    await loadCart(_userId);
  }

  Future<void> clearCart() async {
    final db = await DatabaseService.database;
    await db.delete('cart_items', where: 'user_id = ?', whereArgs: [_userId]);
    _items = [];
    _appliedVoucherCode = null;
    _voucherDiscount = 0;
    notifyListeners();
  }

  Future<String?> applyVoucher(String code) async {
    final db = await DatabaseService.database;
    final results = await db.query('vouchers', where: 'code = ?', whereArgs: [code.toUpperCase()]);

    if (results.isEmpty) return 'Kode voucher tidak ditemukan';

    final voucher = results.first;
    final type = voucher['type'] as String;
    final value = voucher['value'] as int;
    final minPurchase = voucher['min_purchase'] as int?;
    final maxDiscount = voucher['max_discount'] as int?;
    final quota = voucher['quota'] as int;
    final usedCount = voucher['used_count'] as int;
    final validUntil = DateTime.parse(voucher['valid_until'] as String);

    if (usedCount >= quota) return 'Kuota voucher sudah habis';
    if (DateTime.now().isAfter(validUntil)) return 'Voucher sudah kadaluarsa';
    if (minPurchase != null && subtotal < minPurchase) return 'Minimal belanja Rp${minPurchase} untuk voucher ini';

    _appliedVoucherCode = code.toUpperCase();

    if (type == 'persen') {
      _voucherDiscount = (subtotal * value ~/ 100);
      if (maxDiscount != null && _voucherDiscount > maxDiscount) {
        _voucherDiscount = maxDiscount;
      }
    } else {
      _voucherDiscount = value;
    }

    notifyListeners();
    return null;
  }

  void removeVoucher() {
    _appliedVoucherCode = null;
    _voucherDiscount = 0;
    notifyListeners();
  }
}
