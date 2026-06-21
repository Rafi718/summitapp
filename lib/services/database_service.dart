import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/constants.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN image TEXT');
      } catch (_) {
        // Column may already exist; ignore.
      }
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT,
        photo TEXT,
        email_verified_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        parent_id INTEGER,
        icon TEXT NOT NULL,
        image TEXT,
        FOREIGN KEY (parent_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        brand TEXT NOT NULL,
        weight INTEGER NOT NULL,
        price INTEGER NOT NULL,
        discount_price INTEGER,
        stock INTEGER NOT NULL,
        rating REAL DEFAULT 0,
        review_count INTEGER DEFAULT 0,
        sold_count INTEGER DEFAULT 0,
        images TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        size_guide TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty INTEGER NOT NULL DEFAULT 1,
        variant_size TEXT,
        variant_color TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        label TEXT NOT NULL,
        recipient_name TEXT NOT NULL,
        recipient_phone TEXT NOT NULL,
        full_address TEXT NOT NULL,
        city TEXT NOT NULL,
        subdistrict TEXT NOT NULL,
        postal_code TEXT NOT NULL,
        is_primary INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        value INTEGER NOT NULL,
        min_purchase INTEGER,
        max_discount INTEGER,
        valid_from TEXT NOT NULL,
        valid_until TEXT NOT NULL,
        quota INTEGER DEFAULT 0,
        used_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        address_id INTEGER NOT NULL,
        ongkir INTEGER NOT NULL DEFAULT 0,
        voucher_id INTEGER,
        voucher_discount INTEGER DEFAULT 0,
        subtotal INTEGER NOT NULL,
        total INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'menunggu_pembayaran',
        courier TEXT,
        tracking_number TEXT,
        payment_method TEXT,
        payment_deadline TEXT,
        paid_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (address_id) REFERENCES addresses(id),
        FOREIGN KEY (voucher_id) REFERENCES vouchers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        variant_size TEXT,
        variant_color TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        order_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        text TEXT NOT NULL,
        photos TEXT DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        UNIQUE(user_id, product_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
  }

  static Future<void> clearTables() async {
    final db = await database;
    final tables = ['cart_items', 'order_items', 'reviews', 'wishlist', 'orders', 'addresses', 'vouchers', 'products', 'categories', 'users'];
    for (final table in tables) {
      await db.delete(table);
    }
  }
}
