import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/models/banner_model.dart';
import 'package:johabon_pwa/models/notice_model.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';
import 'package:johabon_pwa/widgets/common/custom_card.dart';
import 'package:johabon_pwa/widgets/home/banner_slider.dart';
import 'package:johabon_pwa/widgets/home/info_card.dart';
import 'package:johabon_pwa/widgets/home/notice_card.dart';
import 'package:provider/provider.dart';

// 메뉴 아이템 클래스
class MenuItem {
  final String title;
  final String route;
  
  MenuItem(this.title, this.route);
}

// 웹 헤더용 StatefulWidget
class WebHeader extends StatefulWidget {
  final bool isLoggedIn;
  
  const WebHeader({Key? key, required this.isLoggedIn}) : super(key: key);
  
  @override
  WebHeaderState createState() => WebHeaderState();
}

class WebHeaderState extends State<WebHeader> {
  String? hoveredMenu;
  bool showSubmenu = false;
  OverlayEntry? _submenuOverlay;
  
  // 헤더 바의 고정 높이
  static const double headerHeight = 120;
  
  // 메뉴 정의
  final List<Map<String, dynamic>> menuData = [
    {
      'title': '작전현대아파트구역\n주택재개발정비사업조합',
      'id': 'home',
      'route': AppRoutes.home,
      'hasSubmenu': false,
      'submenu': <MenuItem>[],
    },
    {
      'title': '조합소개',
      'id': 'association',
      'route': AppRoutes.associationIntro,
      'hasSubmenu': true,
      'submenu': [
        MenuItem('조합장 인사', AppRoutes.associationIntro),
        MenuItem('사무실 안내', AppRoutes.officeInfo),
        MenuItem('조직도', AppRoutes.organizationChart),
      ],
    },
    {
      'title': '재개발 소개',
      'id': 'development',
      'route': AppRoutes.developmentProcess,
      'hasSubmenu': true,
      'submenu': [
        MenuItem('재개발 진행 과정', AppRoutes.developmentProcess),
        MenuItem('재개발 정보', AppRoutes.developmentInfo),
      ],
    },
    {
      'title': '커뮤니티',
      'id': 'community',
      'route': AppRoutes.notice,
      'hasSubmenu': true,
      'submenu': [
        MenuItem('공지사항', AppRoutes.notice),
        MenuItem('Q&A', AppRoutes.qna),
        MenuItem('정보공유방', AppRoutes.infoSharing),
      ],
    },
    {
      'title': '관리자',
      'id': 'admin',
      'route': AppRoutes.adminSlide,
      'hasSubmenu': true,
      'submenu': [
        MenuItem('슬라이드 관리', AppRoutes.adminSlide),
        MenuItem('업체소개 관리', AppRoutes.adminCompany),
        MenuItem('배너 관리', AppRoutes.adminBanner),
        MenuItem('알림톡 관리', AppRoutes.adminNotification),
        MenuItem('사용자 관리', AppRoutes.adminUser),
        MenuItem('기본정보 관리', AppRoutes.adminBasicInfo),
      ],
    },
  ];
  
  @override
  void dispose() {
    _removeSubmenuOverlay();
    super.dispose();
  }
  
  void _showSubmenuOverlay(BuildContext context) {
    _removeSubmenuOverlay();
    
    // 현재 헤더의 위치 및 크기 가져오기
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final headerPos = renderBox.localToGlobal(Offset.zero);
    
    _submenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: headerPos.dy + headerHeight - 1,
        left: 0,
        width: MediaQuery.of(context).size.width,
        child: Material(
          elevation: 8,
          child: MouseRegion(
            onExit: (_) {
              // 서브메뉴에서 마우스가 나가면 서브메뉴를 닫음
              setState(() {
                hoveredMenu = null;
                showSubmenu = false;
              });
              _removeSubmenuOverlay();
            },
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...menuData
                    .where((m) => (m['hasSubmenu'] as bool))
                    .map<Widget>((m) {
                      final String id = m['id'] as String;
                      final List<MenuItem> items = m['submenu'] as List<MenuItem>;
                      return Expanded(
                        child: MouseRegion(
                          onEnter: (_) => setState(() {
                            hoveredMenu = id;
                            showSubmenu = true;
                          }),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...items.map((it) {
                                // 개별 서브메뉴 항목의 상태를 추적하기 위한 StatefulBuilder 사용
                                return StatefulBuilder(
                                  builder: (context, setItemState) {
                                    bool isItemHovered = false;
                                    
                                    return MouseRegion(
                                      onEnter: (_) => setItemState(() => isItemHovered = true),
                                      onExit: (_) {
                                        setItemState(() => isItemHovered = false);
                                        // 개별 아이템에서 마우스가 나가도 서브메뉴가 닫히지 않도록 함
                                        // 전체 서브메뉴 영역에서 나갈 때만 닫히도록 상위 MouseRegion에서 처리
                                      },
                                      child: InkWell(
                                        onTap: () => Navigator.pushNamed(context, it.route),
                                        hoverColor: Colors.transparent, // 커스텀 호버 효과 사용
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: isItemHovered ? const Color(0xFFF2F2F2) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            it.title,
                                            style: const TextStyle(
                                              fontSize: 20, 
                                              fontFamily: 'Wanted Sans', 
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context)!.insert(_submenuOverlay!);
  }
  
  void _removeSubmenuOverlay() {
    _submenuOverlay?.remove();
    _submenuOverlay = null;
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: headerHeight,
      child: Material(
        elevation: 2,
        color: Colors.white,
        child: MouseRegion(
          // 헤더에서 마우스가 벗어났을 때 처리
          onExit: (_) {
            // 마우스가 바로 서브메뉴로 이동할 수 있도록 약간의 지연 추가
            // 단, 서브메뉴가 표시 중일 때만 지연 처리
            if (showSubmenu) {
              // 서브메뉴가 표시 중인 경우 아무것도 하지 않음 (서브메뉴의 onExit에서 처리)
              return;
            } else {
              // 서브메뉴가 없는 경우 바로 처리
              setState(() {
                hoveredMenu = null;
              });
              _removeSubmenuOverlay();
            }
          },
          child: Container(
            height: headerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Row(
              children: [
                // 로고 버튼
                SizedBox(
                  width: 400,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                    child: const Text(
                      '작전현대아파트구역\n주택재개발정비사업조합',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Wanted Sans',
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // 나머지 메뉴들
                ...menuData.skip(1).map((menu) {
                  final id = menu['id'] as String;
                  final title = menu['title'] as String;
                  final hasSubmenu = menu['hasSubmenu'] as bool;
                  final isHover = hoveredMenu == id;

                  return MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        hoveredMenu = id;
                        showSubmenu = hasSubmenu;
                      });
                      if (hasSubmenu) {
                        _showSubmenuOverlay(context);
                      } else {
                        _removeSubmenuOverlay();
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, menu['route'] as String);
                      },
                      hoverColor: Colors.transparent,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 204,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'Wanted Sans',
                            fontWeight: FontWeight.w600,
                            color: isHover
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const Spacer(),

                // 로그인/로그아웃
                if (widget.isLoggedIn) 
                  TextButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('로그아웃', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontFamily: 'Wanted Sans', fontWeight: FontWeight.w600),),
                  )
                else                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('로그인', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontFamily: 'Wanted Sans', fontWeight: FontWeight.w600),),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 웹인지 앱인지 확인 (넓이 기준)
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 800;
    
    return isWeb ? _buildWebHomeScreen(context) : _buildAppHomeScreen(context);
  }
  
  // 웹 버전 홈 화면
  Widget _buildWebHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    
    // 임시 게시판 데이터
    final List<Map<String, dynamic>> boardItems = [
      {
        'category': '공지사항',
        'title': '2023년 조합 정기총회 개최 안내',
        'date': '2023-12-01',
      },
      {
        'category': '자유게시판',
        'title': '재개발 일정에 대한 질문',
        'date': '2023-11-28',
      },
      {
        'category': '공지사항',
        'title': '재개발 사업 진행 현황 보고',
        'date': '2023-11-25',
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          // 상단 헤더 - 최상단에 고정하여 배치
          WebHeader(isLoggedIn: isLoggedIn),
          
          // 메인 콘텐츠 - 스크롤 가능한 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 메인 배너 이미지
                  _buildMainBanner(),
                  
                  // 콘텐츠 섹션
                  _buildContentSection(context, boardItems),
                  
                  // 푸터
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 메인 배너 이미지
  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      height: 600,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 어두운 오버레이
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // 배너 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '작전현대아파트구역',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '주택재개발정비사업조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  '더 나은 미래를 위한 도약',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 콘텐츠 섹션
  Widget _buildContentSection(BuildContext context, List<Map<String, dynamic>> boardItems) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      color: Colors.white,
      child: Column(
        children: [
          // 소개 섹션
          const Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      // 배경 이미지
                      Positioned.fill(
                        child: Image(
                          image: NetworkImage('https://images.unsplash.com/photo-1464938050520-ef2270bb8ce8?q=80&w=2074&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // 어두운 오버레이
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      
                      // 텍스트
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '조합소개',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '작전현대아파트구역 주택재개발정비사업조합은\n더 나은 주거환경을 만들기 위해 노력하고 있습니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 24),
              
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      // 배경 이미지 (개발 소개)
                      Positioned.fill(
                        child: Image(
                          image: NetworkImage('https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                      // 어두운 오버레이
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      
                      // 텍스트
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '재개발 소개',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '재개발 사업의 진행 과정과 미래 계획에 대해\n확인하실 수 있습니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 80),
          
          // 소식 섹션
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 공지사항/소식
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '최근 소식',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.notice);
                          },
                          child: const Text('더보기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...boardItems.map((item) => _buildBoardItem(context, item)).toList(),
                  ],
                ),
              ),
              
              const SizedBox(width: 48),
              
              // 사무실 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사무실 안내',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=Incheon,Korea&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7CIncheon,Korea&key=YOUR_API_KEY'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '사무실 위치',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '인천광역시 계양구 작전동 123-45',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '연락처',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '전화: 032-123-4567\n이메일: info@jakhyun.org',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 게시판 아이템
  Widget _buildBoardItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['category'],
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              item['date'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 푸터
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      color: Colors.grey.shade900,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 로고 및 저작권
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '재개발조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '작전현대아파트구역 주택재개발정비사업조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2023 작전현대아파트구역 주택재개발정비사업조합. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // 주소 및 연락처
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '주소',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '인천광역시 계양구 작전동 123-45',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '연락처',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '전화: 032-123-4567\n이메일: info@jakhyun.org',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          // 개인정보 처리방침
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '약관 및 정책',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이용약관'),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('개인정보처리방침'),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이메일무단수집거부'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 앱 버전 홈 화면
  Widget _buildAppHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final isMember = authProvider.isMember;

    // 임시 배너 데이터
    final List<BannerModel> banners = [
      BannerModel(
        id: '1',
        imageUrl: 'https://via.placeholder.com/800x400/4A90E2/FFFFFF?text=재개발+진행상황+안내',
        title: '재개발 진행상황 안내',
        description: '현재 진행중인 재개발 상황을 확인하세요.',
        linkType: 'notice',
        linkId: '1',
      ),
      BannerModel(
        id: '2',
        imageUrl: 'https://via.placeholder.com/800x400/2ECC71/FFFFFF?text=조합+소식',
        title: '조합 소식',
        description: '중요한 조합 소식을 확인하세요.',
        linkType: 'notice',
        linkId: '2',
      ),
      BannerModel(
        id: '3',
        imageUrl: 'https://via.placeholder.com/800x400/E74C3C/FFFFFF?text=제휴업체+안내',
        title: '제휴업체 안내',
        description: '새로운 제휴업체를 확인하세요.',
        linkType: 'company',
        linkId: '1',
      ),
    ];

    // 임시 공지사항 데이터
    final List<NoticeModel> notices = [
      NoticeModel(
        id: '1',
        title: '2023년 조합 정기총회 개최 안내',
        content: '정기총회가 2023년 12월 15일에 개최됩니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isImportant: true,
      ),
      NoticeModel(
        id: '2',
        title: '재개발 사업 진행 현황 보고',
        content: '현재 진행 중인 재개발 사업의 현황을 보고드립니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isImportant: false,
      ),
      NoticeModel(
        id: '3',
        title: '조합원 의견 수렴 안내',
        content: '조합원 여러분의 의견을 수렴하고자 합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isImportant: false,
      ),
    ];

    return BaseScreen(
      title: '라텔 재개발/재건축',
      showBackButton: false,
      currentIndex: 0,
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침 로직 구현
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            // 슬라이드 배너
            BannerSlider(banners: banners),
            
            const SizedBox(height: 24),
            
            // 로그인/회원 정보 카드
            if (!isLoggedIn) ...[
              _buildLoginCard(context),
            ] else ...[
              _buildMemberInfoCard(context, authProvider),
            ],
            
            const SizedBox(height: 24),
            
            // 정보 카드 섹션
            _buildInfoSection(),
            
            const SizedBox(height: 24),
            
            // 공지사항 섹션
            _buildNoticeSection(context, notices, isMember),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoginCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '로그인하여 더 많은 정보를 확인하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '조합원 전용 정보 및 커뮤니티 이용을 위해 로그인이 필요합니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final name = user?.name ?? '사용자';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 24,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name님, 환영합니다',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.isAdmin
                          ? '관리자'
                          : authProvider.isMember
                              ? '조합원'
                              : '일반 사용자',
                      style: TextStyle(
                        fontSize: 14,
                        color: authProvider.isAdmin
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // 마이페이지로 이동
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('내 정보 관리'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '빠른 메뉴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: '조합 소개',
                icon: Icons.business_rounded,
                color: AppTheme.primaryColor,
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.associationIntro);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                title: '재개발 소개',
                icon: Icons.apartment_rounded,
                color: AppTheme.secondaryColor,
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.developmentProcess);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: '사무실 안내',
                icon: Icons.location_on_rounded,
                color: const Color(0xFF8E44AD),
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.officeInfo);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                title: '제휴업체',
                icon: Icons.handshake_rounded,
                color: const Color(0xFFE67E22),
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.companyBoard);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoticeSection(BuildContext context, List<NoticeModel> notices, bool isMember) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '공지사항',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notice);
                },
                child: const Row(
                  children: [
                    Text('더보기'),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isMember) ...[
          CustomCard(
            child: Column(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: AppTheme.textTertiaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '조합원 전용 컨텐츠입니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '조합원 회원 가입 후 이용해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('로그인하기'),
                ),
              ],
            ),
          ),
        ] else ...[
          ...notices.map((notice) => NoticeCard(notice: notice)).toList(),
        ],
      ],
    );
  }
} 