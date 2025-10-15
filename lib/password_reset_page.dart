import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/utils/responsive_helper.dart';

class PasswordResetPage extends StatefulWidget {
  final String code;
  final VoidCallback? onSuccess;

  const PasswordResetPage({super.key, required this.code, this.onSuccess});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Password strength
  int _passwordStrength = 0;
  String _strengthText = '';
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    print('Password reset code: ${widget.code}');
  }

  void _calculatePasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    setState(() {
      _passwordStrength = strength;

      switch (strength) {
        case 0:
        case 1:
          _strengthText = 'Very Weak';
          _strengthColor = Colors.red;
          break;
        case 2:
          _strengthText = 'Weak';
          _strengthColor = Colors.orange;
          break;
        case 3:
          _strengthText = 'Fair';
          _strengthColor = Colors.yellow[700]!;
          break;
        case 4:
          _strengthText = 'Good';
          _strengthColor = Colors.lightGreen;
          break;
        case 5:
          _strengthText = 'Strong';
          _strengthColor = Colors.green;
          break;
      }
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('Starting password reset with code: ${widget.code}');

      // Step 1: Exchange the PKCE code for a session
      await Supabase.instance.client.auth.exchangeCodeForSession(widget.code);

      print('Code exchanged successfully, session established');

      // Step 2: Update the password
      final updateResponse = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      if (updateResponse.user == null) {
        throw Exception('Failed to update password. Please try again.');
      }

      print('Password updated successfully');

      setState(() {
        _successMessage =
            'Password updated successfully! You are now signed in.';
      });

      // Auto-redirect after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          // Call the success callback to go back to login
          widget.onSuccess?.call();
        }
      });
    } catch (error) {
      print('Password reset error: $error');
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4513)),
            onPressed: () => widget.onSuccess?.call(),
          ),
          title: const Text(
            'Reset Password',
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsiveEdgeInsets(
              context,
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    ResponsiveHelper.getResponsivePadding(
                        context, 48), // 24*2 for padding
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),

                    // Logo
                    Center(
                      child: Container(
                        width:
                            ResponsiveHelper.getResponsivePadding(context, 80),
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 80),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B4513), Color(0xFFD2691E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '☕',
                            style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 32),
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 30)),

                    Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 10)),

                    const Text(
                      'Enter a strong password for your account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 30)),

                    // Error/Success Messages
                    if (_errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsivePadding(context, 12)),
                        margin: EdgeInsets.only(
                            bottom: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(context, 8)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),

                    if (_successMessage != null)
                      Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsivePadding(context, 12)),
                        margin: EdgeInsets.only(
                            bottom: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[200]!),
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(context, 8)),
                        ),
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),

                    // New Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _calculatePasswordStrength,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(
                                  context, 12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(
                                  context, 12)),
                          borderSide: BorderSide(color: Color(0xFF8B4513)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain uppercase letter';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Password must contain lowercase letter';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain a number';
                        }
                        if (!value
                            .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                          return 'Password must contain a special character';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),

                    // Password Strength Indicator
                    if (_passwordController.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordStrength / 5,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_strengthColor),
                            ),
                          ),
                          SizedBox(
                              width: ResponsiveHelper.getResponsivePadding(
                                  context, 12)),
                          Text(
                            _strengthText,
                            style: TextStyle(
                              color: _strengthColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(
                              context, 16)),
                    ],

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your new password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(
                                  context, 12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(
                                  context, 12)),
                          borderSide: BorderSide(color: Color(0xFF8B4513)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Reset Password Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(
                                  context, 12)),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: ResponsiveHelper.getResponsivePadding(
                                  context, 20),
                              width: ResponsiveHelper.getResponsivePadding(
                                  context, 20),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),

                    // Back to Login
                    TextButton(
                      onPressed: () => widget.onSuccess?.call(),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Color(0xFF8B4513),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
