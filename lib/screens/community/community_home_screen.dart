import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';

class CommunityHomeScreen extends StatelessWidget {
  const CommunityHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: '커뮤니티',
      body: Center(
        child: Text('커뮤니티 홈 페이지'),
      ),
    );
  }
} 