import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 홈'),
      ),
      body: const Center(
        child: Text('관리자 홈 화면입니다.'),
      ),
    );
  }
} 