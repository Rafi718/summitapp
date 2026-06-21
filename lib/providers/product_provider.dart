import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/product.dart';
import '../models/category.dart' as models;

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int _selectedCategoryId = 0;
  String _sortBy = 'terbaru';

  List<Product> get products => _filteredProducts;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  int get selectedCategoryId => _selectedCategoryId;

  List<Product> get _filteredProducts {
    var result = List<Product>.from(_products);

    if (_selectedCategoryId != 0) {
      result = result.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    }

    switch (_sortBy) {
      case 'termurah':
        result.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
        break;
      case 'termahal':
        result.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
        break;
      case 'terlaris':
        result.sort((a, b) => b.soldCount.compareTo(a.soldCount));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }

  List<Product> get popularProducts {
    final sorted = List<Product>.from(_products);
    sorted.sort((a, b) => b.soldCount.compareTo(a.soldCount));
    return sorted.take(8).toList();
  }

  List<Product> get onSaleProducts {
    return _products.where((p) => p.isOnSale).toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseService.database;
    final catResults = await db.query('categories');
    _categories = catResults.map((m) => models.Category.fromMap(m)).toList();

    final prodResults = await db.query('products', where: 'is_active = ?', whereArgs: [1]);
    _products = prodResults.map((m) => Product.fromMap(m)).toList();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fetches a product by ID, falling back to a direct DB query if the
  /// in-memory cache is stale (e.g. detail page opened before loadProducts
  /// completed). Updates the cache on success.
  Future<Product?> fetchProductById(int id) async {
    final cached = getProductById(id);
    if (cached != null) return cached;

    final db = await DatabaseService.database;
    final results = await db.query('products', where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;

    final product = Product.fromMap(results.first);
    final existingIndex = _products.indexWhere((p) => p.id == product.id);
    if (existingIndex >= 0) {
      _products[existingIndex] = product;
    } else {
      _products.add(product);
    }
    notifyListeners();
    return product;
  }

  List<Product> getRelatedProducts(int productId, int categoryId) {
    return _products.where((p) => p.id != productId && p.categoryId == categoryId).take(6).toList();
  }

  // ============================================================
  // Admin CRUD
  // ============================================================
  // Pattern: returns null on success, error message on failure.
  // After any mutation, the in-memory cache is refreshed via
  // loadProducts() (which also reloads categories).

  Future<String?> addProduct(Product p) async {
    final db = await DatabaseService.database;
    final createdAt = p.createdAt.isEmpty
        ? DateTime.now().toIso8601String()
        : p.createdAt;
    // Build a fresh instance with null id so SQLite auto-increments.
    final toInsert = Product(
      categoryId: p.categoryId,
      name: p.name,
      description: p.description,
      brand: p.brand,
      weight: p.weight,
      price: p.price,
      discountPrice: p.discountPrice,
      stock: p.stock,
      rating: p.rating,
      reviewCount: p.reviewCount,
      soldCount: p.soldCount,
      images: p.images,
      isActive: p.isActive,
      sizeGuide: p.sizeGuide,
      createdAt: createdAt,
    );
    await db.insert('products', toInsert.toMap());
    await loadProducts();
    return null;
  }

  Future<String?> updateProduct(Product p) async {
    if (p.id == null) return 'ID produk tidak valid';
    final db = await DatabaseService.database;
    await db.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    await loadProducts();
    return null;
  }

  Future<String?> deleteProduct(int id) async {
    final db = await DatabaseService.database;
    // Cascade: clear cart/wishlist references so we don't leave orphans.
    await db.delete('cart_items', where: 'product_id = ?', whereArgs: [id]);
    await db.delete('wishlist', where: 'product_id = ?', whereArgs: [id]);
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await loadProducts();
    return null;
  }

  Future<String?> addCategory(models.Category c) async {
    final db = await DatabaseService.database;
    await db.insert('categories', c.toMap());
    await loadProducts();
    return null;
  }

  Future<String?> updateCategory(models.Category c) async {
    if (c.id == null) return 'ID kategori tidak valid';
    final db = await DatabaseService.database;
    await db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
    await loadProducts();
    return null;
  }

  Future<String?> deleteCategory(int id) async {
    final db = await DatabaseService.database;
    // FK isn't enforced by default in this DB (no PRAGMA foreign_keys=ON),
    // so we check explicitly to avoid orphan products.
    final usedBy = await db.query('products',
        columns: ['id'], where: 'category_id = ?', whereArgs: [id], limit: 1);
    if (usedBy.isNotEmpty) {
      return 'Kategori masih digunakan produk. Pindahkan atau hapus produknya dulu.';
    }
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await loadProducts();
    return null;
  }
}
