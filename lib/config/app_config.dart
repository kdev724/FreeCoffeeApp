class AppConfig {
  // Coffee Shop Website URL
  static const String coffeeShopUrl = 'https://freecoffeestore.com';

  // App Information
  static const String appName = 'Free Coffee App';
  static const String appVersion = '1.0.0';
  static const String appFont = 'Inter';

  // Feature Flags
  static const bool enableCoffeeShop = true;
  static const bool enableSurveys = true;
  static const bool enableAds = true;

  // URLs
  static const String privacyPolicyUrl =
      'https://app.freecoffeestore.com/privacy_policy';
  static const String termsOfServiceUrl =
      'https://app.freecoffeestore.com/terms_of_service';
  static const String supportEmail = 'info@freecoffeestore.com';

  // Test Device IDs for AdMob
  // Add your device IDs here when you see them in console logs
  static const List<String> testDeviceIds = [
    'EMULATOR', // Android emulator
    'SIMULATOR', // iOS simulator
    'B84142DE4463E6F021952BDC2FD14D62', // Your device ID
    // Add more device IDs here when you see them in console logs
  ];
}
