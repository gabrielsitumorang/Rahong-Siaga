import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';
import 'simulator_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToMap: () => setState(() => _currentIndex = 1),
        onNavigateToSimulator: () => setState(() => _currentIndex = 2),
      ),
      const MapScreen(),
      const SimulatorScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderGold, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.royalPurpleDeep,
          indicatorColor: AppColors.royalPurplePrimary.withOpacity(0.6),
          elevation: 10,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.paleGold),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.map_rounded, color: AppColors.paleGold),
              label: 'Peta Spasial',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.tune_rounded, color: AppColors.paleGold),
              label: 'Simulasi What-If',
            ),
          ],
        ),
      ),
    );
  }
}
