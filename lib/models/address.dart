class Address {
  final int? id;
  final int userId;
  final String label;
  final String recipientName;
  final String recipientPhone;
  final String fullAddress;
  final String city;
  final String subdistrict;
  final String postalCode;
  final bool isPrimary;

  Address({
    this.id,
    required this.userId,
    required this.label,
    required this.recipientName,
    required this.recipientPhone,
    required this.fullAddress,
    required this.city,
    required this.subdistrict,
    required this.postalCode,
    this.isPrimary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'full_address': fullAddress,
      'city': city,
      'subdistrict': subdistrict,
      'postal_code': postalCode,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      label: map['label'] as String? ?? '',
      recipientName: map['recipient_name'] as String? ?? '',
      recipientPhone: map['recipient_phone'] as String? ?? '',
      fullAddress: map['full_address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      subdistrict: map['subdistrict'] as String? ?? '',
      postalCode: map['postal_code'] as String? ?? '',
      isPrimary: (map['is_primary'] as int?) == 1,
    );
  }
}
