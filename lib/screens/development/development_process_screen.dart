import 'package:flutter/material.dart';

class DevelopmentProcessScreen extends StatelessWidget {
  const DevelopmentProcessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('재개발 진행 과정'),
      ),
      body: const Center(
        child: Text('재개발 진행 과정 화면입니다.'),
      ),
    );
  }
} 