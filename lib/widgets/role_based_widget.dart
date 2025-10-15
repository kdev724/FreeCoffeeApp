import 'package:flutter/material.dart';
import '../services/supabase_auth_service.dart';

class RoleBasedWidget extends StatelessWidget {
  final Widget child;
  final String requiredRole;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.child,
    required this.requiredRole,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = SupabaseAuthService.getUserRole();

    if (userRole == requiredRole || userRole == 'admin') {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (SupabaseAuthService.isAdmin()) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

class UserOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const UserOnlyWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = SupabaseAuthService.getUserRole();

    if (userRole == 'user' || userRole == 'admin') {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

class RoleBasedBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, String role) builder;
  final Widget? fallback;

  const RoleBasedBuilder({
    super.key,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = SupabaseAuthService.getUserRole();
    return builder(context, userRole);
  }
}

class AdminGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (SupabaseAuthService.isAdmin()) {
      return child;
    }

    return fallback ??
        Scaffold(
          appBar: AppBar(
            title: const Text('Access Denied'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You need admin privileges to access this page.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
