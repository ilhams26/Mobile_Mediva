class ApiConfig {
  ApiConfig._();

  // Environment
  // VPS:   "https://kelompok9.my.id"
  // Lokal: "http://10.0.2.2:8000"
  // Ngrok: "https://deon-experimental-dalton.ngrok-free.dev"
  static const String host = 'https://deon-experimental-dalton.ngrok-free.dev';

  /// Base URL untuk semua endpoint REST API.
  static const String baseUrl = '$host/api';

  /// Base URL untuk mengakses file di Laravel storage.
  static const String storageUrl = '$host/storage';

  /// Key yang digunakan untuk menyimpan JWT token di SharedPreferences.
  static const String tokenKey = 'mediva_token';

  /// Key yang digunakan untuk menyimpan data keranjang di SharedPreferences.
  static const String cartKey = 'mediva_cart';
}
