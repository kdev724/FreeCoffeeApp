import 'package:flutter/material.dart';
import 'home_page.dart';
import 'widgets/social_login_buttons.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';
import 'forgot_password_page.dart';
import 'email_verification_page.dart';
import 'privacy_policy_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onRegisterTap;
  const LoginPage({super.key, this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseAuthService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = 'Login failed. Please try again.';

        // Handle specific error cases
        if (error.toString().contains('Invalid login credentials') ||
            error.toString().contains('invalid_credentials')) {
          errorMessage =
              'Invalid email or password. Please check your credentials and try again.';
        } else if (error.toString().contains('Email not confirmed')) {
          errorMessage =
              'Please check your email and confirm your account before logging in.';

          // Show resend email option
          _showEmailNotConfirmedDialog();
        } else if (error.toString().contains('Too many requests')) {
          errorMessage =
              'Too many login attempts. Please wait a moment before trying again.';
        } else if (error.toString().contains('User not found')) {
          errorMessage =
              'No account found with this email. Please check your email or create a new account.';
        } else if (error.toString().contains('Network error') ||
            error.toString().contains('Connection failed')) {
          errorMessage =
              'Connection error. Please check your internet connection and try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE7),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 30),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.brown.shade100,
                          child: Icon(Icons.coffee,
                              color: Colors.brown.shade700, size: 28),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Coffee Credit',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 22),
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon:
                                const Icon(Icons.email_outlined, size: 18),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.brown.withOpacity(0.05),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_outline, size: 18),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.brown.withOpacity(0.05),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 11),
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text('Login',
                                    style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 15),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ),
                        ),
                        SocialLoginButtons(
                          onLoginSuccess: (userName) {
                            // Show a message that Google sign-in was initiated
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Google sign-in initiated. Please complete the process in your browser.'),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          onLoginError: (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 13),
                                )),
                            TextButton(
                              onPressed: widget.onRegisterTap,
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 13),
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Privacy Policy Link
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Privacy Policy & Terms",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 12),
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailNotConfirmedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Email Not Verified',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Your email address has not been verified yet. Please check your email and click the verification link, or resend the verification email.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailVerificationPage(
                      email: _emailController.text.trim(),
                    ),
                  ),
                );
              },
              child: Text('Resend Email'),
            ),
          ],
        );
      },
    );
  }
}
