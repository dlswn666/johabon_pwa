import 'package:flutter/material.dart';

class QnaScreen extends StatelessWidget {
  const QnaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('질문방'),
      ),
      body: const Center(
        child: Text('질문방 화면입니다.'),
      ),
    );
  }
} 