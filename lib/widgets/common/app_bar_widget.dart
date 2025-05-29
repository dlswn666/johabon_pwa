import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
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
      actions: ResponsiveLayout.isDesktop(context)
          ? [
                // 로그인 상태 표시 및 메뉴
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // 초기화 중일 때는 로딩 표시
                    if (!authProvider.isInitialized) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    
                    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
                      return PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'profile') {
                            // 프로필 페이지로 이동
                            final unionProvider = Provider.of<UnionProvider>(context, listen: false);
                            final slug = unionProvider.currentUnion?.homepage;
                            
                            if (slug != null) {
                              Navigator.pushNamed(context, '/$slug/${AppRoutes.profile}');
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                authProvider.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${authProvider.currentUser!.name}님',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          ),
                        ),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline),
                                const SizedBox(width: 8),
                                Text('내 정보 (${authProvider.isAdmin ? '관리자' : '일반'})'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text('로그아웃'),
                              ],
                            ),
                          ),
                        ],
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