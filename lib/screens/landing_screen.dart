import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 이미지 또는 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor,
                ],
              ),
            ),
          ),
          
          // 상단 물결 모양 장식
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.1,
            right: -size.width * 0.1,
            child: Container(
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width),
              ),
            ),
          ),
          
          // 하단 물결 모양 장식
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.3,
            right: -size.width * 0.3,
            child: Container(
              height: size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  
                  // 로고 또는 타이틀
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '라텔',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 타이틀 텍스트
                  Center(
                    child: Text(
                      '라텔 재개발/재건축',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.25),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 서브 타이틀 텍스트
                  Center(
                    child: Text(
                      '조합원을 위한 맞춤형 정보 서비스',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // 로그인 버튼
                  CustomButton(
                    text: '로그인',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    isFullWidth: true,
                    height: 55,
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                    icon: Icons.login_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 회원가입 버튼
                  CustomButton(
                    text: '회원가입',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    isFullWidth: true,
                    height: 55,
                    type: ButtonType.outline,
                    backgroundColor: Colors.white,
                    textColor: Colors.white,
                    icon: Icons.person_add_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 비회원 접속 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    child: Text(
                      '비회원으로 둘러보기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 