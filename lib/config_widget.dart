import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/responsive_helper.dart';
import 'globals.dart';

class ConfigWidget extends StatefulWidget {
  const ConfigWidget({super.key});

  @override
  State<ConfigWidget> createState() => _ConfigWidgetState();
}

class _ConfigWidgetState extends State<ConfigWidget> {
  bool _isAutoConnect = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    checkAutoConnect();
    checkConnectionStatus();
  }

  Future<void> checkAutoConnect() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAutoConnect = prefs.getBool('auto_connect') ?? true;
    setState(() {
      _isAutoConnect = isAutoConnect;
    });
  }

  Future<void> setAutoConnect(bool isAuto) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto_connect', isAuto);
    setState(() {
      _isAutoConnect = isAuto;
    });
  }

  Future<void> checkConnectionStatus() async {
    // Simulate connection check - in real app this would check actual connection
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isConnected = true;
    });
  }

  String _getLastUpdateTime() {
    final userProfile = GlobalUser.userProfile;
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
        return '${months[lastUpdate.month - 1]} ${lastUpdate.day}, ${lastUpdate.year}';
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
        return '${months[now.month - 1]} ${now.day}, ${now.year}';
      }
    }

    // Fallback to current date if no profile data
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Color(0xFFFF5516),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.pending,
                          color: _isConnected ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connection Status',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5516),
                                ),
                              ),
                              Text(
                                _isConnected
                                    ? 'Connected to AdGate'
                                    : 'Connecting...',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _isConnected ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isConnected ? Icons.info : Icons.warning,
                            color: _isConnected
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isConnected
                                  ? 'Your app is successfully connected to AdGate and ready to show surveys.'
                                  : 'Establishing connection to AdGate. This may take a few moments.',
                              style: TextStyle(
                                color: _isConnected
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Auto Connect Settings
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Settings',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5516),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAutoConnect,
                          onChanged: (bool? value) {
                            setAutoConnect(value ?? true);
                          },
                          activeColor: Color(0xFFFF5516),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto Connect',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Automatically connect to AdGate when the app starts',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 14),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Information
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Information',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5516),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('App Version', '1.0.0'),
                    _buildInfoRow(
                        'Platform', Platform.isAndroid ? 'Android' : 'iOS'),
                    _buildInfoRow('Build Type', 'Release'),
                    _buildInfoRow('Last Updated', _getLastUpdateTime()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Support Information
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support & Help',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5516),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          Icon(Icons.help_outline, color: Color(0xFFFF5516)),
                      title: const Text('How to Use'),
                      subtitle: const Text('Learn how to earn coffee rewards'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to help page
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.email_outlined, color: Color(0xFFFF5516)),
                      title: const Text('Contact Support'),
                      subtitle: const Text('Get help with your account'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Open support email
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined,
                          color: Color(0xFFFF5516)),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('Read our privacy policy'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }
}
