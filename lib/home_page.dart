import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/auth_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/responsive_helper.dart';
import 'widgets/ad_watch_dialog.dart';
import 'services/supabase_auth_service.dart';
import 'services/coffee_redemption_service.dart';
import 'services/app_config_service.dart';
import 'admin/admin_dashboard.dart';
import 'widgets/role_based_widget.dart';
import 'redemption_history_page.dart';
import 'consent_manager.dart';
import 'config/app_config.dart';
import 'survey_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomePage> {
  final _consentManager = ConsentManager();

  // Use getter to always get current credits from global user
  double get userCredits => globals.GlobalUser.getCredits();
  bool _isLoading = false;
  List<Map<String, dynamic>> _userRedemptions = [];

  void _loadAdAndShowModal() {
    _loadAd();

    // Show modal after a short delay to allow ad to load
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showAdModal();
      }
    });
  }

  void _showAdModal() async {
    // Get the configurable credit earning percentage for ads
    final percentage = await AppConfigService.getAdsCreditEarningPercentage();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdWatchDialog(
        onCreditsEarned: (amount) {
          _onCreditsEarned(amount * percentage);
        },
        onDialogClosed: () {},
      ),
    );
  }

  void _showSurveyModal() {
    String apiKey = 'e583e38f2c0268474150e0c8c1d3';
    String surveyUrl =
        'https://theoremreach.com/respondent_entry?api_key=$apiKey&user_id=${globals.GlobalUser.currentUser?.id}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyPage(
          surveyUrl: surveyUrl,
          onSurveyCompleted: (earnedCoins) {
            _onCreditsEarned(earnedCoins);
          },
        ),
      ),
    );
  }

  void _loadAd() async {
    var canRequestAds = await _consentManager.canRequestAds();
    if (!canRequestAds) {
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      MobileAds.instance.initialize();
    }
  }

  Future<void> _onCreditsEarned(double amount) async {
    print('Amount123123123123: $amount');
    final newCredits = globals.GlobalUser.getCredits() + amount;

    globals.GlobalUser.updateCredits(newCredits);
    await SupabaseAuthService.updateUserCredits(newCredits);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned \$${amount.toStringAsFixed(2)}!'),
        backgroundColor: Colors.green,
        duration:
            Duration(days: 1), // very long duration - only dismissible by tap
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void setAppConnected(bool connected) {
    setState(() {
      globals.isConnected = connected;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUserData();
    _refreshUserDataFromDatabase(); // Refresh from database to ensure latest data
    _loadUserRedemptions(); // Load user's redemption history

    // Initialize ad loading
    _initializeAds();
  }

  void _initializeAds() async {
    // Initialize Mobile Ads SDK and load first ad
    var canRequestAds = await _consentManager.canRequestAds();
    if (canRequestAds) {
      // Configure test device IDs for development
      await MobileAds.instance.initialize().then((initializationStatus) {
        // Set test device configuration for development
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: AppConfig.testDeviceIds,
            tagForChildDirectedTreatment:
                TagForChildDirectedTreatment.unspecified,
            tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
            maxAdContentRating: MaxAdContentRating.pg,
          ),
        );
      });

      _loadAd();
    }
  }

  void _refreshUserData() {
    // Refresh user data from global state
    setState(() {});
  }

  // Method to refresh user data from database
  Future<void> _refreshUserDataFromDatabase() async {
    try {
      final user = globals.GlobalUser.currentUser;
      if (user != null) {
        final profile = await SupabaseAuthService.loadUserProfile(user.id);
        if (profile != null) {
          globals.GlobalUser.setUserProfile(profile);
          setState(() {});
        }
      }
    } catch (error) {}
  }

  // Load user's redemption history
  Future<void> _loadUserRedemptions() async {
    try {
      final redemptions = await CoffeeRedemptionService.getUserRedemptions();
      setState(() {
        _userRedemptions = redemptions;
      });
    } catch (error) {
      // Don't show error to user on home page, just log it
      // The redemption history page will handle errors properly
    }
  }

  // Build user avatar with initials or profile picture
  Widget _buildUserAvatar(BuildContext context) {
    final displayName = globals.GlobalUser.getDisplayName();

    // Get user initials from display name
    String getInitials(String? name) {
      if (name == null || name.isEmpty) return '?';
      final nameParts = name.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.length == 1) {
        return nameParts[0][0].toUpperCase();
      }
      return '?';
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: ResponsiveHelper.getResponsiveIconSize(context, 35),
        backgroundColor: Color(0xFFC69C6D),
        child: displayName.isNotEmpty
            ? Text(
                getInitials(displayName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 25),
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white,
                size: ResponsiveHelper.getResponsiveIconSize(context, 30),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Color(0xFFC69C6D),
            title: Text(
              'Free Coffee',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: false,
            actions: [
              // Admin button (only visible to admins)
              if (globals.GlobalUser.isLoggedIn &&
                  SupabaseAuthService.isAdmin())
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings,
                      color: Colors.white),
                  onPressed: () async {
                    // Navigate to admin dashboard with role protection
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminGuard(
                          child: const AdminDashboard(),
                        ),
                      ),
                    );
                  },
                  tooltip: 'Admin Panel',
                ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  try {
                    await SupabaseAuthService.signOut();
                    if (mounted) {
                      // Ensure we leave Home immediately and let AuthWrapper decide next screen
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthWrapper()),
                        (route) => false,
                      );
                    }
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign out failed: ${error.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                tooltip: 'Sign Out',
              ),
            ],
          ),
          body: Padding(
            padding: ResponsiveHelper.getResponsiveEdgeInsets(
              context,
              horizontal: ResponsiveHelper.getResponsivePadding(context, 0),
              vertical: ResponsiveHelper.getResponsivePadding(context, 0),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 10),
                    height: ResponsiveHelper.getResponsivePadding(context, 20),
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: ResponsiveHelper.getResponsivePadding(
                              context, 20)),
                      _buildUserAvatar(context),
                      SizedBox(
                          width: ResponsiveHelper.getResponsivePadding(
                              context, 15)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Good Morning",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 25))),
                          Text(globals.GlobalUser.getDisplayName(),
                              style: TextStyle(color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 10),
                    height: ResponsiveHelper.getResponsivePadding(context, 12),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: CreditCardWidget(credits: userCredits),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 20),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    child: Text(
                      "Earn More Credits",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                          ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 10),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ActionButton(
                            icon: _isLoading
                                ? Icons.hourglass_empty
                                : Icons.play_arrow_rounded,
                            label: _isLoading ? 'Loading...' : 'Load Ad',
                            onPressed: _isLoading
                                ? () {} // Disabled when loading
                                : () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    _loadAdAndShowModal();
                                  },
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsivePadding(
                              context, 12),
                        ),
                        Expanded(
                          flex: 1,
                          child: ActionButton(
                            icon: Icons.assignment,
                            label: 'Take Surveys',
                            onPressed: () {
                              _showSurveyModal();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 10),
                  ),
                  // Coffee Shop Section (hidden for admin users)
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    width: double.infinity,
                    padding: ResponsiveHelper.getResponsiveEdgeInsets(
                      context,
                      horizontal:
                          ResponsiveHelper.getResponsivePadding(context, 20),
                      vertical:
                          ResponsiveHelper.getResponsivePadding(context, 20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFC69C6D).withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                ResponsiveHelper.getResponsivePadding(
                                    context, 12),
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFC69C6D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveRadius(
                                      context, 12),
                                ),
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Color(0xFF8B4513),
                                size: ResponsiveHelper.getResponsiveIconSize(
                                    context, 24),
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
                                    "Ready to Shop?",
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 20),
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC69C6D),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Coffee Collection",
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 14),
                                      color: Color(0xFFC69C6D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        Text(
                          "Browse our premium coffee selection and redeem your credits for delicious coffee!",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 20)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Open coffee shop website
                              final Uri url =
                                  Uri.parse(AppConfig.coffeeShopUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Could not open coffee shop website'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.shopping_bag_outlined,
                                color: Colors.white),
                            label: Text(
                              'Shop Coffee',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC69C6D),
                              foregroundColor: Colors.white,
                              padding: ResponsiveHelper.getResponsiveEdgeInsets(
                                context,
                                horizontal: 24,
                                vertical: 16,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveRadius(
                                      context, 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 16),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    child: RedeemCard(
                      credits: userCredits,
                      onCreditsUpdated: () {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),
                  // Coffee count display
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    width: double.infinity,
                    padding: ResponsiveHelper.getResponsiveEdgeInsets(
                      context,
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Coffee Bags Redeemed",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 8)),
                        Row(
                          children: [
                            Icon(
                              Icons.coffee,
                              color: Colors.brown.shade600,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                  context, 24),
                            ),
                            SizedBox(
                                width: ResponsiveHelper.getResponsivePadding(
                                    context, 8)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${globals.GlobalUser.getCoffeeCount()} bags",
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 18),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown.shade600,
                                    ),
                                  ),
                                  if (_userRedemptions.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      "${_userRedemptions.where((r) => r['status'] == 'pending' || r['status'] == 'processing').length} pending",
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 12),
                                        color: Colors.orange.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (_userRedemptions.isNotEmpty) ...[
                              Icon(
                                Icons.history,
                                color: Colors.grey.shade500,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                    context, 20),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Redemption history button
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFC69C6D).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RedemptionHistoryPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('View Redemption History'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC69C6D),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: ResponsiveHelper.getResponsiveEdgeInsets(
                          context,
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  // Add test buttons for debugging
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )),
    );
  }
}

class CreditCardWidget extends StatelessWidget {
  final double credits;

  const CreditCardWidget({super.key, required this.credits});

  String _getLastUpdateTime() {
    final userProfile = globals.GlobalUser.userProfile;
    if (userProfile != null && userProfile['last_update'] != null) {
      try {
        final lastUpdate = DateTime.parse(userProfile['last_update']);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[lastUpdate.month - 1]} ${lastUpdate.day}';
      } catch (e) {
        // Fallback to current date if parsing fails
        final now = DateTime.now();
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${months[now.month - 1]} ${now.day}';
      }
    }

    // Fallback to current date if no profile data
    return "No update";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsiveEdgeInsets(
        context,
        horizontal: ResponsiveHelper.getResponsivePadding(context, 20),
        vertical: ResponsiveHelper.getResponsivePadding(context, 20),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFC69C6D),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFC69C6D).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 7)),
          Text(
            '\$${credits.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 4)),
          Text(
            'Last update: ${_getLastUpdateTime()}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF243046),
          elevation: 0,
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Color.fromARGB(255, 222, 232, 250),
                fontWeight: FontWeight.bold,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, 14),
            ),
          ),
          padding: ResponsiveHelper.getResponsiveEdgeInsets(
            context,
            horizontal: 8,
            vertical: 14,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: ResponsiveHelper.getResponsiveIconSize(context, 20)),
            SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 8)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 16),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class RedeemCard extends StatefulWidget {
  final double credits;
  final VoidCallback? onCreditsUpdated;
  const RedeemCard({super.key, required this.credits, this.onCreditsUpdated});

  @override
  State<RedeemCard> createState() => _RedeemCardState();
}

class _RedeemCardState extends State<RedeemCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool canRedeem = widget.credits >= 15.0;
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getResponsiveEdgeInsets(
        context,
        horizontal: 16,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            spreadRadius: 0,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Free Coffee Bag",
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 6)),
          Text(
            "Redeem your credits for a free bag of premium coffee.",
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (canRedeem && !_isLoading)
                  ? () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('Confirm Redemption',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 22),
                                )),
                            content: Text(
                                'Are you sure you want to redeem your credits for a free coffee bag? This will deduct 15 credits from your account.'),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 8)),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFD7A86E),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Confirm'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          // Show shipping address dialog
                          final TextEditingController addressController =
                              TextEditingController();
                          final shippingAddress = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Shipping Address'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      'Please provide your shipping address for the coffee bag:'),
                                  SizedBox(
                                      height:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 16)),
                                  TextField(
                                    controller: addressController,
                                    decoration: InputDecoration(
                                      labelText: 'Shipping Address',
                                      border: OutlineInputBorder(),
                                      hintText:
                                          'Enter your full shipping address',
                                    ),
                                    maxLines: 3,
                                    autofocus: true,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(addressController.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFD7A86E),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Submit'),
                                ),
                              ],
                            ),
                          );

                          if (shippingAddress != null &&
                              shippingAddress.isNotEmpty) {
                            // Import the service at the top of the file
                            await CoffeeRedemptionService.createRedemption(
                              shippingAddress: shippingAddress,
                            );

                            // Notify parent to refresh credits and coffee count
                            widget.onCreditsUpdated?.call();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Coffee bag redeemed successfully! 15 credits deducted.'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${error.toString()}'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD7A86E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 10),
                  ),
                ),
                padding: ResponsiveHelper.getResponsiveEdgeInsets(
                  context,
                  horizontal: 0,
                  vertical: 12,
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveIconSize(
                              context, 16),
                          height: ResponsiveHelper.getResponsiveIconSize(
                              context, 16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.getResponsivePadding(
                                context, 8)),
                        Text(
                          "Processing...",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      canRedeem ? "Redeem Now" : "\$15 Required to Redeem",
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 14),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
