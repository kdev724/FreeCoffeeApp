import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'globals.dart' as globals;
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'widgets/auth_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'utils/responsive_helper.dart';
import 'widgets/ad_watch_dialog.dart';
import 'services/supabase_auth_service.dart';
import 'services/coffee_redemption_service.dart';
import 'services/app_config_service.dart';
// import 'admin/admin_dashboard.dart';
// import 'widgets/role_based_widget.dart';
import 'redemption_history_page.dart';
import 'consent_manager.dart';
import 'config/app_config.dart';
import 'survey_page.dart';
import 'admin/admin_dashboard.dart';

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
  bool _animateIn = false;
  final GlobalKey _greetingKey = GlobalKey();

  String _getFirstName() {
    final displayName = globals.GlobalUser.getDisplayName();
    if (displayName.trim().isEmpty) return 'there';
    final parts = displayName.trim().split(' ');
    return parts.first;
  }

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
        'https://theoremreach.com/respondent_entry/direct?api_key=$apiKey&user_id=${globals.GlobalUser.currentUser?.id}';

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SurveyPage(
          surveyUrl: surveyUrl,
          heroTag: 'survey_tile',
          onSurveyCompleted: (earnedCoins) {
            _onCreditsEarned(earnedCoins);
          },
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
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
    print('Amount99999: $amount');
    final newCredits = globals.GlobalUser.getCredits() + amount;

    globals.GlobalUser.updateCredits(newCredits);
    await SupabaseAuthService.updateUserCredits(newCredits);

    setState(() {});

    // Format amount display - show cents for small amounts
    String formattedAmount = _formatCreditsDisplay(amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $formattedAmount!'),
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

  String _formatCreditsDisplay(double amount) {
    if (amount < 0.01) {
      // Show as cents for amounts less than 1 cent
      print('Amount00000: $amount');
      double cents = (amount * 100).toDouble();
      return '${double.parse(cents.toStringAsFixed(6))}¢';
    } else {
      // Show as dollars for larger amounts
      return '\$${double.parse(amount.toStringAsFixed(6))}';
    }
  }

  String _formatWholeCredits(double amount) {
    final intVal = amount.floor();
    final str = intVal.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (m) => '${m[1]},');
  }

  String _getLastUpdateTimeShort() {
    final userProfile = globals.GlobalUser.userProfile;
    if (userProfile != null && userProfile['last_update'] != null) {
      try {
        final lastUpdate = DateTime.parse(userProfile['last_update']);
        const months = [
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
      } catch (_) {}
    }
    return 'No update';
  }

  Widget _buildSmallAvatar() {
    final displayName = globals.GlobalUser.getDisplayName();
    String initials = '?';
    if (displayName.isNotEmpty) {
      final parts = displayName.trim().split(' ');
      if (parts.length >= 2) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: const Color(0xFF222222),
      child: Text(
        initials,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildBountyBalance(double credits) {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getResponsivePadding(context, 25)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _formatCreditsDisplay(credits),
                        key: ValueKey(_formatCreditsDisplay(credits)),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 58),
                              color: const Color(0xFF0F0F0F),
                              letterSpacing: -1.2,
                            ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 25)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 10),
                        vertical:
                            ResponsiveHelper.getResponsivePadding(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 20),
                        ),
                        border: const Border.fromBorderSide(
                          BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                      ),
                      child: Text(
                        'Last updated: ${_getLastUpdateTimeShort()}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w700,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 12),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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

    // Initialize ad loading
    _initializeAds();

    // Trigger initial fade/slide-in after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animateIn = true;
        });
      }
    });
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

  // Redemption history is accessible via the button; no prefetch on home

  // Avatar helper removed for the minimalist header

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text(
            '',
          ),
          titleSpacing: 0,
          titleTextStyle: Theme.of(context).textTheme.titleLarge,
          leadingWidth: 0,
          leading: const SizedBox.shrink(),
          flexibleSpace: SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: ResponsiveHelper.getResponsivePadding(context, 16),
                    top: ResponsiveHelper.getResponsivePadding(context, 5)),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: ResponsiveHelper.getResponsivePadding(context, 20),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.only(
                    right: ResponsiveHelper.getResponsivePadding(context, 12)),
                child: Container(
                  key: _greetingKey,
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getResponsivePadding(context, 12),
                      vertical:
                          ResponsiveHelper.getResponsivePadding(context, 6)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 24)),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: ResponsiveHelper.getResponsivePadding(
                              context, 12),
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 24)),
                      splashColor: Colors.black12,
                      highlightColor: Colors.black12.withOpacity(0.06),
                      onTap: () async {
                        final ctx = _greetingKey.currentContext;
                        if (ctx != null) {
                          final box = ctx.findRenderObject() as RenderBox;
                          final offset = box.localToGlobal(Offset.zero);
                          final size = box.size;
                          final selected = await showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx +
                                  ResponsiveHelper.getResponsivePadding(
                                      context, 10),
                              offset.dy + size.height + 5,
                              offset.dx + size.width,
                              0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12),
                              ),
                            ),
                            items: [
                              if (globals.GlobalUser.getEmail() != null &&
                                  globals.GlobalUser.getUserRole() == 'admin')
                                PopupMenuItem<String>(
                                  value: 'admin',
                                  height: ResponsiveHelper.getResponsivePadding(
                                      context, 30),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        size: ResponsiveHelper
                                            .getResponsiveIconSize(context, 18),
                                        color: Colors.blueAccent,
                                      ),
                                      SizedBox(
                                        width: ResponsiveHelper
                                            .getResponsivePadding(context, 10),
                                      ),
                                      Text(
                                        'Admin',
                                        style: TextStyle(
                                            fontSize: ResponsiveHelper
                                                .getResponsiveFontSize(
                                                    context, 16)),
                                      ),
                                    ],
                                  ),
                                ),
                              PopupMenuItem<String>(
                                value: 'signout',
                                height: ResponsiveHelper.getResponsivePadding(
                                    context, 30),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: ResponsiveHelper
                                          .getResponsiveIconSize(context, 18),
                                      color: Colors.redAccent,
                                    ),
                                    SizedBox(
                                      width:
                                          ResponsiveHelper.getResponsivePadding(
                                              context, 10),
                                    ),
                                    Text(
                                      'Sign out',
                                      style: TextStyle(
                                          fontSize: ResponsiveHelper
                                              .getResponsiveFontSize(
                                                  context, 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                          if (selected == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminDashboard(),
                              ),
                            );
                          } else if (selected == 'signout') {
                            await SupabaseAuthService.signOut();
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Hi, ${_getFirstName()}!',
                              style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 16),
                                  fontWeight: FontWeight.w600)),
                          SizedBox(
                              width: ResponsiveHelper.getResponsivePadding(
                                  context, 6)),
                          _buildSmallAvatar(),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSlide(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  offset: _animateIn ? Offset.zero : const Offset(0, -0.05),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    opacity: _animateIn ? 1 : 0,
                    child: _buildBountyBalance(userCredits),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 50)),
                        topRight: Radius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 50))),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getResponsivePadding(context, 20)),
                  child: Column(children: [
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 30)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.06),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: ResponsiveHelper.getResponsivePadding(
                                  context, 21),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFF5516),
                                    Color(0xFFE04A14),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            Text(
                              'Earn Credits',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 24),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 12)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.08),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: _ModernListTile(
                          icon: Icons.play_circle_filled,
                          title: 'Watch Ads',
                          subtitle: _isLoading
                              ? 'Preparing ad…'
                              : 'Earn credits by watching ads',
                          heroTag: 'watch_ads_tile',
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() => _isLoading = true);
                                  _loadAdAndShowModal();
                                },
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.1),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: _ModernListTile(
                          icon: Icons.quiz,
                          title: 'Complete Surveys',
                          subtitle: 'Answer questions and earn rewards',
                          heroTag: 'survey_tile',
                          onTap: _showSurveyModal,
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.12),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: _ModernListTile(
                          icon: Icons.language,
                          title: 'Visit Website',
                          subtitle: 'Explore our coffee collection',
                          heroTag: 'visit_website_tile',
                          onTap: () async {
                            final Uri url = Uri.parse(AppConfig.coffeeShopUrl);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 32)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.06),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: ResponsiveHelper.getResponsivePadding(
                                  context, 24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                        context, 2)),
                              ),
                            ),
                            SizedBox(
                                width: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            Text(
                              'Redeem Coffee',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 24),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 12)),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      offset: _animateIn ? Offset.zero : const Offset(0, 0.08),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: RedeemCard(
                          credits: userCredits,
                          onCreditsUpdated: () {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 24)),
                    const _RedeemedSummaryCard(),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RedemptionHistoryPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEDEDED)),
                          backgroundColor: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveRadius(
                                    context, 12)),
                          ),
                        ),
                        child: Text(
                          'Redemption history',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 24)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? heroTag;

  const _ModernListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.heroTag,
  });

  @override
  State<_ModernListTile> createState() => _ModernListTileState();
}

class _ModernListTileState extends State<_ModernListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onTap == null;
    Widget content = GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 15)),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, 20)),
          border: Border.all(
            color: Color(0xFFEDEDED),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: ResponsiveHelper.getResponsivePadding(context, 24),
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: ResponsiveHelper.getResponsivePadding(context, 12),
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getResponsivePadding(context, 46),
              height: ResponsiveHelper.getResponsivePadding(context, 46),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context,
                        ResponsiveHelper.getResponsivePadding(context, 16))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: ResponsiveHelper.getResponsiveIconSize(context, 28),
                color: Color(0xFFFF5516),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDisabled ? Colors.black45 : Colors.black87,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 18),
                        ),
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 4)),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 14),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: content,
      );
    }

    return content;
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

  String _formatCreditsDisplay(BuildContext context, double amount) {
    if (amount < 0.01) {
      // Show as cents for amounts less than 1 cent
      print('Amount123123123123: $amount');
      double cents = (amount * 100).toDouble();
      return '${double.parse(cents.toStringAsFixed(6))}¢';
    } else {
      // Show as dollars for larger amounts
      return '\$${double.parse(amount.toStringAsFixed(6))}';
    }
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
        color: Color(0xFFFF5516),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF5516).withOpacity(0.3),
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
            _formatCreditsDisplay(context, credits),
            style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 30)),
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

class _RedeemedSummaryCard extends StatelessWidget {
  const _RedeemedSummaryCard();

  int _countPending(List<Map<String, dynamic>> items) {
    return items
        .where((r) => (r['status'] ?? '').toString().toLowerCase() == 'pending')
        .length;
  }

  int _countCompleted(List<Map<String, dynamic>> items) {
    // Treat delivered/confirmed/shipped/processing as completed
    const completedStatuses = {
      'delivered',
      'confirmed',
      'shipped',
      'processing'
    };
    return items
        .where((r) => completedStatuses
            .contains((r['status'] ?? '').toString().toLowerCase()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: CoffeeRedemptionService.getUserRedemptions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 16),
              ),
              border: Border.all(color: const Color(0xFFEDEDED)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatPill(label: 'Pending', value: '—', color: Colors.orange),
                _StatPill(label: 'Completed', value: '—', color: Colors.green),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 16),
              ),
              border: Border.all(color: const Color(0xFFEDEDED)),
            ),
            child: Text(
              'Unable to load redeemed bags',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          );
        }

        final items = snapshot.data ?? const <Map<String, dynamic>>[];
        final pending = _countPending(items);
        final completed = _countCompleted(items);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            ResponsiveHelper.getResponsivePadding(context, 16),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveRadius(context, 16),
            ),
            border: Border.all(color: const Color(0xFFEDEDED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Pending',
                  value: pending.toString(),
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context, 12)),
              Expanded(
                child: _StatPill(
                  label: 'Completed',
                  value: completed.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getResponsivePadding(context, 12),
        horizontal: ResponsiveHelper.getResponsivePadding(context, 12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveRadius(context, 12),
        ),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            label == 'Pending' ? Icons.schedule : Icons.check_circle,
            color: color,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 14),
                    ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
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
    return FutureBuilder<double>(
      future: AppConfigService.getDefaultCoffeePrice(),
      builder: (context, snapshot) {
        final double price = (snapshot.data ?? 15.0).toDouble();
        bool canRedeem = widget.credits >= price;
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
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 6)),
              Text(
                "Redeem your credits for a free bag of premium coffee.",
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 12)),
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
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 22),
                                    )),
                                content: Text(
                                    'Are you sure you want to redeem your credits for a free coffee bag? This will deduct ${price.toStringAsFixed(0)} credits from your account.'),
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
                                          width: ResponsiveHelper
                                              .getResponsivePadding(
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
                                          height: ResponsiveHelper
                                              .getResponsivePadding(
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
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
                                        'Coffee bag redeemed successfully! ${price.toStringAsFixed(0)} credits deducted.'),
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
                    backgroundColor: Color(0xFFFF5516).withOpacity(0.9),
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
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 14),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          canRedeem
                              ? "Redeem Now"
                              : "\$${double.parse(price.toStringAsFixed(2))} Required to Redeem",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
