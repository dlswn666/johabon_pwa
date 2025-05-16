import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';

class BannerManageScreen extends StatelessWidget {
  const BannerManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: '배너 관리',
      body: Center(
        child: Text('배너 관리 페이지'),
      ),
    );
  }
} 