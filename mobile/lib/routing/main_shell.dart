import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/theme/app_theme.dart';

/// Main scaffold with bottom navigation bar — matches wireframe .bottom-nav
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.gray200, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.gray400),
              selectedIcon: Icon(Icons.home, color: AppColors.greenMain),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: AppColors.gray400),
              selectedIcon: Icon(Icons.bar_chart, color: AppColors.greenMain),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined, color: AppColors.gray400),
              selectedIcon: Icon(Icons.person, color: AppColors.greenMain),
              label: 'Avatar',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.gray400),
              selectedIcon: Icon(Icons.settings, color: AppColors.greenMain),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
