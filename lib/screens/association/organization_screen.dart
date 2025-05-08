import 'package:flutter/material.dart';

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('조직도'),
      ),
      body: const Center(
        child: Text('조직도 화면입니다.'),
      ),
    );
  }
} 