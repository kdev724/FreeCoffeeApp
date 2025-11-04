import 'package:flutter/material.dart';
import 'home_page.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';
import 'forgot_password_page.dart';
import 'email_verification_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onRegisterTap;
  const LoginPage({super.key, this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

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
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 10)),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      ResponsiveHelper.getResponsivePadding(context, 24)),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 60)),
                    // Title
                    Image.asset(
                      'assets/images/logo.png',
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 30),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    // Subtitle
                    Text(
                      'Log in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    // Email field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _emailFocusNode.hasFocus
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          child: TextFormField(
                            key: _emailFieldKey,
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() {}),
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
                              hintText: 'Email',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(height: 0),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveHelper.getResponsivePadding(
                                        context, 16),
                                vertical: ResponsiveHelper.getResponsivePadding(
                                    context, 13),
                              ),
                            ),
                          ),
                        ),
                        if (_emailFieldKey.currentState?.hasError == true)
                          Padding(
                            padding: EdgeInsets.only(
                                top: ResponsiveHelper.getResponsivePadding(
                                    context, 4),
                                left: ResponsiveHelper.getResponsivePadding(
                                    context, 16)),
                            child: Text(
                              _emailFieldKey.currentState?.errorText ?? '',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    // Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _passwordFocusNode.hasFocus
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          child: TextFormField(
                            key: _passwordFieldKey,
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
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
                              hintText: 'Password',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(height: 0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveHelper.getResponsivePadding(
                                        context, 16),
                                vertical: ResponsiveHelper.getResponsivePadding(
                                    context, 13),
                              ),
                            ),
                          ),
                        ),
                        if (_passwordFieldKey.currentState?.hasError == true)
                          Padding(
                            padding: EdgeInsets.only(
                                top: ResponsiveHelper.getResponsivePadding(
                                    context, 4),
                                left: ResponsiveHelper.getResponsivePadding(
                                    context, 16)),
                            child: Text(
                              _passwordFieldKey.currentState?.errorText ?? '',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.black87,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF5516).withOpacity(0.9),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                height: ResponsiveHelper.getResponsiveIconSize(
                                    context, 20),
                                width: ResponsiveHelper.getResponsiveIconSize(
                                    context, 20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 24)),
                    // Separator
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 14),
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 24)),
                    // Google login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _handleGoogleSignIn();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: ResponsiveHelper.getResponsiveIconSize(
                                  context, 20),
                              width: ResponsiveHelper.getResponsiveIconSize(
                                  context, 20),
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                                width: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            Text(
                              'Log in with Google',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    // Sign up section
                    Column(
                      children: [
                        Text(
                          "Don't have an account?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 4)),
                        TextButton(
                          onPressed: widget.onRegisterTap,
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 16),
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await SupabaseAuthService.signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Google sign-in initiated. Please complete the process in your browser.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      String errorMessage = 'Google sign in failed';
      if (e.toString().contains('cancelled')) {
        errorMessage = 'Google sign in was cancelled';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('popup')) {
        errorMessage = 'Popup blocked. Please allow popups for this site';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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
