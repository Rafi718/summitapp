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

  List<Product> getRelatedProducts(int productId, int categoryId) {
    return _products.where((p) => p.id != productId && p.categoryId == categoryId).take(6).toList();
  }
}
