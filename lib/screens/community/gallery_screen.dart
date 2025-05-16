import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: '갤러리',
      body: Center(
        child: Text('갤러리 페이지'),
      ),
    );
  }
} 