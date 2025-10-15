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

  // Real AdMob ad unit IDs - using your actual ad unit ID from AdMob console
  final List<String> _adUnitIds = Platform.isAndroid
      ? [
          'ca-app-pub-4671717342961261/1751761759',
          'ca-app-pub-4671717342961261/1471096083'
          // Add more ad units here when you create them in AdMob
        ]
      : [
          'ca-app-pub-4671717342961261/1751761759',
          'ca-app-pub-4671717342961261/1471096083'
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
      _statusMessage = 'Loading video ad...';
    });

    // Rotate between ad units for more variety
    final currentAdUnitId = _adUnitIds[_currentAdUnitIndex];
    _currentAdUnitIndex = (_currentAdUnitIndex + 1) % _adUnitIds.length;

    RewardedInterstitialAd.load(
      adUnitId: currentAdUnitId,
      request: AdRequest(
        // Coffee-related targeting to get coffee ads
        keywords: [
          'coffee',
          'beverage',
          'drink',
          'cafe',
          'espresso',
          'latte',
          'cappuccino',
          'food',
          'restaurant',
          'dining',
          'gourmet',
          'premium',
          'organic',
          'fair trade'
        ],
        contentUrl: 'https://coffee-rewards-app.com',
        // Add more targeting for coffee-related ads
        extras: {
          'category': 'food_and_beverage',
          'subcategory': 'coffee',
        },
      ),
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
          setState(() {
            _isLoading = false;
            _isAdReady = false;
            _statusMessage = 'Failed to load ad. Please try again.';
          });
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
          widget.onCreditsEarned(rewardItem.amount.toDouble());

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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.brown.shade600,
                    Colors.brown.shade800,
                  ],
                ),
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
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                            color: Colors.white.withOpacity(0.8),
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
                        const SizedBox(width: 10),
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

                  const SizedBox(height: 16),

                  // Reward Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.brown.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.monetization_on,
                            color: Colors.brown.shade700,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                  color: Colors.brown.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Watch video ads to earn credits for your account',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 12),
                                  color: Colors.brown.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

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
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isAdReady && !_isLoading ? _showAd : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 16,
                                  width: 16,
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
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
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
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _loadAd,
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
