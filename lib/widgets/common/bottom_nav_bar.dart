import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textTertiaryColor,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          showUnselectedLabels: true,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: (index) {
            _handleNavigation(context, index, isAdmin);
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: '홈',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.business_rounded),
              label: '조합소개',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.apartment_rounded),
              label: '재개발',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.forum_rounded),
              label: '커뮤니티',
            ),
            if (isAdmin)
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_rounded),
                label: '관리자',
              ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index, bool isAdmin) {
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.associationIntro);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.developmentProcess);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.notice);
        break;
      case 4:
        if (isAdmin) {
          Navigator.pushNamed(context, AppRoutes.adminHome);
        }
        break;
    }
  }
} 