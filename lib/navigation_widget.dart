import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';
import 'user_profile_page.dart';
import 'about_app_page.dart';
import 'utils/responsive_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const HomePage(),
    const UserProfilePage(),
    const AboutAppPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: Container(
        height: ResponsiveHelper.getResponsivePadding(context, 64),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF5516),
          unselectedItemColor: Colors.black54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (int index) async {
            if (index == 3) {
              final Uri url = Uri.parse('https://freecoffeestore.com');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              activeIcon: Icon(
                Icons.home_rounded,
                size: ResponsiveHelper.getResponsiveIconSize(context, 26),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              activeIcon: Icon(Icons.person_rounded,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_rounded,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              activeIcon: Icon(Icons.info,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              activeIcon: Icon(Icons.shopping_bag,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 26)),
              label: 'Shop',
            ),
          ],
        ),
      ),
    );
  }
}
