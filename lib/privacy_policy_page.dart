import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/responsive_helper.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3ECE7),
      appBar: AppBar(
        title: Text(
          'Privacy Policy & Terms',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
          ),
        ),
        backgroundColor: Color(0xFFC69C6D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 20)),
        child: Container(
          constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getResponsiveFontSize(context, 800)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 24)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFC69C6D).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(
                          0, ResponsiveHelper.getResponsivePadding(context, 8)),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: Offset(0,
                          ResponsiveHelper.getResponsivePadding(context, 16)),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: ResponsiveHelper.getResponsiveFontSize(context, 48),
                      color: Color(0xFFC69C6D),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Text(
                      'Privacy Policy & Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                    Text(
                      'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: GoogleFonts.inter(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 14),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 24)),

              // Privacy Policy Section
              _buildSection(
                context,
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                [
                  _buildSubsection(
                    context,
                    'Information We Collect',
                    [
                      '• Email address for account creation and communication',
                      '• Full name for personalization',
                      '• Usage data to improve our services',
                      '• Device information for app functionality',
                      '• Survey responses and reward preferences',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'How We Use Your Information',
                    [
                      '• To provide and maintain our coffee rewards service',
                      '• To send you verification emails and important updates',
                      '• To process your coffee redemptions and rewards',
                      '• To improve our app and user experience',
                      '• To communicate with you about surveys and offers',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Data Security',
                    [
                      '• We use industry-standard encryption to protect your data',
                      '• Your passwords are securely hashed and never stored in plain text',
                      '• We implement proper access controls and monitoring',
                      '• Regular security audits and updates are performed',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Third-Party Services',
                    [
                      '• We use Supabase for secure data storage and authentication',
                      '• Google AdMob for displaying advertisements',
                      '• TheoremReach for survey services',
                      '• All third-party services comply with privacy standards',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Your Rights',
                    [
                      '• You can access your personal data at any time',
                      '• You can update or correct your information',
                      '• You can delete your account and data',
                      '• You can opt out of marketing communications',
                      '• You can request a copy of your data',
                    ],
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 24)),

              // Terms of Service Section
              _buildSection(
                context,
                'Terms of Service',
                Icons.description_outlined,
                [
                  _buildSubsection(
                    context,
                    'Acceptance of Terms',
                    [
                      'By using our app, you agree to be bound by these terms and conditions.',
                      'If you do not agree to these terms, please do not use our service.',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Service Description',
                    [
                      '• Free Coffee App provides a rewards platform for coffee enthusiasts',
                      '• Users can earn points by watching ads and completing surveys',
                      '• Points can be redeemed for coffee at participating locations',
                      '• We reserve the right to modify or discontinue services',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'User Responsibilities',
                    [
                      '• Provide accurate and truthful information',
                      '• Maintain the security of your account',
                      '• Use the service in compliance with applicable laws',
                      '• Do not attempt to manipulate or abuse the reward system',
                      '• Respect other users and our community guidelines',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Prohibited Activities',
                    [
                      '• Creating multiple accounts to gain unfair advantages',
                      '• Using automated tools or bots',
                      '• Attempting to hack or compromise our systems',
                      '• Sharing false or misleading information',
                      '• Violating any applicable laws or regulations',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Rewards and Redemptions',
                    [
                      '• Rewards are subject to availability and terms',
                      '• We reserve the right to modify reward values',
                      '• Redemptions are final and non-refundable',
                      '• Points may expire after a period of inactivity',
                    ],
                  ),
                  _buildSubsection(
                    context,
                    'Limitation of Liability',
                    [
                      '• Our service is provided "as is" without warranties',
                      '• We are not liable for any indirect or consequential damages',
                      '• Our liability is limited to the amount you paid for the service',
                      '• We are not responsible for third-party services or content',
                    ],
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 24)),

              // Contact Information
              _buildSection(
                context,
                'Contact Us',
                Icons.contact_support_outlined,
                [
                  Container(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getResponsivePadding(context, 16)),
                    decoration: BoxDecoration(
                      color: Color(0xFFC69C6D).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 12)),
                      border: Border.all(color: Color(0xFFC69C6D)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'If you have any questions about this Privacy Policy or Terms of Service, please contact us:',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Color(0xFFC69C6D),
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 12)),
                        _buildContactItem(
                            context, 'Email:', 'info@freecoffeestore.com'),
                        _buildContactItem(
                            context, 'Website:', 'https://freecoffeestore.com'),
                        _buildContactItem(
                            context, 'Response Time:', 'Within 24-48 hours'),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 32)),

              // Footer
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 12)),
                ),
                child: Text(
                  'By using our app, you acknowledge that you have read and understood this Privacy Policy and Terms of Service.',
                  style: GoogleFonts.inter(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon,
      List<Widget> children) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset:
                Offset(0, ResponsiveHelper.getResponsivePadding(context, 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFFC69C6D), size: 24),
              SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context, 12)),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubsection(
      BuildContext context, String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(
                    bottom: ResponsiveHelper.getResponsivePadding(context, 4)),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: Color(0xFFC69C6D),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 8)),
          Expanded(
            child: Text(
              value,
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
}
