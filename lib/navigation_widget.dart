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
        backgroundColor: Color(0xFFC69C6D),
        elevation: 0,
      ),
      body: SafeArea(
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: Container(
        height: ResponsiveHelper.getResponsivePadding(context, 63),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 25)),
            topRight: Radius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 25)),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFFC69C6D),
            unselectedItemColor: Colors.grey[400],
            selectedFontSize:
                ResponsiveHelper.getResponsiveFontSize(context, 0),
            unselectedFontSize:
                ResponsiveHelper.getResponsiveFontSize(context, 0),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (int index) async {
              if (index == 3) {
                // Shops tab - open URL
                final Uri url = Uri.parse('https://freecoffeestore.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } else {
                // Other tabs - normal navigation
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    color: _currentIndex == 0
                        ? Color(0xFFC69C6D)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                    color: _currentIndex == 0
                        ? Color(0xFFFFFFFF)
                        : Color(0xFFC69C6D),
                  ),
                ),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    color: _currentIndex == 1
                        ? Color(0xFFC69C6D)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                    color: _currentIndex == 1
                        ? Color(0xFFFFFFFF)
                        : Color(0xFFC69C6D),
                  ),
                ),
                label: 'PROFILE',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    color: _currentIndex == 2
                        ? Color(0xFFC69C6D)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.info_rounded,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                    color: _currentIndex == 2
                        ? Color(0xFFFFFFFF)
                        : Color(0xFFC69C6D),
                  ),
                ),
                label: 'ABOUT',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    color: _currentIndex == 3
                        ? Color(0xFFC69C6D)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.local_cafe_rounded,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                    color: _currentIndex == 3
                        ? Color(0xFFFFFFFF)
                        : Color(0xFFC69C6D),
                  ),
                ),
                label: 'SHOPS',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
