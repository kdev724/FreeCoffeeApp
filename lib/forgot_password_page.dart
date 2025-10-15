import 'package:flutter/material.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseAuthService.resetPassword(_emailController.text.trim());

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Email Sent!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We\'ve sent a password reset link to:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _emailController.text.trim(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please check your email and follow the instructions to reset your password.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and go back to login page
              Navigator.of(context).pop(); // Close dialog
              // Use a small delay to ensure dialog is closed before navigating
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // Go back to login page
                }
              });
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(
          _getErrorMessage(error),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('User not found')) {
      return 'No account found with this email address.';
    } else if (error.contains('Too many requests')) {
      return 'Too many reset attempts. Please wait a few minutes before trying again.';
    } else {
      return 'Failed to send reset email. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isLargeScreen(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey[700],
          ),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? screenWidth * 0.2 : 24.0,
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 400 : double.infinity,
              ),
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green[200]!,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 60,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ve sent password reset instructions to:',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text.trim(),
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'Didn\'t receive the email?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your spam folder or try again in a few minutes.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
                _emailController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Another Email',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 40,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No worries! Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _sendResetEmail(),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Send Reset Email Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Send Reset Email',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Back to Login
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Remember your password? Sign in',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Help Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.orange[600],
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you\'re having trouble resetting your password, please contact our support team.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                  color: Colors.orange[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
