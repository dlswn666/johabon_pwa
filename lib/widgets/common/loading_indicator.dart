import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.color,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? AppTheme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// 현대적인 전체 화면 로딩 페이지
class FullScreenLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isDismissible;
  final Color barrierColor;

  const FullScreenLoadingIndicator({
    Key? key,
    this.message,
    this.isDismissible = false,
    this.barrierColor = Colors.black54,
  }) : super(key: key);

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FullScreenLoadingIndicator(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDismissible,
      child: Scaffold(
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
              
              // 추가 메시지 (있는 경우)
              if (message != null)
                Text(
                  message!,
                  style: const TextStyle(
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
      ),
    );
  }
} 