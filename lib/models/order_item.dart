class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int price;
  final int costPrice;
  final int qty;
  final int subtotal;
  final String? variantSize;
  final String? variantColor;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    this.costPrice = 0,
    required this.qty,
    required this.subtotal,
    this.variantSize,
    this.variantColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'cost_price': costPrice,
      'qty': qty,
      'subtotal': subtotal,
      'variant_size': variantSize,
      'variant_color': variantColor,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      productName: map['product_name'] as String? ?? '',
      price: map['price'] as int? ?? 0,
      costPrice: map['cost_price'] as int? ?? 0,
      qty: map['qty'] as int? ?? 0,
      subtotal: map['subtotal'] as int? ?? 0,
      variantSize: map['variant_size'] as String?,
      variantColor: map['variant_color'] as String?,
    );
  }

  /// Total cost for this line item = cost per unit * qty.
  int get totalCost => costPrice * qty;

  /// Gross profit for this line item = revenue - cost.
  int get profit => subtotal - totalCost;
}
