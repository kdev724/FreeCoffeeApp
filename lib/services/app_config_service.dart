import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Cache for configuration values
  static Map<String, dynamic> _configCache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get all app configuration values
  static Future<Map<String, dynamic>> getAppConfig() async {
    try {
      // Check if cache is still valid
      if (_configCache.isNotEmpty &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiry) {
        return _configCache;
      }

      final response = await _supabase.from('app_config').select('*').single();

      _configCache = response;
      _lastCacheUpdate = DateTime.now();

      return response;
    } catch (error) {
      print('❌ Error fetching app config: $error');
      // Return default values if config doesn't exist
      return _getDefaultConfig();
    }
  }

  /// Get a specific configuration value
  static Future<dynamic> getConfigValue(String key) async {
    final config = await getAppConfig();
    return config[key];
  }

  /// Update a configuration value
  static Future<void> updateConfigValue(String key, dynamic value) async {
    try {
      await _supabase.from('app_config').upsert({
        'id': 1, // Single config record
        key: value,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update cache
      _configCache[key] = value;
      _lastCacheUpdate = DateTime.now();

      print('✅ Updated config: $key = $value');
    } catch (error) {
      print('❌ Error updating config: $error');
      rethrow;
    }
  }

  /// Get ads credit earning percentage
  static Future<double> getAdsCreditEarningPercentage() async {
    final percentage = await getConfigValue('ads_credit_earning_percentage');
    return percentage?.toDouble() ?? 0.1; // Default to 10% if not set
  }

  /// Get survey credit earning percentage
  static Future<double> getSurveyCreditEarningPercentage() async {
    final percentage = await getConfigValue('survey_credit_earning_percentage');
    return percentage?.toDouble() ?? 0.1; // Default to 10% if not set
  }

  static Future<bool> isTestMode() async {
    final test_mode = await getConfigValue('test_mode');
    return test_mode; // Default to false if not set
  }

  /// Get credit earning percentage (legacy method for backward compatibility)
  static Future<double> getCreditEarningPercentage() async {
    final percentage = await getConfigValue('credit_earning_percentage');
    return percentage?.toDouble() ?? 0.1; // Default to 10% if not set
  }

  /// Get ad earning multiplier
  static Future<double> getAdEarningMultiplier() async {
    final multiplier = await getConfigValue('ad_earning_multiplier');
    return multiplier?.toDouble() ?? 1.0; // Default to 1x if not set
  }

  /// Get survey earning multiplier
  static Future<double> getSurveyEarningMultiplier() async {
    final multiplier = await getConfigValue('survey_earning_multiplier');
    return multiplier?.toDouble() ?? 1.0; // Default to 1x if not set
  }

  /// Get daily check-in bonus
  static Future<double> getDailyCheckInBonus() async {
    final bonus = await getConfigValue('daily_checkin_bonus');
    return bonus?.toDouble() ?? 1.0; // Default to 1 credit if not set
  }

  /// Get referral bonus
  static Future<double> getReferralBonus() async {
    final bonus = await getConfigValue('referral_bonus');
    return bonus?.toDouble() ?? 5.0; // Default to 5 credits if not set
  }

  /// Get minimum redemption amount
  static Future<double> getMinimumRedemptionAmount() async {
    final amount = await getConfigValue('minimum_redemption_amount');
    return amount?.toDouble() ?? 15.0; // Default to 15 credits if not set
  }

  /// Get maximum daily earning limit
  static Future<double> getMaxDailyEarningLimit() async {
    final limit = await getConfigValue('max_daily_earning_limit');
    return limit?.toDouble() ?? 50.0; // Default to 50 credits if not set
  }

  /// Get app maintenance mode status
  static Future<bool> getMaintenanceMode() async {
    final maintenance = await getConfigValue('maintenance_mode');
    return maintenance == true;
  }

  /// Get app version info
  static Future<String> getAppVersion() async {
    final version = await getConfigValue('app_version');
    return version?.toString() ?? '1.0.0';
  }

  /// Get feature flags
  static Future<Map<String, bool>> getFeatureFlags() async {
    final flags = await getConfigValue('feature_flags');
    if (flags is Map<String, dynamic>) {
      return flags.map((key, value) => MapEntry(key, value == true));
    }
    return _getDefaultFeatureFlags();
  }

  /// Check if a feature is enabled
  static Future<bool> isFeatureEnabled(String featureName) async {
    final flags = await getFeatureFlags();
    return flags[featureName] ?? false;
  }

  /// Clear cache (force refresh on next request)
  static void clearCache() {
    _configCache.clear();
    _lastCacheUpdate = null;
  }

  /// Get default configuration values
  static Map<String, dynamic> _getDefaultConfig() {
    return {
      'id': 1,
      'credit_earning_percentage': 0.1, // 10% (legacy)
      'ads_credit_earning_percentage': 0.1, // 10%
      'survey_credit_earning_percentage': 0.1, // 10%
      'ad_earning_multiplier': 1.0,
      'survey_earning_multiplier': 1.0,
      'daily_checkin_bonus': 1.0,
      'referral_bonus': 5.0,
      'minimum_redemption_amount': 15.0,
      'max_daily_earning_limit': 50.0,
      'maintenance_mode': false,
      'app_version': '1.0.0',
      'feature_flags': _getDefaultFeatureFlags(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get default feature flags
  static Map<String, bool> _getDefaultFeatureFlags() {
    return {
      'daily_checkin_enabled': true,
      'referral_system_enabled': true,
      'achievement_system_enabled': true,
      'video_ads_enabled': true,
      'survey_system_enabled': true,
      'redemption_system_enabled': true,
      'notifications_enabled': true,
      'analytics_enabled': true,
    };
  }

  /// Initialize default configuration (run once)
  static Future<void> initializeDefaultConfig() async {
    try {
      // Check if config already exists
      final existingConfig = await _supabase
          .from('app_config')
          .select('id')
          .eq('id', 1)
          .maybeSingle();

      if (existingConfig == null) {
        // Create default configuration
        await _supabase.from('app_config').insert(_getDefaultConfig());

        print('✅ Default app configuration created');
      }
    } catch (error) {
      print('❌ Error initializing default config: $error');
    }
  }
}
