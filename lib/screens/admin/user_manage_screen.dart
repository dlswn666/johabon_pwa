import 'package:flutter/material.dart';

class UserManageScreen extends StatelessWidget {
  const UserManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
      ),
      body: const Center(
        child: Text('사용자 관리 화면입니다.'),
      ),
    );
  }
} 