import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'services/supabase_auth_service.dart';
import 'widgets/auth_wrapper.dart';
import 'register_page.dart';
import 'password_reset_page.dart';
import 'utils/responsive_helper.dart';
import 'utils/network_diagnostics.dart';
import 'consent_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase and Auth Service
    await SupabaseAuthService.initialize();
    runApp(const FreeCoffeeApp());
  } catch (e) {
    // Run app with error handling
    runApp(MaterialApp(
      home: ErrorScreen(error: e.toString()),
    ));
  }
}

/// An example app that loads a rewarded interstitial ad.
class FreeCoffeeApp extends StatefulWidget {
  const FreeCoffeeApp({super.key});

  @override
  FreeCoffeeAppState createState() => FreeCoffeeAppState();
}

class FreeCoffeeAppState extends State<FreeCoffeeApp> {
  final _consentManager = ConsentManager();
  RewardedInterstitialAd? _rewardedInterstitialAd;
  final _appLinks = AppLinks();

  String _currentPage = 'login';
  String? _resetCode;

  void _goTo(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _handlePasswordReset(String code) {
    setState(() {
      _resetCode = code;
      _currentPage = 'password-reset';
    });
  }

  @override
  void initState() {
    super.initState();

    _consentManager.gatherConsent((consentGatheringError) {
      if (consentGatheringError != null) {
        // Consent not obtained in current session.
        debugPrint(
          "${consentGatheringError.errorCode}: ${consentGatheringError.message}",
        );
      }
    });

    // Set up deep link listener
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle app links while the app is already started - it should be
    // handled inside the `initState` function
    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    }, onError: (err) {
      // Handle exception: AppLinksException, UriFormatException, etc.
      print('Deep link error: $err');
    });

    // Note: For initial app launch deep links, we'll rely on the stream listener
    // The app_links package handles this automatically when the app is launched
  }

  void _handleIncomingLink(Uri uri) {
    print('Received deep link: $uri');

    // Check if this is a Supabase deep link
    if (uri.scheme == 'io.supabase.flutter') {
      final code = uri.queryParameters['code'];
      final type = uri.queryParameters['type'];
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      print(
          'Deep link params - code: $code, type: $type, access_token: ${accessToken != null ? 'present' : 'null'}');

      // Handle password reset
      if (type == 'recovery' && code != null && code.isNotEmpty) {
        print('Password reset code detected: $code');
        _handlePasswordReset(code);
      }
      // Handle email verification
      else if (type == 'signup' && code != null && code.isNotEmpty) {
        print('Email verification code detected: $code');
        _handleEmailVerification(code);
      }
      // Handle OAuth callback (Google Sign-In)
      else if (accessToken != null || code != null) {
        print('OAuth callback detected - manually processing OAuth callback');
        _handleOAuthCallback(code, accessToken, refreshToken);
      }
    }
  }

  void _handleEmailVerification(String code) async {
    try {
      print('🔄 Processing email verification...');

      // Exchange code for session
      await Supabase.instance.client.auth.exchangeCodeForSession(code);
      // The AuthWrapper will automatically detect the signed-in user
      // and navigate to the Home page
    } catch (error) {
      print('❌ Email verification error: $error');
    }
  }

  void _handleOAuthCallback(
      String? code, String? accessToken, String? refreshToken) async {
    try {
      print('🔄 Processing OAuth callback...');

      if (code != null) {
        // Exchange code for session
        await Supabase.instance.client.auth.exchangeCodeForSession(code);
      } else if (accessToken != null) {
        // Set session with access token
        await Supabase.instance.client.auth.setSession(accessToken);
      }
    } catch (error) {
      print('❌ OAuth callback error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (_currentPage == 'register') {
      page = RegisterPage(onLoginTap: () => _goTo('login'));
    } else if (_currentPage == 'password-reset' && _resetCode != null) {
      page = PasswordResetPage(
        code: _resetCode!,
        onSuccess: () {
          // Go back to login page after successful password reset
          _goTo('login');
        },
      );
    } else {
      page = AuthWrapper(onRegisterTap: () => _goTo('register'));
    }
    return MaterialApp(
      title: 'Coffee Credit App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFf8f7f6),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0XFF364253)),
          titleTextStyle: GoogleFonts.inter(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
          ),
        ),
        cardColor: Color.fromARGB(255, 0, 0, 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFF23211C),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0XFF364253)),
          titleTextStyle: GoogleFonts.inter(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
          ),
        ),
        cardColor: Colors.brown[900]?.withOpacity(0.2),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFC69C6D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: Stack(
        children: [
          page,
          // Positioned(
          //   top: MediaQuery.of(context).padding.top + 8,
          //   right: 16,
          //   child: Material(
          //     color: Colors.transparent,
          //     child: IconButton(
          //       icon: Icon(
          //         _themeMode == ThemeMode.light
          //             ? Icons.dark_mode
          //             : Icons.light_mode,
          //         color: Colors.brown,
          //         size: 28,
          //       ),
          //       tooltip: 'Toggle Theme',
          //       onPressed: _toggleTheme,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }
}

class ErrorScreen extends StatefulWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isRunningDiagnostics = false;
  String _diagnosticsReport = '';

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunningDiagnostics = true;
      _diagnosticsReport = '';
    });

    try {
      final results = await NetworkDiagnostics.runDiagnostics();
      final report = NetworkDiagnostics.generateReport(results);

      setState(() {
        _diagnosticsReport = report;
        _isRunningDiagnostics = false;
      });
    } catch (e) {
      setState(() {
        _diagnosticsReport = 'Diagnostics failed: $e';
        _isRunningDiagnostics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Connection Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Restart the app
                      main();
                    },
                    child: const Text('Retry'),
                  ),
                  ElevatedButton(
                    onPressed: _isRunningDiagnostics ? null : _runDiagnostics,
                    child: _isRunningDiagnostics
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Run Diagnostics'),
                  ),
                ],
              ),
              if (_diagnosticsReport.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _diagnosticsReport,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordResetDialog extends StatefulWidget {
  @override
  _PasswordResetDialogState createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_reset, color: Colors.brown.shade600),
          SizedBox(width: 8),
          Text('Reset Password'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter your new password below:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade600,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Update Password'),
        ),
      ],
    );
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseAuthService.updatePassword(_passwordController.text);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: ${error.toString()}'),
            backgroundColor: Colors.red,
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
}
