class CartItem {
  final int? id;
  final int userId;
  final int productId;
  final int qty;
  String? variantSize;
  String? variantColor;

  CartItem({
    this.id,
    required this.userId,
    required this.productId,
    required this.qty,
    this.variantSize,
    this.variantColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'qty': qty,
      'variant_size': variantSize,
      'variant_color': variantColor,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      qty: map['qty'] as int? ?? 1,
      variantSize: map['variant_size'] as String?,
      variantColor: map['variant_color'] as String?,
    );
  }
}
