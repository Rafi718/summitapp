import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../services/database_service.dart';
import '../services/seed_data.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    final db = await DatabaseService.database;
    final users = await db.query('users', limit: 1);
    if (users.isNotEmpty) {
      _currentUser = User.fromMap(users.first);
    }
    await _seedIfEmpty();
  }

  Future<void> _seedIfEmpty() async {
    final db = await DatabaseService.database;

    final catCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories'));
    if (catCount == 0) {
      for (final cat in SeedData.categories) {
        await db.insert('categories', cat.toMap());
      }
    }

    final prodCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    if (prodCount == 0) {
      for (final prod in SeedData.products) {
        await db.insert('products', prod.toMap());
      }
    }

    final voucherCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM vouchers'));
    if (voucherCount == 0) {
      for (final v in SeedData.vouchers) {
        await db.insert('vouchers', v.toMap());
      }
    }

    // Seed a default admin user on a fresh install so the demo flow
    // works without forcing the user to register a special account.
    // Skipped if any user already exists (registered users take priority).
    final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    if (userCount == 0) {
      final admin = User(
        name: 'Admin Summit',
        email: 'admin@summit.com',
        password: 'admin123',
        createdAt: DateTime.now().toIso8601String(),
      );
      await db.insert('users', admin.toMap());
    }
  }

  /// Inserts the current SeedData into the DB unconditionally. Caller is
  /// responsible for clearing the target tables first.
  Future<void> _seedAll() async {
    final db = await DatabaseService.database;
    for (final cat in SeedData.categories) {
      await db.insert('categories', cat.toMap());
    }
    for (final prod in SeedData.products) {
      await db.insert('products', prod.toMap());
    }
    for (final v in SeedData.vouchers) {
      await db.insert('vouchers', v.toMap());
    }
  }

  /// Destructive: wipes products, categories, vouchers, and all data
  /// that depends on them (cart_items, wishlist, order_items, orders,
  /// reviews), then re-runs the seed from `SeedData`. Users (accounts)
  /// are preserved. Wrapped in a single transaction for atomicity.
  ///
  /// Called from the admin dashboard "Reset Data ke Default" tile.
  Future<void> resetSeed() async {
    final db = await DatabaseService.database;
    await db.transaction((txn) async {
      // Delete in dependency order. FK isn't enforced by default in
      // this DB, but we still delete dependents first for clarity.
      await txn.delete('order_items');
      await txn.delete('orders');
      await txn.delete('cart_items');
      await txn.delete('wishlist');
      await txn.delete('reviews');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('vouchers');
    });
    // Re-insert seed. Done outside the transaction because sqflite's
    // transaction doesn't allow nested insert calls cleanly here, and
    // these are idempotent seed inserts with fixed ids.
    await _seedAll();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await DatabaseService.database;

    final existing = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (existing.isNotEmpty) return 'Email sudah terdaftar';

    final user = User(
      name: name,
      email: email,
      password: password,
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await db.insert('users', user.toMap());
    _currentUser = user.copyWith(id: id);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final db = await DatabaseService.database;

    final result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isEmpty) return 'Email atau password salah';

    _currentUser = User.fromMap(result.first);
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photo,
  }) async {
    if (_currentUser == null) return;
    final db = await DatabaseService.database;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photo != null) updates['photo'] = photo;

    if (updates.isNotEmpty) {
      await db.update('users', updates, where: 'id = ?', whereArgs: [_currentUser!.id]);
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        photo: photo ?? _currentUser!.photo,
      );
    }
  }

  Future<List<Address>> getAddresses() async {
    if (_currentUser == null) return [];
    final db = await DatabaseService.database;
    final results = await db.query('addresses', where: 'user_id = ?', whereArgs: [_currentUser!.id]);
    return results.map((m) => Address.fromMap(m)).toList();
  }

  Future<void> addAddress(Address address) async {
    final db = await DatabaseService.database;
    await db.insert('addresses', address.toMap());
  }

  Future<void> updateAddress(Address address) async {
    final db = await DatabaseService.database;
    await db.update('addresses', address.toMap(), where: 'id = ?', whereArgs: [address.id]);
  }

  Future<void> deleteAddress(int id) async {
    final db = await DatabaseService.database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setPrimaryAddress(int id) async {
    if (_currentUser == null) return;
    final db = await DatabaseService.database;
    await db.update('addresses', {'is_primary': 0}, where: 'user_id = ?', whereArgs: [_currentUser!.id]);
    await db.update('addresses', {'is_primary': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<Address?> getPrimaryAddress() async {
    if (_currentUser == null) return null;
    final db = await DatabaseService.database;
    final results = await db.query('addresses',
      where: 'user_id = ? AND is_primary = ?',
      whereArgs: [_currentUser!.id, 1],
      limit: 1,
    );
    if (results.isNotEmpty) return Address.fromMap(results.first);
    return null;
  }
}
