import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/dashboard_screen.dart';
import '../screens/main/favorites_screen.dart';
import '../screens/main/player_screen.dart'; // <--- Added import
import '../screens/main/settings_screen.dart';
import '../core/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';
import '../core/providers/theme_provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static _MainScaffoldState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainScaffoldState>();
  }

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  final List<Widget> _screens = [
    HomeScreen(),
    PlayerScreen(), // <--- Replaced placeholder
    FavoritesScreen(),
    DashboardScreen(), // Mapping profile icon to Dashboard since dashboard has user stats
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Current Tab
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: AppColors.isDarkMode ? 0.6 : 0.8),
                    border: Border(
                      top: BorderSide(color: AppColors.outline.withValues(alpha: 0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home, 'Home'),
                      _buildNavItem(1, Icons.play_circle_outline, 'Player'),
                      _buildNavItem(2, Icons.favorite_outline, 'Favorites'),
                      _buildNavItem(3, Icons.person_outline, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 48, color: AppColors.onPrimaryFixed),
                  SizedBox(height: 16),
                  Text('MELODY', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.onPrimaryFixed, fontWeight: FontWeight.w900, letterSpacing: 4)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_outlined, color: AppColors.outline),
            title: Text('Home', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              changeTab(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: AppColors.outline),
            title: Text('Profile', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              changeTab(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined, color: AppColors.outline),
            title: Text('Settings', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.outline,
                ),
                title: Text(
                  themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(color: AppColors.onSurface),
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('Log Out', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await FirebaseAuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/gateway', (route) => false);
              }
            },
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.5), blurRadius: 10),
                ],
              )
            : BoxDecoration(
                color: Colors.transparent,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.onPrimaryFixed : Colors.grey[500],
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                letterSpacing: 2,
                color: isSelected ? AppColors.onPrimaryFixed : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
