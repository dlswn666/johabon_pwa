import 'package:flutter/material.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('정보 공유방'),
      ),
      body: const Center(
        child: Text('정보 공유방 화면입니다.'),
      ),
    );
  }
} 