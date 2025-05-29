import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _selectedRoute;

  Widget _buildMenuCategory(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
          fontFamily: 'Wanted Sans',
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String routeName,
    IconData? icon, // 아이콘 추가 (선택 사항)
  ) {
    final bool isSelected = _selectedRoute == routeName;
    return ListTile(
      leading: icon != null ? Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600]) : null,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Wanted Sans',
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFF2F2F2),
      onTap: () {
        setState(() {
          _selectedRoute = routeName;
        });
        Navigator.pop(context); // Drawer 닫기
        
        print('[AppDrawer] MenuItem clicked: $title, route: $routeName');
        
        // 고정 경로 처리 (logout, splash, 404 등)
        if (routeName == 'logout') {
          // 로그아웃 로직
          Provider.of<AuthProvider>(context, listen: false).logout();
          
          // 현재 슬러그를 가져옵니다
          final unionProvider = Provider.of<UnionProvider>(context, listen: false);
          final slug = unionProvider.currentUnion?.homepage;
          
          if (slug != null) {
            print('[AppDrawer] Logout - Navigating to /$slug/${AppRoutes.login}');
            Navigator.pushReplacementNamed(context, '/$slug/${AppRoutes.login}');
          } else {
            // 슬러그가 없는 경우 (비정상적인 상황) 404로 이동
            print('[AppDrawer] Logout - No slug, navigating to 404');
            Navigator.pushReplacementNamed(context, AppRoutes.notFound);
          }
          return;
        }
        
        // 고정 경로 (slash로 시작하는 경우)
        if (routeName.startsWith('/')) {
          print('[AppDrawer] Navigating to fixed path: $routeName');
          Navigator.pushNamed(context, routeName);
          return;
        }
        
        // 관리자 페이지 처리 (routeName이 'admin/'으로 시작하는 경우)
        if (routeName.startsWith('admin/')) {
          // admin/ 접두사를 제거하고 직접 경로로 이동
          final adminPath = '/$routeName';
          print('[AppDrawer] Navigating to admin path: $adminPath');
          Navigator.pushNamed(context, adminPath);
          return;
        }
        
        // 그 외 일반 라우트 처리 (슬러그 포함)
        final unionProvider = Provider.of<UnionProvider>(context, listen: false);
        final slug = unionProvider.currentUnion?.homepage;
        
        if (slug != null) {
          // 슬러그를 포함한 전체 경로
          final fullPath = '/$slug/$routeName';
          print('[AppDrawer] Navigating with slug: $fullPath');
          Navigator.pushNamed(context, fullPath);
        } else {
          // 슬러그가 없는 경우 (비정상적인 상황) 404로 이동
          print('[AppDrawer] No slug available, navigating to 404');
          Navigator.pushNamed(context, AppRoutes.notFound);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면 너비의 75%를 Drawer 너비로 사용 (조정 가능)
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75;
    final authProvider = Provider.of<AuthProvider>(context);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // "메뉴" 타이틀
            Container(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0), // 상단 여백 추가
              alignment: Alignment.centerLeft,
              child: const Text(
                '메뉴',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Wanted Sans',
                ),
              ),
            ),
            _buildMenuItem(context, '홈', AppRoutes.home, Icons.home_outlined),
            const Divider(),
            _buildMenuCategory('조합소개'),
            _buildMenuItem(context, '조합장 인사', AppRoutes.associationIntro, Icons.person_outline),
            _buildMenuItem(context, '사무실 안내', AppRoutes.officeInfo, Icons.location_on_outlined),
            _buildMenuItem(context, '조직도', AppRoutes.organization, Icons.groups_outlined),
            const Divider(),
            _buildMenuCategory('재개발소개'),
            _buildMenuItem(context, '재개발 진행 과정', AppRoutes.developmentProcess, Icons.timeline_outlined),
            _buildMenuItem(context, '재개발 정보', AppRoutes.developmentInfo, Icons.info_outline),
            const Divider(),
            _buildMenuCategory('커뮤니티'),
            _buildMenuItem(context, '공지사항', AppRoutes.notice, Icons.campaign_outlined),
            _buildMenuItem(context, 'Q&A', AppRoutes.qna, Icons.question_answer_outlined),
            _buildMenuItem(context, '정보공유방', AppRoutes.infoSharing, Icons.share_outlined),
            // 관리자 메뉴 (조건부 렌더링)
            if (authProvider.isLoggedIn && authProvider.isAdmin) ...[
              const Divider(),
              _buildMenuCategory('관리자'),
              _buildMenuItem(context, '관리자 홈', '/admin/${AppRoutes.adminHome}', Icons.admin_panel_settings_outlined),
              _buildMenuItem(context, '슬라이드 관리', '/admin/${AppRoutes.slideManage}', Icons.slideshow_outlined),
              _buildMenuItem(context, '업체소개 관리', '/admin/${AppRoutes.companyManage}', Icons.business_center_outlined),
              _buildMenuItem(context, '배너 관리', '/admin/${AppRoutes.adminBanner}', Icons.ad_units_outlined),
              _buildMenuItem(context, '알림톡 관리', '/admin/${AppRoutes.alarmManage}', Icons.sms_outlined),
              _buildMenuItem(context, '사용자 관리', '/admin/${AppRoutes.userManage}', Icons.manage_accounts_outlined),
              _buildMenuItem(context, '기본정보 관리', '/admin/${AppRoutes.adminBasicInfo}', Icons.settings_outlined),
            ],
            const Divider(),
            _buildMenuItem(context, '로그아웃', 'logout', Icons.logout),
          ],
        ),
      ),
    );
  }
} 