import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showActions;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showActions = true,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      actions: showActions
          ? actions ??
              [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isLoggedIn) {
                      return PopupMenuButton<String>(
                        offset: const Offset(0, 50),
                        icon: const Icon(Icons.person_rounded),
                        onSelected: (value) {
                          if (value == 'profile') {
                            Navigator.pushNamed(context, AppRoutes.profile);
                          } else if (value == 'logout') {
                            // 로그아웃 구현
                            authProvider.logout();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.landing,
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, color: AppTheme.textPrimaryColor),
                                  SizedBox(width: 8),
                                  Text('내 정보'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout, color: AppTheme.textPrimaryColor),
                                  SizedBox(width: 8),
                                  Text('로그아웃'),
                                ],
                              ),
                            ),
                          ];
                        },
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.login_rounded),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
              ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 