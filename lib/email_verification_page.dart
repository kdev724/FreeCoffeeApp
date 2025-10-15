import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'navigation_widget.dart';
import 'services/supabase_auth_service.dart';
import 'utils/responsive_helper.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _hasResent = false;
  int _resendCount = 0;
  final int _maxResends = 3;
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _listenForVerification();
    _checkIfAlreadyVerified();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Check every 3 seconds if user has verified their email
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkIfAlreadyVerified();
    });
  }

  void _checkIfAlreadyVerified() async {
    // Check if user is already verified and signed in
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.emailConfirmedAt != null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    }
  }

  void _listenForVerification() {
    // Listen for authentication state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Navigate to home page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                  ResponsiveHelper.getResponsivePadding(context, 24)),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth:
                      ResponsiveHelper.getResponsiveFontSize(context, 400),
                ),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 20)),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getResponsivePadding(context, 32)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Email Icon
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.getResponsivePadding(
                                  context, 20)),
                          decoration: BoxDecoration(
                            color: Color(0xFFC69C6D).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.email_outlined,
                            size: ResponsiveHelper.getResponsiveFontSize(
                                context, 48),
                            color: Color(0xFFC69C6D),
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 24)),

                        // Title
                        Text(
                          'Check Your Email',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 28),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),

                        // Auto-verification status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsivePadding(
                                context, 16),
                            vertical: ResponsiveHelper.getResponsivePadding(
                                context, 8),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveRadius(context, 8),
                            ),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveFontSize(
                                    context, 16),
                                height: ResponsiveHelper.getResponsiveFontSize(
                                    context, 16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.blue),
                                ),
                              ),
                              SizedBox(
                                  width: ResponsiveHelper.getResponsivePadding(
                                      context, 8)),
                              Text(
                                'Waiting for verification...',
                                style: GoogleFonts.inter(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),

                        // Subtitle
                        Text(
                          'We\'ve sent a verification link to',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 8)),

                        // Email
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsivePadding(
                                  context, 16),
                              vertical: ResponsiveHelper.getResponsivePadding(
                                  context, 12)),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            widget.email,
                            style: GoogleFonts.inter(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 24)),

                        // Instructions
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                          decoration: BoxDecoration(
                            color: Color(0xFFC69C6D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                            border: Border.all(
                                color: Color(0xFFC69C6D).withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Color(0xFFC69C6D),
                                      size: ResponsiveHelper
                                          .getResponsiveFontSize(context, 20)),
                                  SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 8)),
                                  Text(
                                    'What to do next:',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 14),
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFC69C6D),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: ResponsiveHelper.getResponsivePadding(
                                      context, 12)),
                              _buildInstructionStep(
                                  '1', 'Check your email inbox'),
                              _buildInstructionStep(
                                  '2', 'Click the verification link'),
                              _buildInstructionStep(
                                  '3', 'Return to the app and sign in'),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 24)),

                        // Resend Button
                        if (_resendCount < _maxResends) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isResending ? null : _resendEmail,
                              icon: _isResending
                                  ? SizedBox(
                                      width: ResponsiveHelper
                                          .getResponsiveFontSize(context, 20),
                                      height: ResponsiveHelper
                                          .getResponsiveFontSize(context, 20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Icon(Icons.refresh, color: Colors.white),
                              label: Text(
                                _isResending
                                    ? 'Sending...'
                                    : _hasResent
                                        ? 'Resend Email Again'
                                        : 'Resend Verification Email',
                                style: GoogleFonts.inter(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC69C6D),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        ResponsiveHelper.getResponsivePadding(
                                            context, 16)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ResponsiveHelper.getResponsiveRadius(
                                          context, 12)),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: ResponsiveHelper.getResponsivePadding(
                                  context, 16)),
                        ],

                        // Resend limit message
                        if (_resendCount >= _maxResends)
                          Container(
                            padding: EdgeInsets.all(
                                ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveRadius(
                                      context, 8)),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_outlined,
                                    color: Colors.orange.shade600,
                                    size:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 20)),
                                SizedBox(
                                    width:
                                        ResponsiveHelper.getResponsivePadding(
                                            context, 8)),
                                Expanded(
                                  child: Text(
                                    'Maximum resend attempts reached. Please check your spam folder or contact support.',
                                    style: GoogleFonts.inter(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 12),
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 24)),

                        // Back to Login Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            icon:
                                Icon(Icons.arrow_back, color: Colors.grey[600]),
                            label: Text(
                              'Back to Login',
                              style: GoogleFonts.inter(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      ResponsiveHelper.getResponsivePadding(
                                          context, 16)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                        context, 12)),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),

                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),

                        // Help Text
                        Text(
                          'Didn\'t receive the email? Check your spam folder or try resending.',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 12),
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 8)),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveFontSize(context, 24),
            height: ResponsiveHelper.getResponsiveFontSize(context, 24),
            decoration: BoxDecoration(
              color: Color(0xFFC69C6D),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 12)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Color(0xFFC69C6D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      await SupabaseAuthService.resendEmailVerification(widget.email);

      setState(() {
        _hasResent = true;
        _resendCount++;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification email sent! Please check your inbox.',
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 10)),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = 'Failed to resend email. Please try again.';

        if (error.toString().contains('Too many requests')) {
          errorMessage =
              'Too many requests. Please wait a moment before trying again.';
        } else if (error.toString().contains('Invalid email')) {
          errorMessage = 'Invalid email address.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.inter(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
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
          _isResending = false;
        });
      }
    }
  }
}
