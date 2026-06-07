class Order {
  final int? id;
  final int userId;
  final int addressId;
  final int ongkir;
  final int? voucherId;
  final int? voucherDiscount;
  final int subtotal;
  final int total;
  final String status;
  final String? courier;
  final String? trackingNumber;
  final String? paymentMethod;
  final String? paymentDeadline;
  final String? paidAt;
  final String createdAt;

  Order({
    this.id,
    required this.userId,
    required this.addressId,
    required this.ongkir,
    this.voucherId,
    this.voucherDiscount,
    required this.subtotal,
    required this.total,
    required this.status,
    this.courier,
    this.trackingNumber,
    this.paymentMethod,
    this.paymentDeadline,
    this.paidAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'ongkir': ongkir,
      'voucher_id': voucherId,
      'voucher_discount': voucherDiscount,
      'subtotal': subtotal,
      'total': total,
      'status': status,
      'courier': courier,
      'tracking_number': trackingNumber,
      'payment_method': paymentMethod,
      'payment_deadline': paymentDeadline,
      'paid_at': paidAt,
      'created_at': createdAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      addressId: map['address_id'] as int? ?? 0,
      ongkir: map['ongkir'] as int? ?? 0,
      voucherId: map['voucher_id'] as int?,
      voucherDiscount: map['voucher_discount'] as int?,
      subtotal: map['subtotal'] as int? ?? 0,
      total: map['total'] as int? ?? 0,
      status: map['status'] as String? ?? 'menunggu_pembayaran',
      courier: map['courier'] as String?,
      trackingNumber: map['tracking_number'] as String?,
      paymentMethod: map['payment_method'] as String?,
      paymentDeadline: map['payment_deadline'] as String?,
      paidAt: map['paid_at'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case 'menunggu_pembayaran':
        return 'Menunggu Pembayaran';
      case 'diproses':
        return 'Diproses';
      case 'dikirim':
        return 'Dikirim';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
