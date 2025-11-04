import 'package:flutter/material.dart';
import 'utils/responsive_helper.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About This App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            top: ResponsiveHelper.getResponsivePadding(context, 5),
            bottom: ResponsiveHelper.getResponsivePadding(context, 16),
            left: ResponsiveHelper.getResponsivePadding(context, 16),
            right: ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 24)),
                child: Column(
                  children: [
                    Container(
                      width: ResponsiveHelper.getResponsivePadding(context, 80),
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 80),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF5516),
                        borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveRadius(context, 20)),
                      ),
                      child: Icon(
                        Icons.coffee,
                        size:
                            ResponsiveHelper.getResponsiveFontSize(context, 40),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Image.asset(
                      'assets/images/logo.png',
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 20),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Text(
                      'Earn coffee rewards by completing surveys and engaging with coffee shops in your area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // How It Works
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5516),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.question_answer,
                      title: 'Complete Surveys',
                      description:
                          'Answer surveys through AdGate to earn coffee credits',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.local_cafe,
                      title: 'Earn Rewards',
                      description:
                          'Accumulate credits that can be redeemed for coffee',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.store,
                      title: 'Visit Coffee Shops',
                      description:
                          'Find and visit participating coffee shops in your area',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.card_giftcard,
                      title: 'Redeem Rewards',
                      description:
                          'Use your credits to get free coffee and treats',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // Features
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Features',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5516),
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.security,
                      title: 'Secure & Private',
                      description:
                          'Your data is protected with industry-standard security',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.notifications,
                      title: 'Smart Notifications',
                      description: 'Get notified about new surveys and rewards',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.history,
                      title: 'Reward History',
                      description:
                          'Track all your earned credits and redemptions',
                    ),
                    _buildFeatureItem(
                      context: context,
                      icon: Icons.location_on,
                      title: 'Location Services',
                      description: 'Find coffee shops near you',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // Contact & Support
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ResponsiveHelper.getResponsivePadding(context, 8),
                    right: ResponsiveHelper.getResponsivePadding(context, 20),
                    top: ResponsiveHelper.getResponsivePadding(context, 20),
                    bottom: ResponsiveHelper.getResponsivePadding(context, 20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                          left: ResponsiveHelper.getResponsivePadding(
                              context, 13),
                        ),
                        child: Text(
                          'Contact & Support',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5516),
                          ),
                        )),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    ListTile(
                      leading:
                          Icon(Icons.email_outlined, color: Color(0xFFFF5516)),
                      title: Text(
                        'Email Support',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      subtitle: Text(
                        'info@freecoffeestore.com',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      onTap: () {
                        // TODO: Open email app
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.help_outline, color: Color(0xFFFF5516)),
                      title: Text(
                        'Help Center',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      subtitle: Text(
                        'Frequently asked questions',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      onTap: () {
                        // TODO: Navigate to help page
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.privacy_tip_outlined,
                          color: Color(0xFFFF5516)),
                      title: Text(
                        'Privacy Policy',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      subtitle: Text(
                        'How we protect your data',
                        style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16)),
                      ),
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // App Info
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 4)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(
                        0, ResponsiveHelper.getResponsivePadding(context, 1)),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 20)),
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
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    _buildInfoRow(
                      context: context,
                      label: 'Developer',
                      value: 'Coffee Rewards Team',
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Category',
                      value: 'Lifestyle & Rewards',
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Platform',
                      value: 'Android & iOS',
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Last Updated',
                      value: 'October 2025',
                    ),
                    _buildInfoRow(
                      context: context,
                      label: 'Size',
                      value: '15.2 MB',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 24)),

            // Footer
            Center(
              child: Text(
                '© 2025 Coffee Rewards App. All rights reserved.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required String description}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsivePadding(context, 12)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 8)),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 8)),
            ),
            child: Icon(
              icon,
              color: Color(0xFFFF5516),
              size: ResponsiveHelper.getResponsiveFontSize(context, 24),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 4)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      {required BuildContext context,
      required String label,
      required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsivePadding(context, 8)),
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
