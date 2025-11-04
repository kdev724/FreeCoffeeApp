import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../utils/responsive_helper.dart';

class AdWatchDialog extends StatefulWidget {
  final Function(double) onCreditsEarned;
  final VoidCallback? onDialogClosed; // Add this callback

  const AdWatchDialog({
    super.key,
    required this.onCreditsEarned,
    this.onDialogClosed, // Add this parameter
  });

  @override
  State<AdWatchDialog> createState() => _AdWatchDialogState();
}

class _AdWatchDialogState extends State<AdWatchDialog> {
  bool _isLoading = true;
  bool _isAdReady = false;
  String _statusMessage = 'Loading video ad...';
  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _currentAdUnitIndex = 0;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  // AdMob ad unit IDs - using test IDs for development and real IDs for production
  final List<String> _adUnitIds = Platform.isAndroid
      ? [
          // Test ad unit IDs for development (always return ads)
          'ca-app-pub-4671717342961261/1751761759', // Test rewarded interstitial
          // Real ad unit IDs for production
          'ca-app-pub-3940256099942544/5354046379',
          // Add more ad units here when you create them in AdMob
        ]
      : [
          // Test ad unit IDs for development (always return ads)
          'ca-app-pub-4671717342961261/1751761759', // Test rewarded interstitial
          // Real ad unit IDs for production
          'ca-app-pub-3940256099942544/5354046379',
          // Add more ad units here when you create them in AdMob
        ];

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() {
      _isLoading = true;
      _isAdReady = false;
      _statusMessage = _retryCount > 0
          ? 'Retrying to load ad... (${_retryCount + 1}/$_maxRetries)'
          : 'Loading video ad...';
    });

    // Rotate between ad units for more variety
    final currentAdUnitId = _adUnitIds[_currentAdUnitIndex];

    RewardedInterstitialAd.load(
      adUnitId: currentAdUnitId,
      request: AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Ad loaded in dialog!');
          _rewardedInterstitialAd = ad;
          setState(() {
            _isLoading = false;
            _isAdReady = true;
            _statusMessage = 'Video ad ready! Tap to watch and earn credits';
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load in dialog: $error');
          if (_currentAdUnitIndex == 1) {
            setState(() {
              _isLoading = false;
              _isAdReady = false;
            });
          } else {
            _currentAdUnitIndex = 1;
            _loadAd();
          }
        },
      ),
    );
  }

  Future<void> _showAd() async {
    if (!_isAdReady || _rewardedInterstitialAd == null) {
      print('Ad not ready to show');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Playing video ad...';
    });

    try {
      print('User clicked Watch Ad - showing Google Mobile Ads video');

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView view, RewardItem rewardItem) {
          print('Reward earned: ${rewardItem.amount}');
          widget.onCreditsEarned(rewardItem.amount.toDouble() > 5
              ? 1
              : rewardItem.amount.toDouble());

          if (mounted) {
            setState(() {
              _statusMessage = 'Video completed! Credits added to your account';
            });
          }
          // Close dialog after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
              widget.onDialogClosed?.call();
            }
          });
        },
      );

      // Set up ad callbacks
      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('Ad dismissed');
          ad.dispose();
          _rewardedInterstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Ad failed to show: $error');
          ad.dispose();
          _rewardedInterstitialAd = null;
          if (mounted) {
            setState(() {
              _isLoading = false;
              _statusMessage = 'Failed to show ad. Please try again.';
            });
          }
        },
      );
    } catch (e) {
      print('Error showing video ad: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error loading video ad. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Color(0xFFFF5516).withOpacity(0.9),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                      width:
                          ResponsiveHelper.getResponsivePadding(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watch & Earn',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Earn credits by watching ads',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 12),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDialogClosed?.call();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isAdReady
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isAdReady
                            ? Colors.green.shade200
                            : Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _isAdReady
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _isAdReady
                                ? Icons.check_circle
                                : Icons.hourglass_empty,
                            color: _isAdReady
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            size: 16,
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.getResponsivePadding(
                                context, 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isAdReady ? 'Ad Ready!' : 'Loading Ad...',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  fontWeight: FontWeight.bold,
                                  color: _isAdReady
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _statusMessage,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 12),
                                  color: _isAdReady
                                      ? Colors.green.shade600
                                      : Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),

                  // Reward Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getResponsivePadding(context, 12)),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF5516).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFFF5516).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              ResponsiveHelper.getResponsivePadding(
                                  context, 6)),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF5516).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.monetization_on,
                            color: Color(0xFFFF5516).withOpacity(0.9),
                            size: ResponsiveHelper.getResponsiveIconSize(
                                context, 16),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveHelper.getResponsivePadding(
                                context, 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Earn Credits',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5516).withOpacity(0.9),
                                ),
                              ),
                              SizedBox(
                                  height: ResponsiveHelper.getResponsivePadding(
                                      context, 2)),
                              Text(
                                'Watch video ads to earn credits',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 12),
                                  color: Color(0xFFFF5516).withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDialogClosed?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context, 14),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: ResponsiveHelper.getResponsivePadding(
                              context, 8)),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isAdReady && !_isLoading ? _showAd : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF5516).withOpacity(0.9),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height:
                                      ResponsiveHelper.getResponsiveIconSize(
                                          context, 16),
                                  width: ResponsiveHelper.getResponsiveIconSize(
                                      context, 16),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      size: ResponsiveHelper
                                          .getResponsiveIconSize(context, 16),
                                    ),
                                    SizedBox(
                                        width: ResponsiveHelper
                                            .getResponsivePadding(context, 6)),
                                    Text(
                                      'Watch Video Ad',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper
                                            .getResponsiveFontSize(context, 14),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  // Retry button (only show when ad failed)
                  if (!_isAdReady && !_isLoading) ...[
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    TextButton.icon(
                      onPressed: () {
                        _retryCount = 0; // Reset retry count
                        _loadAd();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 14,
                        color: Colors.brown.shade600,
                      ),
                      label: Text(
                        'Retry Loading Ad',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                          color: Colors.brown.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
