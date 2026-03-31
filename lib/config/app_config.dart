class AppConfig {
  static const String appName = 'AfroCards Admin';
  static const String appVersion = '1.0.0';
  
  // API Configuration - À ajuster selon ton environnement
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Storage Keys
  static const String tokenKey = 'admin_token';
  static const String userKey = 'admin_user';
}
