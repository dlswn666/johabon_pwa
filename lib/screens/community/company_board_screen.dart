import 'package:flutter/material.dart';

class CompanyBoardScreen extends StatelessWidget {
  const CompanyBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제휴업체 게시판'),
      ),
      body: const Center(
        child: Text('제휴업체 게시판 화면입니다.'),
      ),
    );
  }
} 