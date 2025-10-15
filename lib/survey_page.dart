import 'package:flutter/material.dart';
import 'package:rewarded_interstitial_example/services/app_config_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'utils/responsive_helper.dart';

class SurveyPage extends StatefulWidget {
  final String surveyUrl;
  final Function(double)? onSurveyCompleted;

  const SurveyPage({
    super.key,
    required this.surveyUrl,
    this.onSurveyCompleted,
  });

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check for survey completion
            _checkSurveyCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            print('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.surveyUrl));
  }

  void _checkSurveyCompletion(String url) async {
    print('Reward Completed: $url');
    if (url.contains('reward_complete') ||
        await AppConfigService.isTestMode()) {
      // Extract reward from URL
      double earnedCoins = await _parseCoins(url);
      print('Coins123123123123: $earnedCoins');
      if (earnedCoins > 0) {
        // Call the completion callback
        widget.onSurveyCompleted?.call(earnedCoins);
        // Close the survey page
        Navigator.of(context).pop();
      }
    }
  }

  Future<double> _parseCoins(String url) async {
    try {
      final uri = Uri.parse(url);
      final coins = uri.queryParameters['reward_amount_in_app_currency'] ??
          uri.queryParameters['coins'] ??
          uri.queryParameters['reward'];
      final percentage =
          await AppConfigService.getSurveyCreditEarningPercentage();
      return coins != null ? (double.tryParse(coins) ?? 0) * percentage : 0.0;
    } catch (e) {
      print('❌ Error parsing coins from URL: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Take Survey',
          style: TextStyle(
              color: Colors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20)),
        ),
        backgroundColor: const Color(0xFFC69C6D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
