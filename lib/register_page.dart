import 'package:flutter/material.dart';
import 'email_verification_page.dart';
import 'privacy_policy_page.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onLoginTap;
  const RegisterPage({super.key, this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicators
  double _passwordStrengthValue = 0.0;

  // Terms and conditions
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_calculatePasswordStrength);
    _fullNameFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_calculatePasswordStrength);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength() {
    final password = _passwordController.text;
    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    setState(() {
      _passwordStrengthValue = score / 6.0;
    });
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Full name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Full name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (value.length > 100) {
      return 'Email address is too long';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

    // Additional validation for password strength
    if (_passwordStrengthValue < 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please choose a stronger password for better security.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 10)),
          ),
        ),
      );
      return;
    }

    // Check terms and conditions
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and conditions to continue.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 10)),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseAuthService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (response.user != null && mounted) {
        // Navigate to email verification page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = 'Registration failed. Please try again.';

        // Handle specific error cases
        if (error.toString().contains('User already registered') ||
            error.toString().contains('already registered')) {
          errorMessage =
              'An account with this email already exists. Please try logging in instead.';
        } else if (error.toString().contains('Password should be at least')) {
          errorMessage = 'Password must be at least 6 characters long.';
        } else if (error.toString().contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (error.toString().contains('Too many requests')) {
          errorMessage =
              'Too many registration attempts. Please wait a moment before trying again.';
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
                            ResponsiveHelper.getResponsivePadding(context, 40)),
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
                      'Create an account',
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
                    // Full Name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _fullNameFocusNode.hasFocus
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          child: TextFormField(
                            key: _fullNameFieldKey,
                            controller: _fullNameController,
                            focusNode: _fullNameFocusNode,
                            onChanged: (_) => setState(() {}),
                            validator: _validateFullName,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
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
                        if (_fullNameFieldKey.currentState?.hasError == true)
                          Padding(
                            padding: EdgeInsets.only(
                                top: ResponsiveHelper.getResponsivePadding(
                                    context, 4),
                                left: ResponsiveHelper.getResponsivePadding(
                                    context, 16)),
                            child: Text(
                              _fullNameFieldKey.currentState?.errorText ?? '',
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
                            validator: _validateEmail,
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
                            validator: _validatePassword,
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
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    // Confirm Password field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: _confirmPasswordFocusNode.hasFocus
                                ? Colors.grey.shade300
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                          child: TextFormField(
                            key: _confirmPasswordFieldKey,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            obscureText: _obscureConfirmPassword,
                            onChanged: (_) => setState(() {}),
                            validator: _validateConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              errorStyle: TextStyle(height: 0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
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
                        if (_confirmPasswordFieldKey.currentState?.hasError ==
                            true)
                          Padding(
                            padding: EdgeInsets.only(
                                top: ResponsiveHelper.getResponsivePadding(
                                    context, 4),
                                left: ResponsiveHelper.getResponsivePadding(
                                    context, 16)),
                            child: Text(
                              _confirmPasswordFieldKey
                                      .currentState?.errorText ??
                                  '',
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
                    // Terms and conditions checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: Colors.black87,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(text: 'I agree to the '),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const PrivacyPolicyPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Terms and Conditions and Privacy Policy',
                                        style: TextStyle(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(
                                                  context, 14),
                                          color: Colors.black87,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    // Register button
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
                        onPressed: _isLoading ? null : _register,
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
                                'Sign up',
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
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    // Login section
                    Column(
                      children: [
                        Text(
                          "Already have an account?",
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
                          onPressed: widget.onLoginTap,
                          child: Text(
                            "Log in",
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
}
