import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../applications/presentation/applications_screen.dart';
import '../../explore/presentation/explore_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/models/profile_data.dart';
import '../../profile/presentation/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(
      onExplore: () {
        _selectTab(1);
      },
    ),
    const ExploreScreen(),
    const ApplicationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await ProfileData.instance.loadCurrentUser();
  }

  void _selectTab(int index) {
    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavigationItemTapped(int index) {
    _selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected:
                _onNavigationItemTapped,
            backgroundColor: AppColors.surface,
            indicatorColor:
                AppColors.primaryLight,
            height: 72,
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                ),
                selectedIcon: Icon(
                  Icons.home,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.explore_outlined,
                ),
                selectedIcon: Icon(
                  Icons.explore,
                ),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.assignment_outlined,
                ),
                selectedIcon: Icon(
                  Icons.assignment,
                ),
                label: 'Applications',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                ),
                selectedIcon: Icon(
                  Icons.person,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}