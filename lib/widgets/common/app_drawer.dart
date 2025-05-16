import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
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
        // 실제 페이지 이동 로직 (routeName에 따라 분기)
        if (routeName == AppRoutes.home) { // 예시: 홈으로 이동
          Navigator.pushNamed(context, AppRoutes.home);
        } else if (routeName == AppRoutes.notice) { // 예시: 공지사항
            Navigator.pushNamed(context, AppRoutes.notice);
        } else if (routeName == AppRoutes.qna) { // 예시: QNA
            Navigator.pushNamed(context, AppRoutes.qna);
        } else if (routeName == 'logout') {
          // 로그아웃 로직
          Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.pushReplacementNamed(context, AppRoutes.login); 
        }
        // TODO: 나머지 라우트들에 대한 네비게이션 로직 추가
        print('Navigate to: $routeName');
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
            _buildMenuCategory('조합소개'),
            _buildMenuItem(context, '조합장 인사', 'introduction_greeting', Icons.person_outline),
            _buildMenuItem(context, '사무실 안내', 'introduction_office', Icons.location_on_outlined),
            _buildMenuItem(context, '조직도', 'introduction_organization', Icons.groups_outlined),
            const Divider(),
            _buildMenuCategory('재개발소개'),
            _buildMenuItem(context, '재개발 진행 과정', 'redevelopment_process', Icons.timeline_outlined),
            _buildMenuItem(context, '재개발 정보', 'redevelopment_info', Icons.info_outline),
            const Divider(),
            _buildMenuCategory('커뮤니티'),
            _buildMenuItem(context, '공지사항', AppRoutes.notice, Icons.campaign_outlined),
            _buildMenuItem(context, 'Q&A', AppRoutes.qna, Icons.question_answer_outlined),
            _buildMenuItem(context, '정보공유방', 'community_info_share', Icons.share_outlined),
            // 관리자 메뉴 (조건부 렌더링 제거)
            // if (authProvider.isLoggedIn && authProvider.isAdmin) ...[
              const Divider(),
              _buildMenuCategory('관리자'),
              _buildMenuItem(context, '슬라이드 관리', 'admin_slide', Icons.slideshow_outlined),
              _buildMenuItem(context, '업체소개 관리', 'admin_partner', Icons.business_center_outlined),
              _buildMenuItem(context, '배너 관리', 'admin_banner', Icons.ad_units_outlined),
              _buildMenuItem(context, '알림톡 관리', 'admin_alimtalk', Icons.sms_outlined),
              _buildMenuItem(context, '사용자 관리', 'admin_user', Icons.manage_accounts_outlined),
              _buildMenuItem(context, '기본정보 관리', 'admin_basic_info', Icons.settings_outlined),
            // ], // 조건부 렌더링 제거
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.grey[600]),
              title: const Text(
                '로그아웃',
                style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    color: Colors.black87),
              ),
              onTap: () {
                setState(() {
                  _selectedRoute = 'logout'; // 로그아웃도 선택 상태로 표시 (선택적)
                });
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            ),
          ],
        ),
      ),
    );
  }
} 