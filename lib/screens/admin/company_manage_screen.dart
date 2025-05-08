import 'package:flutter/material.dart';

class CompanyManageScreen extends StatelessWidget {
  const CompanyManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('업체 관리'),
      ),
      body: const Center(
        child: Text('업체 관리 화면입니다.'),
      ),
    );
  }
} 