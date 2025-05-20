import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
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
                            // 현재 슬러그 기반으로 프로필 경로 생성
                            final unionProvider = Provider.of<UnionProvider>(context, listen: false);
                            final slug = unionProvider.currentUnion?.homepage;
                            
                            if (slug != null) {
                              Navigator.pushNamed(context, '/$slug/${AppRoutes.profile}');
                            } else {
                              // 현재 슬러그가 없으면 안내 메시지 표시
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('조합 정보를 찾을 수 없습니다.')),
                              );
                            }
                          } else if (value == 'logout') {
                            // 로그아웃 구현
                            authProvider.logout();
                            
                            // 현재 슬러그 기반으로 로그인 페이지로 이동
                            final unionProvider = Provider.of<UnionProvider>(context, listen: false);
                            final slug = unionProvider.currentUnion?.homepage;
                            
                            if (slug != null) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/$slug/${AppRoutes.login}',
                                (route) => false,
                              );
                            } else {
                              // 슬러그가 없으면 404로 이동
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.notFound,
                                (route) => false,
                              );
                            }
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
                          // 현재 슬러그 기반으로 로그인 페이지로 이동
                          final unionProvider = Provider.of<UnionProvider>(context, listen: false);
                          final slug = unionProvider.currentUnion?.homepage;
                          
                          if (slug != null) {
                            Navigator.pushNamed(context, '/$slug/${AppRoutes.login}');
                          } else {
                            // 슬러그가 없으면 안내 메시지 표시
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('조합 정보를 찾을 수 없습니다.')),
                            );
                          }
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