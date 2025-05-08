import 'package:flutter/material.dart';

class DevelopmentInfoScreen extends StatelessWidget {
  const DevelopmentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재개발 정보'),
      ),
      body: const Center(
        child: Text('재개발 정보 화면입니다.'),
      ),
    );
  }
} 