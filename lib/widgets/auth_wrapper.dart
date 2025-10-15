import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login_page.dart';
import '../navigation_widget.dart';
import '../globals.dart' as globals;
import '../services/supabase_auth_service.dart';

class AuthWrapper extends StatefulWidget {
  final VoidCallback? onRegisterTap;

  const AuthWrapper({super.key, this.onRegisterTap});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            // User is authenticated - set global user data
            _setGlobalUserData(session.user);
            return const Home();
          } else {
            // User is not authenticated - clear global user data
            globals.GlobalUser.clearUser();
            return LoginPage(onRegisterTap: widget.onRegisterTap);
          }
        }

        // Loading state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _setGlobalUserData(User user) async {
    // Set the current user
    globals.GlobalUser.setCurrentUser(user);

    // Load and set the user profile
    try {
      final profile = await SupabaseAuthService.loadUserProfile(user.id);
      if (profile != null) {
        globals.GlobalUser.setUserProfile(profile);
        print('✅ Global user data set from auth state: ${user.email}');
      } else {
        // Profile doesn't exist, create it
        print(
            '⚠️ User profile not found, creating new profile for: ${user.email}');
        await SupabaseAuthService.createUserProfile(user);
        // Try loading again
        final newProfile = await SupabaseAuthService.loadUserProfile(user.id);
        globals.GlobalUser.setUserProfile(newProfile);
        print('✅ New user profile created and loaded: ${user.email}');
      }
    } catch (error) {
      print('❌ Error loading user profile in auth wrapper: $error');
      // Even if profile loading fails, we still have the user
      globals.GlobalUser.setUserProfile(null);
    }
  }
}
