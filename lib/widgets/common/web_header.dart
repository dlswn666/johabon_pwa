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
  
  const WebHeader({Key? key, required this.isLoggedIn}) : super(key: key);
  
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
            onExit: (_) {
              setState(() {
                hoveredMenu = null;
                showSubmenu = false;
              });
              _removeSubmenuOverlay();
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
                            }).toList(),
                          ],
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
          onExit: (_) {
            if (showSubmenu) {
              return;
            } else {
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
                SizedBox(
                  width: 400,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.home);
                    },
                    style: TextButton.styleFrom(overlayColor: Colors.transparent),
                    child: Text(
                      menuData[0]['title'] as String,
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

                const Spacer(),

                ...menuData.skip(1).map((menu) {
                  final id = menu['id'] as String;
                  final title = menu['title'] as String;
                  final hasSubmenu = menu['hasSubmenu'] as bool;
                  final isHover = hoveredMenu == id;
                  
                  Key? itemKey;
                  if (_menuItemKeys.containsKey(id)) {
                    itemKey = _menuItemKeys[id];
                  }

                  return MouseRegion(
                    key: itemKey, 
                    onEnter: (_) {
                      bool overlayAlreadyCorrectlyShown = hoveredMenu == id && this.showSubmenu == true && _submenuOverlay != null && hasSubmenu;

                      setState(() {
                        hoveredMenu = id;
                        this.showSubmenu = hasSubmenu; 
                      });

                      if (hasSubmenu) {
                        if (!overlayAlreadyCorrectlyShown) {
                          _showSubmenuOverlay(context);
                        }
                      } else {
                        _removeSubmenuOverlay();
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, menu['route'] as String);
                      },
                      hoverColor: const Color(0xFFF2F2F2),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 304,
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
                  );
                }).toList(),

                const Spacer(),

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