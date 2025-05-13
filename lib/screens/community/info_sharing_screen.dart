import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';

class InfoSharingScreen extends StatelessWidget {
  const InfoSharingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      title: '정보공유방',
      body: Center(
        child: Text('정보공유방 페이지'),
      ),
    );
  }
} 