import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/widgets/common/app_bar_widget.dart';
import 'package:johabon_pwa/widgets/common/bottom_nav_bar.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final bool showBackButton;
  final bool showBottomNav;
  final bool showAppbar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.showBackButton = true,
    this.showBottomNav = true,
    this.showAppbar = true,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor = AppTheme.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppbar
          ? CustomAppBar(
              title: title,
              showBackButton: showBackButton,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: body,
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: currentIndex,
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }
} 