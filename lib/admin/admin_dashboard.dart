import 'package:flutter/material.dart';
import 'package:rewarded_interstitial_example/utils/responsive_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/coffee_redemption_service.dart';
import '../services/app_config_service.dart';
import '../widgets/role_based_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _redemptions = [];
  bool _isLoading = true;
  String _selectedTab = 'overview';
  bool _isSidebarCollapsed = false;
  bool _isMobile = false;

  // Loading states for configuration updates
  Map<String, bool> _configLoadingStates = {};

  // User management pagination and search
  final ScrollController _usersScrollController = ScrollController();
  final TextEditingController _userSearchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoadingMoreUsers = false;
  bool _hasMoreUsers = true;
  int _currentUserPage = 0;
  final int _usersPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRedemptions();
    _setupUserScrollListener();
  }

  @override
  void dispose() {
    _usersScrollController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkScreenSize();
  }

  void _checkScreenSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile != _isMobile) {
      setState(() {
        _isMobile = isMobile;
        _isSidebarCollapsed = isMobile;
      });
    }
  }

  Future<void> _loadUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _currentUserPage = 0;
        _hasMoreUsers = true;
        _allUsers.clear();
        _filteredUsers.clear();
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Try different approaches to get all users
      List<dynamic> response;

      try {
        // First try: Direct query with pagination
        response = await Supabase.instance.client
            .from('profiles')
            .select("*")
            .order('created_at', ascending: false)
            .range(0, _usersPerPage - 1);
      } catch (directError) {
        // Second try: Use RPC function if available
        try {
          response = await Supabase.instance.client
              .from('profiles')
              .select("*")
              .range(0, _usersPerPage - 1);
        } catch (simpleError) {
          response = [];
        }
      }

      setState(() {
        _allUsers = List<Map<String, dynamic>>.from(response);
        _filteredUsers = List.from(_allUsers);
        _users = _filteredUsers;
        _isLoading = false;
        _hasMoreUsers = response.length == _usersPerPage;
        _currentUserPage = 1;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMoreUsers || !_hasMoreUsers) return;

    setState(() {
      _isLoadingMoreUsers = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false)
          .range(_currentUserPage * _usersPerPage,
              (_currentUserPage + 1) * _usersPerPage - 1);

      setState(() {
        _allUsers.addAll(List<Map<String, dynamic>>.from(response));
        _filteredUsers = List.from(_allUsers);
        _users = _filteredUsers;
        _isLoadingMoreUsers = false;
        _hasMoreUsers = response.length == _usersPerPage;
        _currentUserPage++;
      });
    } catch (error) {
      setState(() {
        _isLoadingMoreUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading more users: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupUserScrollListener() {
    _usersScrollController.addListener(() {
      if (_usersScrollController.position.pixels >=
          _usersScrollController.position.maxScrollExtent - 200) {
        _loadMoreUsers();
      }
    });
  }

  void _searchUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = (user['full_name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }
      _users = _filteredUsers;
    });
  }

  Future<void> _loadRedemptions() async {
    try {
      try {
        final allData = await Supabase.instance.client
            .from('coffee_redemptions')
            .select('*')
            .order('redemption_date', ascending: false);

        // Sort redemptions with pending status first, then by date
        final sortedData = List<Map<String, dynamic>>.from(allData);
        sortedData.sort((a, b) {
          final statusA = (a['status'] as String?)?.toLowerCase() ?? '';
          final statusB = (b['status'] as String?)?.toLowerCase() ?? '';

          // Pending status gets priority
          if (statusA == 'pending' && statusB != 'pending') return -1;
          if (statusA != 'pending' && statusB == 'pending') return 1;

          // If both have same status priority, sort by date (newest first)
          final dateA =
              DateTime.tryParse(a['redemption_date'] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b['redemption_date'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _redemptions = sortedData;
        });
        return;
      } catch (simpleError) {}

      // If simple query failed, try with limit
      try {
        final limitedData = await Supabase.instance.client
            .from('coffee_redemptions')
            .select('*')
            .limit(10);

        // Sort redemptions with pending status first, then by date
        final sortedLimitedData = List<Map<String, dynamic>>.from(limitedData);
        sortedLimitedData.sort((a, b) {
          final statusA = (a['status'] as String?)?.toLowerCase() ?? '';
          final statusB = (b['status'] as String?)?.toLowerCase() ?? '';

          // Pending status gets priority
          if (statusA == 'pending' && statusB != 'pending') return -1;
          if (statusA != 'pending' && statusB == 'pending') return 1;

          // If both have same status priority, sort by date (newest first)
          final dateA =
              DateTime.tryParse(a['redemption_date'] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b['redemption_date'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _redemptions = sortedLimitedData;
        });

        return;
      } catch (limitedError) {
        print('❌ Limited query failed: $limitedError');
      }

      // If both failed, show error
      setState(() {
        _redemptions = [];
      });
    } catch (error) {
      setState(() {
        _redemptions = [];
      });
    }
  }

  Future<void> _updateUserCredits(String userId, double newCredits) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'credits': newCredits}).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Credits updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 10))),
        ),
      );

      _loadUsers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating credits: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 10))),
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 15))),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Delete User'),
          ],
        ),
        content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 8))),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .delete()
            .eq('id', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 10))),
          ),
        );

        _loadUsers();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $error'), // ignore: avoid_print
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 10))),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(),
        drawer: _isMobile ? _buildMobileDrawer() : null,
        body: _isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 6)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 6)),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: Color(0xFFC69C6D),
              size: ResponsiveHelper.getResponsiveIconSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Coffee Credit Management',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 11),
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFFC69C6D),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (!_isMobile)
          Container(
            margin: EdgeInsets.only(
                right: ResponsiveHelper.getResponsivePadding(context, 8)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 8)),
            ),
            child: IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
              tooltip:
                  _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
            ),
          ),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade700,
              Colors.brown.shade600,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                  ResponsiveHelper.getResponsivePadding(context, 20),
                  60,
                  ResponsiveHelper.getResponsivePadding(context, 20),
                  20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getResponsivePadding(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveRadius(context, 16)),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFFC69C6D),
                      size: ResponsiveHelper.getResponsiveIconSize(context, 48),
                    ),
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsivePadding(context, 16)),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Coffee Credit Management',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 20)),
                    topRight: Radius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 20)),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                    _buildMobileDrawerItem(
                        'overview', 'Overview', Icons.dashboard),
                    _buildMobileDrawerItem('users', 'Users', Icons.people),
                    _buildMobileDrawerItem(
                        'credits', 'Credits', Icons.attach_money),
                    _buildMobileDrawerItem('coffee_redemptions',
                        'Coffee Redemptions', Icons.local_shipping),
                    // _buildMobileDrawerItem(
                    //     'adgate_test', 'AdGate Test', Icons.quiz),
                    _buildMobileDrawerItem(
                        'configuration', 'Configuration', Icons.settings),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawerItem(String tab, String title, IconData icon) {
    final isSelected = _selectedTab == tab;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.brown.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 12)),
        border: isSelected
            ? Border.all(color: Colors.brown.shade200, width: 1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding:
              EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 8)),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveRadius(context, 8)),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.brown.shade700 : Colors.grey.shade600,
            size: ResponsiveHelper.getResponsiveIconSize(context, 20),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.brown.shade700 : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() {
            _selectedTab = tab;
          });
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile Header
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 20)),
              bottomRight: Radius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 20)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 12)),
                ),
                child: Icon(
                  _getTabIcon(_selectedTab),
                  color: Colors.brown.shade700,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTabTitle(_selectedTab),
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'Manage your Coffee Credit app',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 14),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Mobile Content
        Expanded(
          child: Container(
            margin: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 16)),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Desktop Sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isSidebarCollapsed ? 60 : 220,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 16)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.brown.shade700,
                        Colors.brown.shade600,
                      ],
                    ),
                  ),
                  child: _isSidebarCollapsed
                      ? Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                        context, 8)),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.brown.shade700,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                    context, 20),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveHelper.getResponsivePadding(
                                    context, 8)),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getResponsiveRadius(
                                        context, 8)),
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.brown.shade700,
                                size: ResponsiveHelper.getResponsiveIconSize(
                                    context, 24),
                              ),
                            ),
                            SizedBox(
                                height: ResponsiveHelper.getResponsivePadding(
                                    context, 12)),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Coffee Credit Management',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                        context, 12),
                              ),
                            ),
                          ],
                        ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    child: Column(
                      children: [
                        _buildDesktopSidebarItem(
                            'overview', 'Overview', Icons.dashboard),
                        _buildDesktopSidebarItem(
                            'users', 'Users', Icons.people),
                        _buildDesktopSidebarItem(
                            'credits', 'Credits', Icons.attach_money),
                        _buildDesktopSidebarItem(
                            'offers', 'Offers', Icons.card_giftcard),
                        _buildDesktopSidebarItem(
                            'rewards', 'Rewards', Icons.coffee),
                        _buildDesktopSidebarItem('coffee_redemptions',
                            'Coffee Redemptions', Icons.local_shipping),
                        // _buildDesktopSidebarItem(
                        //     'adgate_test', 'AdGate Test', Icons.quiz),
                        _buildDesktopSidebarItem(
                            'configuration', 'Configuration', Icons.settings),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Desktop Content
        Expanded(
          child: Container(
            margin: EdgeInsets.all(
                ResponsiveHelper.getResponsivePadding(context, 24)),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebarItem(String tab, String title, IconData icon) {
    final isSelected = _selectedTab == tab;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
          vertical: ResponsiveHelper.getResponsivePadding(context, 4)),
      child: _isSidebarCollapsed
          ? Tooltip(
              message: title,
              child: Container(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 12)),
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.brown.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveRadius(context, 12)),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? Colors.brown.shade700 : Colors.grey.shade600,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.brown.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 12)),
                border: isSelected
                    ? Border.all(color: Colors.brown.shade200, width: 1)
                    : null,
              ),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.brown.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 8)),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.brown.shade700
                        : Colors.grey.shade600,
                    size: ResponsiveHelper.getResponsiveIconSize(context, 20),
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.brown.shade700
                        : Colors.grey.shade800,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
            ),
    );
  }

  IconData _getTabIcon(String tab) {
    switch (tab) {
      case 'overview':
        return Icons.dashboard;
      case 'users':
        return Icons.people;
      case 'credits':
        return Icons.attach_money;
      case 'offers':
        return Icons.card_giftcard;
      case 'rewards':
        return Icons.coffee;
      case 'coffee_redemptions':
        return Icons.local_shipping;
      case 'configuration':
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  String _getTabTitle(String tab) {
    switch (tab) {
      case 'overview':
        return 'Dashboard Overview';
      case 'users':
        return 'User Management';
      case 'credits':
        return 'Credit Management';
      case 'coffee_redemptions':
        return 'Coffee Redemptions';
      // case 'adgate_test':
      //   return 'AdGate Test';
      case 'configuration':
        return 'App Configuration';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildMainContent() {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab();
      case 'users':
        return _buildUsersTab();
      case 'credits':
        return _buildCreditsTab();
      case 'coffee_redemptions':
        return _buildCoffeeRedemptionsTab();
      case 'configuration':
        return _buildConfigurationTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    final totalUsers = _users.length;
    final totalCredits = _users.fold<double>(
      0.0,
      (sum, user) {
        final credits = user['credits'];
        if (credits == null) return sum;
        return sum + (credits is num ? credits.toDouble() : 0.0);
      },
    );
    final activeUsers = _users.where((user) {
      final credits = user['credits'];
      if (credits == null) return false;
      return credits is num && credits.toDouble() > 0;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isMobile) ...[
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 6)),
          Text(
            'Monitor your Coffee Credit app performance',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 32)),
        ],
        _buildResponsiveStatsRow(totalUsers, totalCredits, activeUsers),
        SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 32)),
      ],
    );
  }

  Widget _buildResponsiveStatsRow(
      int totalUsers, double totalCredits, int activeUsers) {
    if (_isMobile) {
      return Column(
        children: [
          _buildStatCard(
              'Total Users', totalUsers.toString(), Icons.people, Colors.blue),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          _buildStatCard(
              'Total Credits',
              '\$${totalCredits.toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.green),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 16)),
          _buildStatCard('Active Users', activeUsers.toString(), Icons.person,
              Colors.orange),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
              child: _buildStatCard('Total Users', totalUsers.toString(),
                  Icons.people, Colors.blue)),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 20)),
          Expanded(
              child: _buildStatCard(
                  'Total Credits',
                  '\$${totalCredits.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green)),
          SizedBox(width: ResponsiveHelper.getResponsivePadding(context, 20)),
          Expanded(
              child: _buildStatCard('Active Users', activeUsers.toString(),
                  Icons.person, Colors.orange)),
        ],
      );
    }
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding:
          EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset:
                Offset(0, ResponsiveHelper.getResponsivePadding(context, 2)),
          ),
        ],
      ),
      child: _isMobile
          ? Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 8)),
                  ),
                  child: Icon(icon,
                      color: color,
                      size:
                          ResponsiveHelper.getResponsiveIconSize(context, 20)),
                ),
                SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(
                              context, 4)),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 18),
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 8)),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 8)),
                  ),
                  child: Icon(icon,
                      color: color,
                      size:
                          ResponsiveHelper.getResponsiveIconSize(context, 24)),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 12)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 14),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                    height: ResponsiveHelper.getResponsivePadding(context, 6)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUsersTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
        ),
      );
    }

    return Column(
      children: [
        // Header with search
        Container(
          padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Management',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  Text(
                    '${_users.length} users',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 16)),
              // Search bar
              TextField(
                controller: _userSearchController,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search users by name or email...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon: _userSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          onPressed: () {
                            _userSearchController.clear();
                            _searchUsers('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                    borderSide: BorderSide(color: Colors.brown.shade600),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveHelper.getResponsivePadding(context, 16),
                    vertical:
                        ResponsiveHelper.getResponsivePadding(context, 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Users list with pagination
        Expanded(
          child: _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size:
                            ResponsiveHelper.getResponsiveIconSize(context, 64),
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(
                          height: ResponsiveHelper.getResponsivePadding(
                              context, 16)),
                      Text(
                        _userSearchController.text.isNotEmpty
                            ? 'No users found matching your search'
                            : 'No users found',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 18),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_userSearchController.text.isNotEmpty) ...[
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 8)),
                        TextButton(
                          onPressed: () {
                            _userSearchController.clear();
                            _searchUsers('');
                          },
                          child: Text('Clear search'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _usersScrollController,
                  itemCount: _users.length + (_isLoadingMoreUsers ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _users.length) {
                      // Loading indicator for pagination
                      return Container(
                        padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.brown.shade600),
                          ),
                        ),
                      );
                    }

                    final user = _users[index];
                    return Container(
                      margin: EdgeInsets.only(
                          bottom: ResponsiveHelper.getResponsivePadding(
                              context, 12)),
                      child: _buildUserTile(user),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final credits = (user['credits'] as num?)?.toDouble() ?? 0.0;

    if (_isMobile) {
      return Card(
        margin: EdgeInsets.all(0),
        child: Padding(
          padding: EdgeInsets.all(
              ResponsiveHelper.getResponsivePadding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.brown.shade100,
                    radius: ResponsiveHelper.getResponsiveRadius(context, 20),
                    child: Text(
                      (user['full_name'] as String?)
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          (user['email'] as String?)
                              ?.substring(0, 1)
                              .toUpperCase() ??
                          'U',
                      style: TextStyle(
                        color: Colors.brown.shade700,
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 16),
                      ),
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
                          user['full_name'] ?? user['email'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 16),
                          ),
                        ),
                        Text(
                          user['email'] ?? 'No email',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 12),
                          ),
                        ),
                        Text(
                          'Credits: \$${credits.toStringAsFixed(2)} | Coffee: ${user['coffee_count'] ?? 0}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 8)),
              Text(
                'Joined: ${_formatDate(user['created_at'])}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showEditCreditsDialog(user),
                    icon: Icon(
                      Icons.edit,
                      size: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                    label: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveHelper.getResponsivePadding(context, 8)),
                  ElevatedButton.icon(
                    onPressed: () => _deleteUser(user['id']),
                    icon: Icon(
                      Icons.delete,
                      size: ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown.shade100,
          child: Text(
            (user['full_name'] as String?)?.substring(0, 1).toUpperCase() ??
                (user['email'] as String?)?.substring(0, 1).toUpperCase() ??
                'U',
            style: TextStyle(color: Colors.brown.shade700),
          ),
        ),
        title: Text(user['full_name'] ?? user['email'] ?? 'Unknown'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? 'No email'),
            Text('Credits: \$${credits.toStringAsFixed(2)}'),
            Text('Joined: ${_formatDate(user['created_at'])}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditCreditsDialog(user),
              tooltip: 'Edit Credits',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteUser(user['id']),
              tooltip: 'Delete User',
            ),
          ],
        ),
      );
    }
  }

  void _showEditCreditsDialog(Map<String, dynamic> user) {
    final creditsController = TextEditingController(
      text: (user['credits'] as num?)?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Credits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${user['full_name'] ?? user['email']}'),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 16)),
            TextField(
              controller: creditsController,
              decoration: InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final newCredits = double.tryParse(creditsController.text) ?? 0.0;
              _updateUserCredits(user['id'], newCredits);
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsTab() {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context, 16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Credit Statistics',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 16)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildCreditStats(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditStats() {
    final totalCredits = _users.fold<double>(
      0.0,
      (sum, user) {
        final credits = user['credits'];
        if (credits == null) return sum;
        return sum + (credits is num ? credits.toDouble() : 0.0);
      },
    );
    final averageCredits =
        _users.isNotEmpty ? totalCredits / _users.length : 0.0;
    final maxCredits = _users.fold<double>(
      0.0,
      (max, user) {
        final credits = user['credits'];
        if (credits == null) return max;
        final creditValue = credits is num ? credits.toDouble() : 0.0;
        return creditValue > max ? creditValue : max;
      },
    );

    return Column(
      children: [
        _buildStatRow(
            'Total Credits in System', '\$${totalCredits.toStringAsFixed(2)}'),
        _buildStatRow('Average Credits per User',
            '\$${averageCredits.toStringAsFixed(2)}'),
        _buildStatRow(
            'Highest User Credits', '\$${maxCredits.toStringAsFixed(2)}'),
        _buildStatRow('Total Users', _users.length.toString()),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsivePadding(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeRedemptionsTab() {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _redemptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: ResponsiveHelper.getResponsiveIconSize(
                              context, 64),
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 16)),
                        Text(
                          'No coffee redemptions yet',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveHelper.getResponsivePadding(
                                context, 8)),
                        Text(
                          'Coffee bag redemptions will appear here',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 14),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isMobile
                    ? _buildMobileRedemptionsList()
                    : _buildDesktopRedemptionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRedemptionsList() {
    return ListView.builder(
      itemCount: _redemptions.length,
      itemBuilder: (context, index) {
        final redemption = _redemptions[index];
        return _buildMobileRedemptionCard(redemption);
      },
    );
  }

  Widget _buildDesktopRedemptionsList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
                vertical: ResponsiveHelper.getResponsivePadding(context, 12)),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveRadius(context, 8)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ))),
                Expanded(
                    flex: 1,
                    child: Text('Credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ))),
                Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ))),
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ))),
                Expanded(
                    flex: 1,
                    child: Text('Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 12),
                        ))),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
          // Redemption rows
          ..._redemptions
              .map((redemption) => _buildDesktopRedemptionRow(redemption)),
        ],
      ),
    );
  }

  Widget _buildMobileRedemptionCard(Map<String, dynamic> redemption) {
    final status = redemption['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 12)),
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    redemption['user_id'] ?? 'Unknown User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 16),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveHelper.getResponsivePadding(context, 8),
                      vertical:
                          ResponsiveHelper.getResponsivePadding(context, 4)),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveRadius(context, 12)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
            Text(
              'Credits: ${redemption['credits_spent']}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              'Date: ${_formatDate(redemption['redemption_date'])}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (redemption['shipping_address'] != null) ...[
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 8)),
              Text(
                'Address: ${redemption['shipping_address']}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                ),
              ),
            ],
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 12)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(redemption),
                    child: Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                    width: ResponsiveHelper.getResponsivePadding(context, 8)),
                IconButton(
                  onPressed: () => _showRedemptionDetails(redemption),
                  icon: Icon(Icons.info_outline),
                  tooltip: 'View Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRedemptionRow(Map<String, dynamic> redemption) {
    final status = redemption['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 8)),
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(context, 16),
          vertical: ResponsiveHelper.getResponsivePadding(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveRadius(context, 8)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              redemption['user_id'] ?? 'Unknown User',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${redemption['credits_spent']}',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsivePadding(context, 6),
                  vertical: ResponsiveHelper.getResponsivePadding(context, 4)),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveRadius(context, 8)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(redemption['redemption_date']),
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showStatusUpdateDialog(redemption),
                  icon: Icon(
                    Icons.edit,
                    size: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  ),
                  tooltip: 'Update Status',
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 4)),
                  constraints: BoxConstraints(
                      minWidth:
                          ResponsiveHelper.getResponsivePadding(context, 32),
                      minHeight:
                          ResponsiveHelper.getResponsivePadding(context, 32)),
                ),
                IconButton(
                  onPressed: () => _showRedemptionDetails(redemption),
                  icon: Icon(
                    Icons.info_outline,
                    size: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  ),
                  tooltip: 'View Details',
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getResponsivePadding(context, 4)),
                  constraints: BoxConstraints(
                      minWidth:
                          ResponsiveHelper.getResponsivePadding(context, 32),
                      minHeight:
                          ResponsiveHelper.getResponsivePadding(context, 32)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog(Map<String, dynamic> redemption) {
    String currentStatus = redemption['status'] ?? 'pending';
    String? trackingNumber = redemption['tracking_number'];
    String? notes = redemption['notes'];

    final statusController = TextEditingController(text: currentStatus);
    final trackingController =
        TextEditingController(text: trackingNumber ?? '');
    final notesController = TextEditingController(text: notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Redemption Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: const OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                ),
                items: [
                  'pending',
                  'confirmed',
                  'shipped',
                  'delivered',
                  'cancelled'
                ]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 12),
                                ),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    statusController.text = value;
                  }
                },
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 16)),
              TextField(
                controller: trackingController,
                decoration: InputDecoration(
                  labelText: 'Tracking Number (Optional)',
                  border: const OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 12),
                    ),
              ),
              SizedBox(
                  height: ResponsiveHelper.getResponsivePadding(context, 16)),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: const OutlineInputBorder(),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 12),
                    ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await CoffeeRedemptionService.updateRedemptionStatus(
                  redemptionId: redemption['id'],
                  status: statusController.text,
                  trackingNumber: trackingController.text.isNotEmpty
                      ? trackingController.text
                      : null,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );

                Navigator.of(context).pop();
                _loadRedemptions();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Redemption status updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Update',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRedemptionDetails(Map<String, dynamic> redemption) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Redemption Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', redemption['user_id'] ?? 'Unknown'),
              _buildDetailRow(
                  'Credits Spent', '${redemption['credits_spent']}'),
              _buildDetailRow(
                  'Status', (redemption['status'] ?? 'pending').toUpperCase()),
              _buildDetailRow(
                  'Date', _formatDate(redemption['redemption_date'])),
              if (redemption['shipping_address'] != null)
                _buildDetailRow(
                    'Shipping Address', redemption['shipping_address']),
              if (redemption['tracking_number'] != null)
                _buildDetailRow(
                    'Tracking Number', redemption['tracking_number']),
              if (redemption['notes'] != null)
                _buildDetailRow('Notes', redemption['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsivePadding(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ResponsiveHelper.getResponsivePadding(context, 120),
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 12),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildConfigurationTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfigSection(),
        ],
      ),
    );
  }

  Widget _buildConfigSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: AppConfigService.getAppConfig(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
          ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading configuration: ${snapshot.error}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        }

        final config = snapshot.data ?? {};
        return Column(
          children: [
            _buildConfigCard(
              'Credit Earning Settings',
              [
                _buildConfigField(
                  'Ads Credit Earning Percentage',
                  'Percentage of ad revenue converted to user credits',
                  config['ads_credit_earning_percentage']?.toString() ?? '0.1',
                  (value) => _updateConfig('ads_credit_earning_percentage',
                      double.tryParse(value) ?? 0.1),
                  configKey: 'ads_credit_earning_percentage',
                ),
                _buildConfigField(
                  'Survey Credit Earning Percentage',
                  'Percentage of survey rewards converted to user credits',
                  config['survey_credit_earning_percentage']?.toString() ??
                      '0.1',
                  (value) => _updateConfig('survey_credit_earning_percentage',
                      double.tryParse(value) ?? 0.1),
                  configKey: 'survey_credit_earning_percentage',
                ),
                _buildConfigField(
                  'Ad Earning Multiplier',
                  'Multiplier for ad-based earnings',
                  config['ad_earning_multiplier']?.toString() ?? '1.0',
                  (value) => _updateConfig(
                      'ad_earning_multiplier', double.tryParse(value) ?? 1.0),
                  configKey: 'ad_earning_multiplier',
                ),
                _buildConfigField(
                  'Survey Earning Multiplier',
                  'Multiplier for survey-based earnings',
                  config['survey_earning_multiplier']?.toString() ?? '1.0',
                  (value) => _updateConfig('survey_earning_multiplier',
                      double.tryParse(value) ?? 1.0),
                  configKey: 'survey_earning_multiplier',
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 20)),
            _buildConfigCard(
              'Bonus Settings',
              [
                _buildConfigField(
                  'Daily Check-in Bonus',
                  'Credits awarded for daily app visits',
                  config['daily_checkin_bonus']?.toString() ?? '1.0',
                  (value) => _updateConfig(
                      'daily_checkin_bonus', double.tryParse(value) ?? 1.0),
                  configKey: 'daily_checkin_bonus',
                ),
                _buildConfigField(
                  'Referral Bonus',
                  'Credits awarded for successful referrals',
                  config['referral_bonus']?.toString() ?? '5.0',
                  (value) => _updateConfig(
                      'referral_bonus', double.tryParse(value) ?? 5.0),
                  configKey: 'referral_bonus',
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 20)),
            _buildConfigCard(
              'Redemption Settings',
              [
                _buildConfigField(
                  'Minimum Redemption Amount',
                  'Minimum credits required for coffee redemption',
                  config['minimum_redemption_amount']?.toString() ?? '15.0',
                  (value) => _updateConfig('minimum_redemption_amount',
                      double.tryParse(value) ?? 15.0),
                  configKey: 'minimum_redemption_amount',
                ),
                _buildConfigField(
                  'Max Daily Earning Limit',
                  'Maximum credits users can earn per day',
                  config['max_daily_earning_limit']?.toString() ?? '50.0',
                  (value) => _updateConfig('max_daily_earning_limit',
                      double.tryParse(value) ?? 50.0),
                  configKey: 'max_daily_earning_limit',
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 20)),
            _buildConfigCard(
              'App Settings',
              [
                _buildConfigField(
                  'App Version',
                  'Current app version',
                  config['app_version']?.toString() ?? '1.0.0',
                  (value) => _updateConfig('app_version', value),
                  configKey: 'app_version',
                ),
                _buildConfigField(
                  'Maintenance Mode',
                  'Enable/disable app maintenance mode',
                  config['maintenance_mode']?.toString() ?? 'false',
                  (value) => _updateConfig(
                      'maintenance_mode', value.toLowerCase() == 'true'),
                  configKey: 'maintenance_mode',
                ),
              ],
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 20)),
          ],
        );
      },
    );
  }

  Widget _buildConfigCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:
            EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(
                height: ResponsiveHelper.getResponsivePadding(context, 16)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildConfigField(String label, String description,
      String currentValue, Function(String) onChanged,
      {String? configKey}) {
    final controller = TextEditingController(text: currentValue);
    final isLoading =
        configKey != null ? (_configLoadingStates[configKey] ?? false) : false;

    return Padding(
      padding: EdgeInsets.only(
          bottom: ResponsiveHelper.getResponsivePadding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 4)),
          Text(
            description,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getResponsivePadding(context, 8)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveHelper.getResponsivePadding(context, 12),
                        vertical:
                            ResponsiveHelper.getResponsivePadding(context, 8)),
                  ),
                ),
              ),
              SizedBox(
                  width: ResponsiveHelper.getResponsivePadding(context, 12)),
              ElevatedButton(
                onPressed: isLoading ? null : () => onChanged(controller.text),
                child: isLoading
                    ? SizedBox(
                        width:
                            ResponsiveHelper.getResponsivePadding(context, 20),
                        height:
                            ResponsiveHelper.getResponsivePadding(context, 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLoading ? Colors.grey.shade400 : Colors.brown.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateConfig(String key, dynamic value) async {
    // Set loading state for this specific config key
    setState(() {
      _configLoadingStates[key] = true;
    });

    try {
      await AppConfigService.updateConfigValue(key, value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Configuration updated successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Refresh the configuration tab
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating configuration: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Clear loading state
      setState(() {
        _configLoadingStates[key] = false;
      });
    }
  }
}
