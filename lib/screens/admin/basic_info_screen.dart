import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';

class BasicInfoScreen extends StatelessWidget {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: '기본정보 관리',
      body: Center(
        child: Text('기본정보 관리 페이지'),
      ),
    );
  }
} 