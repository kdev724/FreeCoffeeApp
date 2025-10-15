import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../globals.dart' as globals;

class AdminAuth {
  // Admin email addresses (you can modify this list)
  // Check if current user is admin
  static bool isAdmin() {
    final user = globals.GlobalUser.currentUser;
    if (user == null) return false;

    return globals.adminEmails.contains(user.email?.toLowerCase());
  }

  // Get admin status with user parameter
  static bool isUserAdmin(User user) {
    return globals.adminEmails.contains(user.email?.toLowerCase());
  }

  // Show admin access denied dialog
  static void showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content:
            const Text('You do not have permission to access the admin panel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show admin login dialog
  static Future<bool> showAdminLoginDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isAdmin = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              isAdmin = false;
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response =
                    await Supabase.instance.client.auth.signInWithPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                if (response.user != null && isUserAdmin(response.user!)) {
                  Navigator.of(context).pop();
                  isAdmin = true;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid admin credentials'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Login failed: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );

    return isAdmin;
  }
}
