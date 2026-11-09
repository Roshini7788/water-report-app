import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2B45).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.lightBlue,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 64,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryBlue),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primaryBlue),
                label: 'Report',
              ),
              NavigationDestination(
                icon: Icon(Icons.format_list_bulleted_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryBlue),
                label: 'My Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
