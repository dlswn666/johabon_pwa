import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
    this.breakpoint = 800.0, // 기본 분기점 800px
  });

  // 현재 화면이 데스크탑(넓은 화면) 크기인지 확인하는 정적 메서드
  static bool isDesktop(BuildContext context, {double breakpoint = 800.0}) {
    return MediaQuery.of(context).size.width > breakpoint;
  }

  // 현재 화면이 모바일(좁은 화면) 크기인지 확인하는 정적 메서드
  static bool isMobile(BuildContext context, {double breakpoint = 800.0}) {
    return MediaQuery.of(context).size.width <= breakpoint;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > breakpoint) {
          return desktopBody;
        } else {
          return mobileBody;
        }
      },
    );
  }
} 