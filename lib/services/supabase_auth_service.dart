import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import '../config/supabase_config.dart';
import '../globals.dart';

class SupabaseAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Check network connectivity
  static Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Test DNS resolution for Supabase hostname
  static Future<bool> _testSupabaseDNS() async {
    try {
      final hostname = Uri.parse(SupabaseConfig.supabaseUrl).host;

      final addresses = await InternetAddress.lookup(hostname);
      if (addresses.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Initialize Supabase
  static Future<void> initialize() async {
    // Check network connectivity first
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      throw Exception(
          'No network connection available. Please check your internet connection.');
    }

    // Test DNS resolution
    final dnsWorking = await _testSupabaseDNS();
    if (!dnsWorking) {
      throw Exception(
          'Cannot resolve Supabase hostname. Please check your DNS settings or try again later.');
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
    } catch (e) {
      if (e.toString().contains('No address associated with hostname')) {
        throw Exception(
            'DNS resolution failed for Supabase. Please check your internet connection and try again.');
      }
      rethrow;
    }

    // Set up auth state listener
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // User signed in
        GlobalUser.setCurrentUser(session.user);
        _loadUserProfile(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out
        GlobalUser.clearUser();
      }
    });
  }

  // Load user profile from database
  static Future<void> _loadUserProfile(User user) async {
    try {
      final profile =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      GlobalUser.setUserProfile(profile);
    } catch (error) {
      // Create profile if it doesn't exist
    }
  }

  // Public method to load user profile by user ID
  static Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final profile =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return profile;
    } catch (error) {
      return null;
    }
  }

  // Public method to create user profile
  static Future<void> createUserProfile(User user) async {
    try {
      final profile = {
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User',
        'credits': 0.0,
        'coffee_count': 0,
        'role': 'user', // Default role for new users
      };

      // Try to create profile with retry mechanism
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await _supabase.from('profiles').upsert(profile);
          return;
        } catch (error) {
          retryCount++;

          if (retryCount >= maxRetries) {
            rethrow;
          }

          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return GlobalUser.currentUser;
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return GlobalUser.isLoggedIn;
  }

  // Email and Password Registration
  static Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
        emailRedirectTo:
            'https://app.freecoffeestore.com/email_verification_success.html',
      );

      if (response.user != null) {
        // Set global user immediately for email confirmation flow
        GlobalUser.setCurrentUser(response.user);
        // Note: Profile will be created when user confirms email and signs in
      }

      return response;
    } catch (error) {
      rethrow;
    }
  }

  // Email and Password Login
  static Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      GlobalUser.setLoading(true);

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        GlobalUser.setCurrentUser(response.user);
        await _loadUserProfile(response.user!);
      }

      return response;
    } catch (error) {
      rethrow;
    } finally {
      GlobalUser.setLoading(false);
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      GlobalUser.clearUser();
    } catch (error) {
      rethrow;
    }
  }

  // Resend Email Verification
  static Future<void> resendEmailVerification(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (error) {
      print('Resend email verification error: $error');
      rethrow;
    }
  }

  // Password Reset
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://login-callback?type=recovery',
      );
    } catch (error) {
      rethrow;
    }
  }

  // Update Password
  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (error) {
      rethrow;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    return GlobalUser.userProfile;
  }

  // Update user profile
  static Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    try {
      final user = GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      await _supabase.from('profiles').upsert(profile).eq('id', user.id);

      GlobalUser.setUserProfile(profile);
    } catch (error) {
      rethrow;
    }
  }

  // Update user credits
  static Future<void> updateUserCredits(double newCredits) async {
    try {
      final user = GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final profile = GlobalUser.userProfile ?? {};
      profile['credits'] = newCredits;
      profile['last_update'] = DateTime.now().toIso8601String();

      await _supabase.from('profiles').upsert(profile).eq('id', user.id);

      GlobalUser.updateCredits(newCredits);
    } catch (error) {
      rethrow;
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Check if current user is admin
  static bool isAdmin() {
    final profile = GlobalUser.userProfile;
    return profile?['role'] == 'admin';
  }

  // Get current user role
  static String getUserRole() {
    final profile = GlobalUser.userProfile;
    return profile?['role'] ?? 'user';
  }

  // Check if user has specific role
  static bool hasRole(String role) {
    return getUserRole() == role;
  }

  // Update user role (admin only)
  static Future<void> updateUserRole(String userId, String newRole) async {
    try {
      if (!isAdmin()) {
        throw Exception('Only admins can update user roles');
      }

      await _supabase
          .from('profiles')
          .update({'role': newRole}).eq('id', userId);

      print('✅ User role updated: $userId -> $newRole');
    } catch (error) {
      print('❌ Error updating user role: $error');
      rethrow;
    }
  }

  // Google Sign In
  static Future<void> signInWithGoogle() async {
    try {
      GlobalUser.setLoading(true);
      print('🔄 Starting Google OAuth flow...');

      // Use Supabase's built-in OAuth flow for Google
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      print('✅ Google OAuth response: $response');
      print('🔄 Waiting for deep link callback...');

      // For mobile apps, the OAuth flow should handle the redirect automatically
      // The deep link configuration in AndroidManifest.xml and Info.plist will handle the redirect
    } catch (error) {
      print('❌ Google OAuth error: $error');
      rethrow;
    } finally {
      GlobalUser.setLoading(false);
    }
  }

  // Sign out from Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      // Don't rethrow as this is not critical
    }
  }

  // Delete user account
  static Future<void> deleteUserAccount() async {
    try {
      final user = GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      print('🗑️ Starting account deletion for user: ${user.email}');

      // First delete the user profile from the profiles table
      try {
        await _supabase.from('profiles').delete().eq('id', user.id);
        print('✅ User profile deleted from database');
      } catch (error) {
        print('⚠️ Error deleting user profile: $error');
        // Continue with account deletion even if profile deletion fails
      }

      // Delete user redemptions if they exist
      try {
        await _supabase
            .from('coffee_redemptions')
            .delete()
            .eq('user_id', user.id);
        print('✅ User redemptions deleted from database');
      } catch (error) {
        print('⚠️ Error deleting user redemptions: $error');
        // Continue with account deletion
      }

      // Try to call a server-side function to delete the user account
      bool userDeletedFromAuth = false;
      try {
        final response = await _supabase.functions.invoke(
          'delete-user-account',
          body: {'user_id': user.id},
        );

        if (response.status == 200) {
          print(
              '✅ User account deleted from Supabase Auth via server function');
          userDeletedFromAuth = true;
        } else {
          print('⚠️ Server function returned status: ${response.status}');
        }
      } catch (error) {
        print('⚠️ Error calling delete-user-account function: $error');
        print(
            'ℹ️ Server function may not be deployed, continuing with data deletion only');
      }

      // If server function failed or isn't available, we'll still proceed
      // The user data is already deleted from the database
      if (!userDeletedFromAuth) {
        print('ℹ️ User data deleted from database. User will be signed out.');
        print(
            'ℹ️ Note: The user account in Supabase Auth will remain but will be inactive.');
      }

      // Sign out the user (this will clear the session)
      await _supabase.auth.signOut();

      // Clear local user data
      GlobalUser.clearUser();

      print('✅ Account deletion process completed');
    } catch (error) {
      print('❌ Error deleting user account: $error');
      rethrow;
    }
  }
}
