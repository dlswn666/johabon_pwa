import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/app_drawer.dart';
import 'package:johabon_pwa/widgets/common/bottom_nav_bar.dart';
import 'package:johabon_pwa/widgets/common/mobile_header.dart';
import 'package:johabon_pwa/widgets/common/web_footer.dart';
import 'package:johabon_pwa/widgets/common/web_header.dart';
import 'package:provider/provider.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';

class ContentLayoutTemplate extends StatefulWidget {
  final Widget body;
  final Widget? leftSidebarContent;
  final Widget? rightSidebarContent;
  final String title;
  final bool applyPadding;
  final EdgeInsetsGeometry padding;
  final bool showHeader;
  final bool showFooter;
  final Color backgroundColor;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int currentIndex;
  final bool showBottomNav;
  final double sidebarWidth;
  final EdgeInsetsGeometry sidebarPadding;

  const ContentLayoutTemplate({
    super.key,
    required this.body,
    this.leftSidebarContent,
    this.rightSidebarContent,
    this.title = '',
    this.applyPadding = true,
    this.padding = const EdgeInsets.all(16),
    this.showHeader = true,
    this.showFooter = true,
    this.backgroundColor = AppTheme.backgroundColor,
    this.showDrawer = true,
    this.actions,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.showBottomNav = true,
    this.sidebarWidth = 200, // 기본 사이드바 너비
    this.sidebarPadding = const EdgeInsets.all(8), // 사이드바 패딩
  });

  @override
  State<ContentLayoutTemplate> createState() => _ContentLayoutTemplateState();
}

class _ContentLayoutTemplateState extends State<ContentLayoutTemplate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // ResponsiveLayout을 사용하여 웹/앱 구분
    return ResponsiveLayout(
      mobileBody: _buildMobileLayout(context),
      desktopBody: _buildWebLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: widget.backgroundColor,
      appBar: MobileHeader(
        scaffoldKey: _scaffoldKey,
        title: widget.title.isEmpty && authProvider.isLoggedIn && authProvider.currentUser?.name != null 
                ? '${authProvider.currentUser!.name}님, 안녕하세요' 
                : widget.title,
      ),
      endDrawer: widget.showDrawer ? const AppDrawer() : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 메인 콘텐츠
            widget.applyPadding
                ? Padding(
                    padding: widget.padding,
                    child: widget.body,
                  )
                : widget.body,
            // 모바일에서는 사이드바 콘텐츠를 아래로 배치
            if (widget.leftSidebarContent != null)
              Padding(
                padding: widget.sidebarPadding,
                child: widget.leftSidebarContent,
              ),
            if (widget.rightSidebarContent != null)
              Padding(
                padding: widget.sidebarPadding,
                child: widget.rightSidebarContent,
              ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavBar(currentIndex: widget.currentIndex)
          : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (widget.showHeader) WebHeader(isLoggedIn: authProvider.isLoggedIn),
          const SizedBox(height: 100),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 본문 영역 (좌측 사이드바 + 중앙 콘텐츠 + 우측 사이드바)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 좌측 사이드바 (광고 영역)
                      if (widget.leftSidebarContent != null)
                        Expanded(
                          flex: 2, // 전체 12 중 2
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: widget.sidebarPadding,
                              child: widget.leftSidebarContent,
                            ),
                          ),
                        ),
                      // 중앙 컨텐츠 영역
                      Expanded(
                        flex: 8, // 전체 12 중 8
                        child: widget.applyPadding
                            ? Padding(
                                padding: widget.padding,
                                child: widget.body,
                              )
                            : widget.body,
                      ),
                      // 우측 사이드바 (광고 영역)
                      if (widget.rightSidebarContent != null)
                        Expanded(
                          flex: 2, // 전체 12 중 2
                          child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: widget.sidebarPadding,
                              child: widget.rightSidebarContent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 푸터
                  if (widget.showFooter) const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
} 