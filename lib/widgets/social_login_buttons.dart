import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../services/supabase_auth_service.dart';

class SocialLoginButtons extends StatelessWidget {
  final Function(String) onLoginSuccess;
  final Function(String) onLoginError;

  const SocialLoginButtons({
    super.key,
    required this.onLoginSuccess,
    required this.onLoginError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
        Text(
          'Or continue with',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 14)),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                onPressed: () => _handleGoogleSignIn(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await SupabaseAuthService.signInWithGoogle();

      // The auth state change listener will handle the success case
      // We just need to show a loading message
      onLoginSuccess('Google sign in initiated');
    } catch (e) {
      String errorMessage = 'Google sign in failed';

      if (e.toString().contains('cancelled')) {
        errorMessage = 'Google sign in was cancelled';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('popup')) {
        errorMessage = 'Popup blocked. Please allow popups for this site';
      }

      onLoginError(errorMessage);
    }
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: ResponsiveHelper.getResponsiveEdgeInsets(context,
            horizontal: 0, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, 10)),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        elevation: 1,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ResponsiveHelper.getResponsiveIconSize(context, 25),
            color: textColor,
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 6)),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
