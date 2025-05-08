import 'package:flutter/material.dart';

class AlarmManageScreen extends StatelessWidget {
  const AlarmManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림톡 관리'),
      ),
      body: const Center(
        child: Text('알림톡 관리 화면입니다.'),
      ),
    );
  }
} 