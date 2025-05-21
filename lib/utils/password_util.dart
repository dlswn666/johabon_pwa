import 'package:bcrypt/bcrypt.dart';

/// 비밀번호 해싱 및 검증을 위한 유틸리티 클래스
class PasswordUtil {
  /// 비밀번호를 BCrypt로 해싱하여 반환
  /// 
  /// [password] - 해싱할 원본 비밀번호
  /// [rounds] - 해싱 라운드 수 (기본값: 12)
  /// 
  /// 반환값: 해싱된 비밀번호 문자열
  static String hashPassword(String password, {int rounds = 12}) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: rounds));
  }

  /// 입력한 비밀번호가 해싱된 비밀번호와 일치하는지 확인
  /// 
  /// [password] - 검증할 원본 비밀번호
  /// [hashedPassword] - 저장된 해싱된 비밀번호
  /// 
  /// 반환값: 일치하면 true, 불일치하면 false
  static bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }
} 