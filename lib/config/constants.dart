class AppConstants {
  static const String appName = 'Summit App';
  static const String appTagline = 'Peralatan Pendakian Terpercaya';

  static const String dbName = 'summit_app.db';
  static const int dbVersion = 4;

  static const String placeholderImage = 'assets/images/products/placeholder.png';

  static const List<String> paymentMethods = [
    'Transfer Bank BCA',
    'Transfer Bank BNI',
    'Transfer Bank BRI',
    'Transfer Bank Mandiri',
    'GoPay',
    'OVO',
    'DANA',
    'ShopeePay',
  ];

  static const List<String> courierServices = [
    'JNE Reguler (2-3 hari)',
    'JNE YES (1 hari)',
    'J&T Reguler (2-3 hari)',
    'SiCepat Reguler (2-3 hari)',
  ];

  static const Map<String, int> ongkirFlat = {
    'JNE Reguler (2-3 hari)': 12000,
    'JNE YES (1 hari)': 25000,
    'J&T Reguler (2-3 hari)': 11000,
    'SiCepat Reguler (2-3 hari)': 10000,
  };
}
