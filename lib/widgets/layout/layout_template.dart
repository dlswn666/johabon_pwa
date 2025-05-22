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

class LayoutTemplate extends StatefulWidget {
  final Widget body;
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

  const LayoutTemplate({
    super.key,
    required this.body,
    this.title = '', // 기본값 설정
    this.applyPadding = true,
    this.padding = const EdgeInsets.all(16),
    this.showHeader = true,
    this.showFooter = true,
    this.backgroundColor = AppTheme.backgroundColor, // AppTheme에서 기본 배경색 가져오기
    this.showDrawer = true,
    this.actions,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.showBottomNav = true,
  });

  @override
  State<LayoutTemplate> createState() => _LayoutTemplateState();
}

class _LayoutTemplateState extends State<LayoutTemplate> {
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
      body: widget.applyPadding
          ? Padding(
              padding: widget.padding,
              child: widget.body,
            )
          : widget.body,
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavBar(currentIndex: widget.currentIndex)
          : null,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 예시 위치
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (widget.showHeader) WebHeader(isLoggedIn: authProvider.isLoggedIn),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  widget.applyPadding
                      ? Padding(
                          padding: widget.padding,
                          child: widget.body,
                        )
                      : widget.body,
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