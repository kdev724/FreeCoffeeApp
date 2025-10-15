import 'package:supabase_flutter/supabase_flutter.dart';
import '../globals.dart' as globals;

class CoffeeRedemptionService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new coffee redemption
  static Future<Map<String, dynamic>> createRedemption({
    required String shippingAddress,
    String? notes,
  }) async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final profile = globals.GlobalUser.userProfile;
      if (profile == null) throw Exception('No user profile found');

      // Check if user has enough credits
      final currentCredits = profile['credits'] ?? 0.0;
      if (currentCredits < 15.0) {
        throw Exception(
            'Insufficient credits. You need 15 credits to redeem a coffee bag.');
      }

      // Create redemption record
      final redemption = {
        'user_id': user.email, // Save email instead of UUID
        'profile_id': user.id, // profile_id is the same as user_id in our case
        'credits_spent': 15.00,
        'shipping_address': shippingAddress,
        'notes': notes,
        'status': 'pending',
      };

      final response = await _supabase
          .from('coffee_redemptions')
          .insert(redemption)
          .select()
          .single();

      // Get current coffee count
      final currentCoffeeCount = profile['coffee_count'] ?? 0;
      final newCoffeeCount = currentCoffeeCount + 1;

      // Update user's profile: deduct credits and increment coffee count
      await _supabase.from('profiles').update({
        'credits': currentCredits - 15.0,
        'coffee_count': newCoffeeCount,
      }).eq('id', user.id);

      // Update local user credits and coffee count
      globals.GlobalUser.updateCredits(currentCredits - 15.0);
      globals.GlobalUser.updateCoffeeCount(newCoffeeCount);

      return response;
    } catch (error) {
      rethrow;
    }
  }

  /// Get user's redemption history
  static Future<List<Map<String, dynamic>>> getUserRedemptions() async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final userEmail = user.email;
      if (userEmail == null) throw Exception('User email is null');

      // Check if session is valid and refresh if needed
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please log in again.');
      }

      // Check if token is expired (with 5 minute buffer)
      final expiresAt = session.expiresAt;
      final now = DateTime.now();
      if (expiresAt != null) {
        final expiryTime =
            DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        if (now.isAfter(expiryTime.subtract(Duration(minutes: 5)))) {
          try {
            await _supabase.auth.refreshSession();
          } catch (refreshError) {
            throw Exception('Session expired. Please log in again.');
          }
        }
      }

      final response = await _supabase
          .from('coffee_redemptions')
          .select()
          .eq('user_id', userEmail) // Use email since that's what we store
          .order('redemption_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      rethrow;
    }
  }

  /// Get redemption by ID
  static Future<Map<String, dynamic>?> getRedemptionById(
      String redemptionId) async {
    try {
      final response = await _supabase
          .from('coffee_redemptions')
          .select()
          .eq('id', redemptionId)
          .single();

      return response;
    } catch (error) {
      print('❌ Error fetching redemption: $error');
      return null;
    }
  }

  /// Update redemption status (admin only)
  static Future<void> updateRedemptionStatus({
    required String redemptionId,
    required String status,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Check if user is admin
      final userEmail = user.email?.toLowerCase();

      if (!globals.adminEmails.contains(userEmail)) {
        throw Exception('Admin access required');
      }

      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (trackingNumber != null) {
        updates['tracking_number'] = trackingNumber;
      }

      if (notes != null) {
        updates['notes'] = notes;
      }

      await _supabase
          .from('coffee_redemptions')
          .update(updates)
          .eq('id', redemptionId);
    } catch (error) {
      rethrow;
    }
  }

  /// Get all redemptions (admin only)
  static Future<List<Map<String, dynamic>>> getAllRedemptions() async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Check if user is admin
      final userEmail = user.email?.toLowerCase();

      if (!globals.adminEmails.contains(userEmail)) {
        throw Exception('Admin access required');
      }

      final response = await _supabase
          .from('coffee_redemptions')
          .select('*, profiles(email, full_name)')
          .order('redemption_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      rethrow;
    }
  }

  /// Get redemption statistics (admin only)
  static Future<Map<String, dynamic>> getRedemptionStats() async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Check if user is admin
      final userEmail = user.email?.toLowerCase();

      if (!globals.adminEmails.contains(userEmail)) {
        throw Exception('Admin access required');
      }

      // Get total redemptions
      final totalResponse =
          await _supabase.from('coffee_redemptions').select('id');

      // Get pending redemptions
      final pendingResponse = await _supabase
          .from('coffee_redemptions')
          .select('id')
          .eq('status', 'pending');

      // Get confirmed redemptions
      final confirmedResponse = await _supabase
          .from('coffee_redemptions')
          .select('id')
          .eq('status', 'confirmed');

      // Get shipped redemptions
      final shippedResponse = await _supabase
          .from('coffee_redemptions')
          .select('id')
          .eq('status', 'shipped');

      // Get delivered redemptions
      final deliveredResponse = await _supabase
          .from('coffee_redemptions')
          .select('id')
          .eq('status', 'delivered');

      return {
        'total': totalResponse.length,
        'pending': pendingResponse.length,
        'confirmed': confirmedResponse.length,
        'shipped': shippedResponse.length,
        'delivered': deliveredResponse.length,
      };
    } catch (error) {
      rethrow;
    }
  }

  /// Cancel a redemption (user can only cancel pending ones)
  static Future<void> cancelRedemption(String redemptionId) async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Get the redemption first
      final redemption = await getRedemptionById(redemptionId);
      if (redemption == null) throw Exception('Redemption not found');

      // Check if user owns this redemption
      if (redemption['user_id'] != user.id) {
        throw Exception('You can only cancel your own redemptions');
      }

      // Check if redemption can be cancelled
      if (redemption['status'] != 'pending') {
        throw Exception('Only pending redemptions can be cancelled');
      }

      // Cancel the redemption
      await _supabase.from('coffee_redemptions').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', redemptionId);

      // Refund the credits
      final profile = globals.GlobalUser.userProfile;
      if (profile != null) {
        final currentCredits = profile['credits'] ?? 0.0;
        globals.GlobalUser.updateCredits(currentCredits + 15.0);

        // Update in database
        await _supabase
            .from('profiles')
            .update({'credits': currentCredits + 15.0}).eq('id', user.id);
      }
    } catch (error) {
      rethrow;
    }
  }
}
