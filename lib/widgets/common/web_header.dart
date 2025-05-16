import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // AuthProvider 사용을 위해 추가
import '../../config/routes.dart';
import '../../config/theme.dart'; // AppTheme 사용을 위해 추가
import '../../providers/auth_provider.dart'; // Provider.of<AuthProvider> 사용을 위해 추가

// 메뉴 아이템 클래스
class MenuItem {
  final String title;
  final String route;
  
  MenuItem(this.title, this.route);
}

// 웹 헤더용 StatefulWidget
class WebHeader extends StatefulWidget {
  final bool isLoggedIn;
  
  const WebHeader({super.key, required this.isLoggedIn});
  
  @override
  WebHeaderState createState() => WebHeaderState();
}

class WebHeaderState extends State<WebHeader> {
  String? hoveredMenu;
  bool showSubmenu = false;
  OverlayEntry? _submenuOverlay;
  
  // 각 메뉴 항목의 GlobalKey를 저장하기 위한 Map
  final Map<String, GlobalKey> _menuItemKeys = {};

  // 헤더 바의 고정 높이
  static const double headerHeight = 120;
  
  // 호버 상태 관리를 위한 변수 추가
  bool _headerHovered = false;
  bool _submenuHovered = false;
  
  // 메뉴 정의
  final List<Map<String, dynamic>> menuData = [
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
  void initState() {
    super.initState();
    // 서브메뉴가 있는 메뉴 항목에 대해 GlobalKey 초기화
    for (var menu in menuData) {
      if (menu['hasSubmenu'] as bool) {
        _menuItemKeys[menu['id'] as String] = GlobalKey();
      }
    }
  }

  @override
  void dispose() {
    _removeSubmenuOverlay();
    super.dispose();
  }
  
  // 서브메뉴 가시성 업데이트 헬퍼 메서드
  void _updateSubmenuVisibility() {
    if (!_headerHovered && !_submenuHovered) {
      _removeSubmenuOverlay();
      if (mounted) { // 위젯이 여전히 마운트된 상태인지 확인
        setState(() {
          hoveredMenu = null;
          showSubmenu = false;
        });
      }
    }
  }
  
  void _showSubmenuOverlay(BuildContext context) {
    _removeSubmenuOverlay();
    
    GlobalKey? firstSubmenuKey = _menuItemKeys['association'];
    GlobalKey? lastSubmenuKey = _menuItemKeys['admin'];

    double submenuStartX = 0;
    double submenuEndX = 0; 

    if (firstSubmenuKey?.currentContext != null) {
      final RenderBox itemRenderBox = firstSubmenuKey!.currentContext!.findRenderObject() as RenderBox;
      final itemPos = itemRenderBox.localToGlobal(Offset.zero);
      submenuStartX = itemPos.dx;
    } else {
      submenuStartX = 620; // Fallback
    }

    if (lastSubmenuKey?.currentContext != null) {
      final RenderBox itemRenderBox = lastSubmenuKey!.currentContext!.findRenderObject() as RenderBox;
      final itemPos = itemRenderBox.localToGlobal(Offset.zero);
      submenuEndX = itemPos.dx + itemRenderBox.size.width; 
    } else {
      submenuEndX = MediaQuery.of(context).size.width - 684; 
    }
    
    final RenderBox headerRenderBox = context.findRenderObject() as RenderBox;
    final headerPos = headerRenderBox.localToGlobal(Offset.zero);

    _submenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: headerPos.dy + headerHeight -1, 
        left: submenuStartX, 
        right: MediaQuery.of(context).size.width - submenuEndX, 
        child: Material( 
          elevation: 8,
          type: MaterialType.transparency, 
          child: MouseRegion( 
            onEnter: (_) { // 서브메뉴 영역 진입
              if (mounted) {
                setState(() {
                  _submenuHovered = true;
                });
              }
            },
            onExit: (_) { // 서브메뉴 영역 이탈
              if (mounted) {
                setState(() {
                  _submenuHovered = false;
                });
                _updateSubmenuVisibility();
              }
            },
            child: Container(
              color: Colors.white, 
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...menuData
                    .where((m) => (m['hasSubmenu'] as bool))
                    .map<Widget>((m) {
                      final String id = m['id'] as String;
                      final List<MenuItem> items = m['submenu'] as List<MenuItem>;
                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            const SizedBox(height: 12),
                            ...items.map((it) {
                              return StatefulBuilder(
                                builder: (context, setItemState) {
                                  bool isItemHovered = false;
                                  return MouseRegion(
                                    onEnter: (_) => setItemState(() => isItemHovered = true),
                                    onExit: (_) => setItemState(() => isItemHovered = false),
                                    child: Material( 
                                      color: isItemHovered ? const Color(0xFFF2F2F2) : Colors.white, 
                                      borderRadius: BorderRadius.circular(4),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(4),
                                        hoverColor: const Color(0xFFE0E0E0), 
                                        splashColor: Colors.grey.withOpacity(0.1),
                                        highlightColor: Colors.grey.withOpacity(0.05),
                                        onTap: () => Navigator.pushNamed(context, it.route),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          child: Text(
                                            it.title,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20, 
                                              fontFamily: 'Wanted Sans', 
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_submenuOverlay!);
  }
  
  void _removeSubmenuOverlay() {
    _submenuOverlay?.remove();
    _submenuOverlay = null;
  }
  
  @override
  Widget build(BuildContext context) {
    // 직접 AuthProvider에서 로그인 상태를 구독 (listen: true)
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    
    return SizedBox(
      height: headerHeight,
      child: Material(
        elevation: 2,
        color: Colors.white,
        child: MouseRegion( // 헤더 전체 영역 MouseRegion
          onEnter: (_) { // 헤더 영역 진입
            if (mounted) {
              setState(() {
                _headerHovered = true;
              });
            }
          },
          onExit: (_) { // 헤더 영역 이탈
            if (mounted) {
              setState(() {
                _headerHovered = false;
              });
              _updateSubmenuVisibility();
            }
          },
          child: Container(
            height: headerHeight,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: 400,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.home);
                      },
                      style: TextButton.styleFrom(overlayColor: Colors.transparent),
                      child: Text(
                        '미아동 791-2882일대\n신속통합 재개발 정비사업',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Wanted Sans',
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                ...menuData.map((menu) {
                  final id = menu['id'] as String;
                  final title = menu['title'] as String;
                  final hasSubmenu = menu['hasSubmenu'] as bool;
                  final isHover = hoveredMenu == id;
                  
                  Key? itemKey;
                  if (_menuItemKeys.containsKey(id)) {
                    itemKey = _menuItemKeys[id];
                  }

                  return Expanded(
                    flex: 1,
                    child: MouseRegion( // 각 메뉴 아이템 MouseRegion
                      key: itemKey, 
                      onEnter: (_) { // 메뉴 아이템 진입
                        if (mounted) {
                          setState(() {
                            _headerHovered = true; // 헤더 내부에 있으므로 true
                            hoveredMenu = id;
                            showSubmenu = hasSubmenu; 
                          });
                        }

                        if (hasSubmenu) {
                          _showSubmenuOverlay(context);
                        } else {
                          _removeSubmenuOverlay(); // 서브메뉴 없는 항목 호버 시 기존 오버레이 제거
                        }
                      },
                      // onExit은 각 메뉴 아이템에서는 제거 (헤더 전체 onExit으로 관리)
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, menu['route'] as String);
                        },
                        hoverColor: const Color(0xFFF2F2F2),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Wanted Sans',
                              fontWeight: FontWeight.w600,
                              color:  AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {
                      print('Logout button pressed!');
                      Provider.of<AuthProvider>(context, listen: false).logout().then((_) {
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          AppRoutes.login, 
                          (route) => false
                        );
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('로그아웃', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontFamily: 'Wanted Sans', fontWeight: FontWeight.w600),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 