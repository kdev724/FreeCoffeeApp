import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = GlobalUser.currentUser;
    final userProfile = GlobalUser.userProfile;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your profile'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: ResponsiveHelper.getResponsivePadding(context, 5),
            bottom: ResponsiveHelper.getResponsivePadding(context, 16),
            left: ResponsiveHelper.getResponsivePadding(context, 16),
            right: ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius:
                              ResponsiveHelper.getResponsiveRadius(context, 30),
                          backgroundColor: Color(0xFFFF5516),
                          child: Text(
                            _getInitials(
                                userProfile?['full_name'] ?? user.email ?? 'U'),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 24),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userProfile?['full_name'] ?? 'User',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email ?? 'No email',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 16),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Credits',
                          GlobalUser.getCredits().toStringAsFixed(1),
                          Icons.coffee,
                        ),
                        _buildStatItem(
                          'Coffee Count',
                          '${GlobalUser.getCoffeeCount()}',
                          Icons.local_cafe,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // Account Actions
            Text(
              'Account Actions',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),

            // Sign Out Button
            _buildActionButton(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: _signOut,
              color: Colors.orange,
            ),

            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),

            // Delete Account Button
            _buildActionButton(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              onTap: _showDeleteAccountDialog,
              color: Colors.red,
            ),

            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // App Info
            Text(
              'App Information',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('App Version', '1.0.0'),
                    _buildInfoRow(
                        'User Name', userProfile?['full_name'] ?? 'Not set'),
                    _buildInfoRow('Email', user.email ?? 'No email'),
                    _buildInfoRow('Account Status', 'Active'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon,
            size: ResponsiveHelper.getResponsiveFontSize(context, 32),
            color: Color(0xFFFF5516)),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset:
                Offset(0, ResponsiveHelper.getResponsivePadding(context, 4)),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset:
                Offset(0, ResponsiveHelper.getResponsivePadding(context, 1)),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: color,
            size: ResponsiveHelper.getResponsiveFontSize(context, 24)),
        title: Text(title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            )),
        subtitle: Text(subtitle,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            )),
        trailing: Icon(Icons.arrow_forward_ios,
            size: ResponsiveHelper.getResponsiveFontSize(context, 24)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsivePadding(context, 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _signOut() async {
    try {
      // Clear shared preferences (optional)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out via centralized auth service; AuthWrapper will redirect
      await SupabaseAuthService.signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {}
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
              )),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and will permanently remove:\n\n'
            '• All your profile data\n'
            '• Your reward credits\n'
            '• Survey completion history\n'
            '• Coffee shop preferences\n\n'
            'This action is irreversible.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          contentPadding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 20)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 14),
                  )),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete Account',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 14),
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Final Confirmation',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
                )),
            content: Text(
              'This is your final warning. Deleting your account will:\n\n'
              '• Remove all your data permanently\n'
              '• Cancel any pending rewards\n'
              '• End your access to the app\n\n'
              'Type "DELETE" to confirm:',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            contentPadding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 20)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 14),
                    )),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Confirm',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 14),
                    )),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      // Delete the account
      await SupabaseAuthService.deleteUserAccount();

      if (mounted) {
        // Clear shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Account deleted successfully. You have been signed out.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // No manual navigation needed; AuthWrapper listens to auth state
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $error',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                )),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {}
    }
  }
}
