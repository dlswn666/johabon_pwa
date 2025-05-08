import 'package:flutter/material.dart';

class OfficeInfoScreen extends StatelessWidget {
  const OfficeInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사무실 안내'),
      ),
      body: const Center(
        child: Text('사무실 안내 화면입니다.'),
      ),
    );
  }
} 