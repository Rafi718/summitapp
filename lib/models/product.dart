class Product {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final String brand;
  final int weight;
  final int price;
  final int? discountPrice;
  final int costPrice;
  final int stock;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final List<String> images;
  final bool isActive;
  final String? sizeGuide;
  final String createdAt;

  Product({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.brand,
    required this.weight,
    required this.price,
    this.discountPrice,
    this.costPrice = 0,
    required this.stock,
    this.rating = 0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.images = const [],
    this.isActive = true,
    this.sizeGuide,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'brand': brand,
      'weight': weight,
      'price': price,
      'discount_price': discountPrice,
      'cost_price': costPrice,
      'stock': stock,
      'rating': rating,
      'review_count': reviewCount,
      'sold_count': soldCount,
      'images': images.join(','),
      'is_active': isActive ? 1 : 0,
      'size_guide': sizeGuide,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      weight: map['weight'] as int? ?? 0,
      price: map['price'] as int? ?? 0,
      discountPrice: map['discount_price'] as int?,
      costPrice: map['cost_price'] as int? ?? 0,
      stock: map['stock'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: map['review_count'] as int? ?? 0,
      soldCount: map['sold_count'] as int? ?? 0,
      images: (map['images'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      isActive: (map['is_active'] as int?) == 1,
      sizeGuide: map['size_guide'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  int get effectivePrice => discountPrice ?? price;
  bool get isOnSale => discountPrice != null && discountPrice! < price;
  int get discountPercent => isOnSale ? ((price - discountPrice!) / price * 100).round() : 0;

  /// Profit per unit sold = selling price - cost price.
  int get profitPerUnit => effectivePrice - costPrice;

  /// Margin percentage = profit / selling price * 100.
  int get marginPercent {
    if (effectivePrice == 0) return 0;
    return ((profitPerUnit / effectivePrice) * 100).round();
  }
}
