class Voucher {
  final int? id;
  final String code;
  final String type;
  final int value;
  final int? minPurchase;
  final int? maxDiscount;
  final String validFrom;
  final String validUntil;
  final int quota;
  final int usedCount;

  Voucher({
    this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minPurchase,
    this.maxDiscount,
    required this.validFrom,
    required this.validUntil,
    this.quota = 0,
    this.usedCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'valid_from': validFrom,
      'valid_until': validUntil,
      'quota': quota,
      'used_count': usedCount,
    };
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'] as int?,
      code: map['code'] as String? ?? '',
      type: map['type'] as String? ?? 'persen',
      value: map['value'] as int? ?? 0,
      minPurchase: map['min_purchase'] as int?,
      maxDiscount: map['max_discount'] as int?,
      validFrom: map['valid_from'] as String? ?? '',
      validUntil: map['valid_until'] as String? ?? '',
      quota: map['quota'] as int? ?? 0,
      usedCount: map['used_count'] as int? ?? 0,
    );
  }

  bool get isAvailable => quota > usedCount;
}
