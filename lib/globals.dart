library;

import 'package:supabase_flutter/supabase_flutter.dart';

// Global variables for the app
bool isConnected = false;

final adminEmails = [
  'serhiiarchieve@gmail.com',
  'bohdanmotrych8@gmail.com',
  'info@freecoffeestore.com',
  'ScottSalter@gmail.com',
  'scottsalter@gmail.com',
  'fernandolaza80@gmail.com'
];

// Global user management
class GlobalUser {
  static User? _currentUser;
  static Map<String, dynamic>? _userProfile;
  static bool _isLoading = false;

  // Get current user
  static User? get currentUser => _currentUser;

  // Get user profile
  static Map<String, dynamic>? get userProfile => _userProfile;

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  // Check if loading
  static bool get isLoading => _isLoading;

  // Set current user
  static void setCurrentUser(User? user) {
    _currentUser = user;
  }

  // Set user profile
  static void setUserProfile(Map<String, dynamic>? profile) {
    _userProfile = profile;
  }

  // Set loading state
  static void setLoading(bool loading) {
    _isLoading = loading;
  }

  // Get user display name
  static String getDisplayName() {
    if (_userProfile != null && _userProfile!['full_name'] != null) {
      return _userProfile!['full_name'];
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email!;
    }
    return 'User';
  }

  // Get user email
  static String? getEmail() {
    return _currentUser?.email;
  }

  // Get user credits
  static double getCredits() {
    if (_userProfile != null && _userProfile!['credits'] != null) {
      return (_userProfile!['credits'] as num).toDouble();
    }
    return 0.0;
  }

  // Update user credits
  static void updateCredits(double newCredits) {
    if (_userProfile != null) {
      _userProfile!['credits'] = newCredits;
    }
  }

  // Get user coffee count
  static int getCoffeeCount() {
    if (_userProfile != null && _userProfile!['coffee_count'] != null) {
      return (_userProfile!['coffee_count'] as num).toInt();
    }
    return 0;
  }

  // Update user coffee count
  static void updateCoffeeCount(int newCoffeeCount) {
    if (_userProfile != null) {
      _userProfile!['coffee_count'] = newCoffeeCount;
    }
  }

  // Clear user data (for logout)
  static void clearUser() {
    _currentUser = null;
    _userProfile = null;
    _isLoading = false;
  }

  // Refresh user data from Supabase
  static Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    setLoading(true);
    try {
      // Get fresh profile data
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', _currentUser!.id)
          .single();

      setUserProfile(profile);
    } catch (error) {
    } finally {
      setLoading(false);
    }
  }
}
