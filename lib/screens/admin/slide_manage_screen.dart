import 'package:flutter/material.dart';

class SlideManageScreen extends StatelessWidget {
  const SlideManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('슬라이드 관리'),
      ),
      body: const Center(
        child: Text('슬라이드 관리 화면입니다.'),
      ),
    );
  }
} 