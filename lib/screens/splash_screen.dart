import 'dart:async';
import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후 로그인 페이지로 이동
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A364E), // 세련된 딥 블루 배경색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 또는 아이콘
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.apartment_rounded, 
                size: 80,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 메인 텍스트
            const Text(
              '재개발/재건축 조합원 전용 페이지',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.4,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 50),
            
            // 로딩 스피너
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 추가 메시지
            const Text(
              '로딩 중입니다...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 하단 여백
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
} 