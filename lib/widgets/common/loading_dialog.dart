import 'package:flutter/material.dart';

/// 로딩 다이얼로그를 표시하는 유틸리티 클래스
class LoadingDialog {
  /// 로딩 다이얼로그를 표시합니다.
  /// [context]는 현재 빌드 컨텍스트입니다.
  /// [barrierDismissible]은 사용자가 배경을 탭해서 다이얼로그를 닫을 수 있는지 여부를 결정합니다.
  static void show(BuildContext context, {bool barrierDismissible = false}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return const _LoadingDialogWidget();
      },
    );
  }

  /// 로딩 다이얼로그를 닫습니다.
  /// [context]는 현재 빌드 컨텍스트입니다.
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// 로딩 다이얼로그 위젯
class _LoadingDialogWidget extends StatelessWidget {
  const _LoadingDialogWidget();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
} 