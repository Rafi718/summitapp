import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/database_service.dart';
import '../services/seed_data.dart';

/// SharedPreferences key for persisting the logged-in user's ID across
/// app restarts. Without this, the old code auto-logged-in as
/// `users.first` on every launch — even after logout — which broke
/// the demo flow.
const _kSessionUserId = 'session_user_id';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    final db = await DatabaseService.database;
    try {
      await _seedIfEmpty();
    } catch (e, st) {
      // Print the error so it is visible in the IDE console during dev.
      // This prevents a silent init hang that keeps the login button
      // disabled forever because AuthProvider.isLoading stays true.
      debugPrint('AuthService.init seeding failed: $e');
      debugPrint(st.toString());
      rethrow;
    }

    // Restore session ONLY if a user ID was explicitly saved by login()
    // or register(). This prevents the old bug where the app auto-logged
    // in as `users.first` (the seeded admin) on every launch.
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt(_kSessionUserId);
    if (savedUserId != null) {
      final results = await db.query('users', where: 'id = ?', whereArgs: [savedUserId], limit: 1);
      if (results.isNotEmpty) {
        _currentUser = User.fromMap(results.first);
      } else {
        // Saved user no longer exists (e.g. after resetSeed cleared users).
        // Clear the stale session so the user is sent to the login page.
        await prefs.remove(_kSessionUserId);
      }
    }
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
      await _seedAdminIfMissing(db);
    }

    // Ensure 3 demo customers exist (idempotent — skips emails that
    // already exist so it's safe to call on both fresh and existing DBs).
    final customerIds = await _seedDemoCustomersIfMissing(db);

    // Seed demo orders independently from users so a fresh install AND
    // an existing install (with users but no orders) both get demo data
    // for the dashboard & sales report.
    final orderCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM orders'));
    if (orderCount == 0 && customerIds.length >= 3) {
      await _seedDemoOrders(db, customerIds[0], customerIds[1], customerIds[2]);
    }
  }

  /// Inserts the admin account only if no admin user exists yet.
  /// Idempotent — safe to call on both fresh and existing DBs.
  Future<void> _seedAdminIfMissing(Database db) async {
    final adminCount = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM users WHERE is_admin = 1"),
    );
    if (adminCount != null && adminCount > 0) return;

    final now = DateTime.now();
    await db.insert('users', User(
      name: 'Admin Summit',
      email: 'admin@summit.com',
      password: 'admin123',
      isAdmin: true,
      createdAt: now.toIso8601String(),
    ).toMap());
  }

  /// Ensures the 3 demo customers (Budi, Siti, Andi) with addresses
  /// exist. Returns their user IDs in order. Idempotent — skips any
  /// customer whose email already exists so it never hits the UNIQUE
  /// constraint. Safe to call on both fresh and existing DBs.
  Future<List<int>> _seedDemoCustomersIfMissing(Database db) async {
    final now = DateTime.now();
    final specs = <Map<String, dynamic>>[
      {
        'name': 'Budi Santoso',
        'email': 'budi@email.com',
        'password': 'budi123',
        'phone': '081234567890',
        'daysAgo': 30,
        'address': 'Jl. Merapi No. 12, Sleman',
        'city': 'Sleman',
        'subdistrict': 'Ngaglik',
        'postalCode': '55581',
      },
      {
        'name': 'Siti Rahma',
        'email': 'siti@email.com',
        'password': 'siti123',
        'phone': '082198765432',
        'daysAgo': 20,
        'address': 'Jl. Bromo No. 8, Malang',
        'city': 'Malang',
        'subdistrict': 'Lowokwaru',
        'postalCode': '65141',
      },
      {
        'name': 'Andi Wijaya',
        'email': 'andi@email.com',
        'password': 'andi123',
        'phone': '085711223344',
        'daysAgo': 10,
        'address': 'Jl. Semeru No. 21, Lumajang',
        'city': 'Lumajang',
        'subdistrict': 'Lumajang',
        'postalCode': '67312',
      },
    ];

    final ids = <int>[];
    for (final s in specs) {
      final email = s['email'] as String;
      // Check if this customer already exists.
      final existing = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
      int userId;
      if (existing.isNotEmpty) {
        userId = existing.first['id'] as int;
      } else {
        userId = await db.insert('users', User(
          name: s['name'] as String,
          email: email,
          password: s['password'] as String,
          phone: s['phone'] as String,
          createdAt: now.subtract(Duration(days: s['daysAgo'] as int)).toIso8601String(),
        ).toMap());
        // Only insert address for newly created customers (existing ones
        // presumably already have addresses).
        await db.insert('addresses', Address(
          userId: userId,
          label: 'Rumah',
          recipientName: s['name'] as String,
          recipientPhone: s['phone'] as String,
          fullAddress: s['address'] as String,
          city: s['city'] as String,
          subdistrict: s['subdistrict'] as String,
          postalCode: s['postalCode'] as String,
          isPrimary: true,
        ).toMap());
      }
      ids.add(userId);
    }
    return ids;
  }

  /// Seeds 8 demo orders spread across the last 7 days with various
  /// products and statuses. Uses the product's current cost_price as
  /// the order_items snapshot so profit reports show realistic data.
  Future<void> _seedDemoOrders(Database db, int c1, int c2, int c3) async {
    final now = DateTime.now();
    final products = SeedData.products;

    // Helper to create an order.
    Future<void> createOrder({
      required int userId,
      required int addressId,
      required List<int> productIndexes,
      required List<int> quantities,
      required int ongkir,
      required String status,
      required int daysAgo,
      String? paymentMethod,
    }) async {
      int subtotal = 0;
      final createdAt = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysAgo));

      final orderId = await db.insert('orders', Order(
        userId: userId,
        addressId: addressId,
        ongkir: ongkir,
        subtotal: 0, // will be computed below
        total: 0,
        status: status,
        courier: 'JNE REG',
        paymentMethod: paymentMethod ?? 'Transfer Bank',
        createdAt: createdAt.toIso8601String(),
        paidAt: status != 'menunggu_pembayaran' ? createdAt.toIso8601String() : null,
      ).toMap());

      for (var i = 0; i < productIndexes.length; i++) {
        final p = products[productIndexes[i]];
        final qty = quantities[i];
        final price = p.effectivePrice;
        final itemSubtotal = price * qty;
        subtotal += itemSubtotal;

        await db.insert('order_items', OrderItem(
          orderId: orderId,
          productId: p.id!,
          productName: p.name,
          price: price,
          costPrice: p.costPrice,
          qty: qty,
          subtotal: itemSubtotal,
        ).toMap());

        // Decrement stock & increment sold_count for realism.
        await db.rawUpdate(
          'UPDATE products SET stock = MAX(0, stock - ?), sold_count = sold_count + ? WHERE id = ?',
          [qty, qty, p.id],
        );
      }

      final total = subtotal + ongkir;
      await db.update('orders',
        {'subtotal': subtotal, 'total': total},
        where: 'id = ?',
        whereArgs: [orderId],
      );
    }

    // Get address IDs (first address for each customer).
    final addr1 = Sqflite.firstIntValue(await db.rawQuery('SELECT id FROM addresses WHERE user_id = ? LIMIT 1', [c1]))!;
    final addr2 = Sqflite.firstIntValue(await db.rawQuery('SELECT id FROM addresses WHERE user_id = ? LIMIT 1', [c2]))!;
    final addr3 = Sqflite.firstIntValue(await db.rawQuery('SELECT id FROM addresses WHERE user_id = ? LIMIT 1', [c3]))!;

    // 8 orders spread across last 7 days, various statuses.
    await createOrder(userId: c1, addressId: addr1, productIndexes: [6, 12], quantities: [1, 1], ongkir: 25000, status: 'selesai', daysAgo: 6);
    await createOrder(userId: c2, addressId: addr2, productIndexes: [2], quantities: [2], ongkir: 20000, status: 'selesai', daysAgo: 5);
    await createOrder(userId: c3, addressId: addr3, productIndexes: [0, 14], quantities: [1, 1], ongkir: 30000, status: 'selesai', daysAgo: 4);
    await createOrder(userId: c1, addressId: addr1, productIndexes: [8], quantities: [1], ongkir: 25000, status: 'selesai', daysAgo: 3);
    await createOrder(userId: c2, addressId: addr2, productIndexes: [6, 11, 16], quantities: [1, 2, 1], ongkir: 20000, status: 'dikirim', daysAgo: 2);
    await createOrder(userId: c3, addressId: addr3, productIndexes: [4], quantities: [1], ongkir: 30000, status: 'diproses', daysAgo: 1);
    await createOrder(userId: c1, addressId: addr1, productIndexes: [9, 12], quantities: [1, 1], ongkir: 25000, status: 'menunggu_pembayaran', daysAgo: 0);
    await createOrder(userId: c2, addressId: addr2, productIndexes: [3], quantities: [1], ongkir: 20000, status: 'menunggu_pembayaran', daysAgo: 0);
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

  /// Destructive: wipes all transactional data (orders, cart, wishlist,
  /// reviews) and catalog data (products, categories, vouchers), then
  /// re-seeds everything including demo customers and demo orders so
  /// the dashboard & sales report have data immediately after reset.
  ///
  /// Users (accounts) are also wiped and re-seeded (admin + 3 demo
  /// customers) because demo orders need valid user/address FKs.
  /// The current session is cleared so the user is sent to login.
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
      await txn.delete('addresses');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('vouchers');
      await txn.delete('users');
    });
    // Re-insert seed. Done outside the transaction because sqflite's
    // transaction doesn't allow nested insert calls cleanly here, and
    // these are idempotent seed inserts with fixed ids.
    await _seedAll();
    // Re-seed users (admin + demo customers) and demo orders.
    await _seedAdminIfMissing(db);
    final customerIds = await _seedDemoCustomersIfMissing(db);
    await _seedDemoOrders(db, customerIds[0], customerIds[1], customerIds[2]);

    // Clear the saved session so the user is sent to the login page
    // after reset (their user ID no longer exists).
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionUserId);
    _currentUser = null;
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

    // Persist session so the user stays logged in across app restarts.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionUserId, id);
    return null;
  }

  Future<String?> login({required String email, required String password}) async {
    final db = await DatabaseService.database;

    final result = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isEmpty) return 'Email atau password salah';

    _currentUser = User.fromMap(result.first);

    // Persist session so the user stays logged in across app restarts.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionUserId, _currentUser!.id!);
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    // Clear the saved session so logout actually persists across
    // app restarts. Previously the app would auto-login again on
    // the next launch because init() grabbed users.first.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionUserId);
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

  Future<User?> getUserById(int id) async {
    final db = await DatabaseService.database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isNotEmpty) return User.fromMap(results.first);
    return null;
  }

  Future<Address?> getAddressById(int id) async {
    final db = await DatabaseService.database;
    final results = await db.query('addresses', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isNotEmpty) return Address.fromMap(results.first);
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await DatabaseService.database;
    final results = await db.query('users', orderBy: 'created_at DESC');
    return results.map((m) => User.fromMap(m)).toList();
  }
}
