import 'dart:async';
import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // 스피너 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // 인증 상태 확인 후 적절한 페이지로 이동
    _checkAuthAndNavigate();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    // 3초 대기 (스플래시 화면 표시)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
    
    // AuthProvider 초기화 완료 대기
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }
    
    // 현재 슬러그 확인
    final slug = unionProvider.currentUnion?.homepage;
    
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      // 로그인된 상태라면 홈으로 이동
      if (slug != null) {
        Navigator.pushReplacementNamed(context, '/$slug');
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.notFound);
      }
    } else {
      // 로그인되지 않은 상태라면 로그인 페이지로 이동
      if (slug != null) {
        Navigator.pushReplacementNamed(context, '/$slug/${AppRoutes.login}');
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.notFound);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // index.html과 동일한 그라디언트 배경 적용
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a2842), 
              Color(0xFF2a3f68), 
              Color(0xFF3c5c8e),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 컨테이너
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.bar_chart, // 웹 버전과 유사한 아이콘 사용
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 메인 텍스트
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text(
                  '재개발/재건축\n조합원 전용 웹페이지',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.4,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // 커스텀 로딩 스피너 (웹 버전과 유사하게 구현)
              SizedBox(
                width: 50,
                height: 50,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SpinnerPainter(_controller.value),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 웹 버전의 스피너와 유사한 커스텀 스피너 구현
class SpinnerPainter extends CustomPainter {
  final double progress;
  
  SpinnerPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 회전하는 부분
    final foregroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // 회전 각도 계산
    final startAngle = -0.5 * 3.14; // -90도 (상단에서 시작)
    final sweepAngle = 2 * 3.14 * 0.3; // 원의 약 30%만 그리기
    
    // 진행 상황에 따라 시작 각도 회전
    final rotatedStartAngle = startAngle + (2 * 3.14 * progress);
    
    canvas.drawArc(rect, rotatedStartAngle, sweepAngle, false, foregroundPaint);
  }
  
  @override
  bool shouldRepaint(covariant SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 