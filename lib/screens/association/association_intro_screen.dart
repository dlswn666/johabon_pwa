import 'package:flutter/material.dart';

class AssociationIntroScreen extends StatelessWidget {
  const AssociationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('조합 소개'),
      ),
      body: const Center(
        child: Text('조합 소개 화면입니다.'),
      ),
    );
  }
} 