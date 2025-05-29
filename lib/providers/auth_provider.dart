import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/models/user_model.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:johabon_pwa/utils/password_util.dart';
// dart:js는 웹에서만 사용 가능하므로 조건부 임포트
// ignore: uri_does_not_exist
import 'dart:js' if (dart.library.io) 'package:johabon_pwa/utils/stub_js.dart' as js;

class AuthProvider with ChangeNotifier {
  // 세션 타임아웃 상수 (8시간, 밀리초 단위) - 더 긴 시간으로 설정
  static const int sessionTimeoutMs = 8 * 60 * 60 * 1000; 
  
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isMember = false;
  models.User? _currentUser;
  bool _isLoading = false;
  String? _token;
  bool _isInitialized = false;
  
  // 세션 타이머 관련 변수
  DateTime? _lastActivityTime;
  Timer? _sessionTimer;

  // 게터
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isMember => _isMember;
  models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isInitialized => _isInitialized;
  DateTime? get lastActivityTime => _lastActivityTime;

  // 생성자에서 저장된 사용자 정보 확인
  AuthProvider() {
    print('[AuthProvider] 초기화 시작');
    _initializeAuthState();
  }

  // 인증 상태 초기화
  Future<void> _initializeAuthState() async {
    try {
      print('[AuthProvider] 인증 상태 복원 시작');
      await _loadUserFromPrefs();
      
      // 로그인 상태면 세션 타이머 시작
      if (_isLoggedIn) {
        await _validateAndStartSessionTimer();
      }
      
      _isInitialized = true;
      print('[AuthProvider] 초기화 완료: 로그인 상태=$_isLoggedIn, 사용자=${_currentUser?.name}');
    } catch (e) {
      print('[AuthProvider] 초기화 중 오류 발생: $e');
      _isInitialized = true; // 오류가 있어도 초기화는 완료된 것으로 처리
    }
    notifyListeners();
  }
  
  // 세션 타이머 검증 및 시작
  Future<void> _validateAndStartSessionTimer() async {
    // 저장된 마지막 활동 시간을 확인
    final lastActivity = await _getLastActivityTime();
    
    if (lastActivity != null) {
      final now = DateTime.now();
      final difference = now.difference(lastActivity).inMilliseconds;
      
      // 세션 타임아웃이 지났으면 로그아웃
      if (difference > sessionTimeoutMs) {
        print('[AuthProvider] 세션 만료됨 (마지막 활동: $lastActivity)');
        await logout(isAutoLogout: true);
        return;
      }
      
      // 마지막 활동 시간이 유효하면 저장
      _lastActivityTime = lastActivity;
    } else {
      // 마지막 활동 시간이 없으면 현재 시간으로 설정
      _lastActivityTime = DateTime.now();
      await _updateLastActivityTime();
    }
    
    // 세션 타이머 시작
    _startSessionTimer();
  }
  
  // 마지막 활동 시간 가져오기
  Future<DateTime?> _getLastActivityTime() async {
    try {
      if (kIsWeb) {
        final timestamp = js.context.callMethod('eval', 
          ["localStorage.getItem('auth_last_activity')"]);
        
        if (timestamp != null && timestamp.toString().isNotEmpty && timestamp.toString() != 'null') {
          return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('auth_last_activity');
      
      if (timestamp != null && timestamp.isNotEmpty) {
        return DateTime.parse(timestamp);
      }
      
      return null;
    } catch (e) {
      print('[AuthProvider] 마지막 활동 시간 로드 오류: $e');
      return null;
    }
  }
  
  // 마지막 활동 시간 업데이트
  Future<void> _updateLastActivityTime() async {
    try {
      final now = DateTime.now();
      _lastActivityTime = now;
      
      if (kIsWeb) {
        js.context.callMethod('eval', [
          "localStorage.setItem('auth_last_activity', '${now.millisecondsSinceEpoch}')"
        ]);
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_last_activity', now.toIso8601String());
      
      print('[AuthProvider] 마지막 활동 시간 업데이트: $now');
    } catch (e) {
      print('[AuthProvider] 마지막 활동 시간 업데이트 오류: $e');
    }
  }
  
  // 세션 타이머 시작
  void _startSessionTimer() {
    // 기존 타이머가 있으면 취소
    _sessionTimer?.cancel();
    
    // 새 타이머 시작
    _sessionTimer = Timer(const Duration(milliseconds: sessionTimeoutMs), () async {
      print('[AuthProvider] 세션 타이머 만료, 자동 로그아웃');
      await logout(isAutoLogout: true);
    });
    
    print('[AuthProvider] 세션 타이머 시작: ${Duration(milliseconds: sessionTimeoutMs).inHours}시간');
  }
  
  // 세션 갱신 (사용자 활동 감지 시 호출)
  Future<void> refreshSession() async {
    if (!_isLoggedIn || _currentUser == null) return;
    
    try {
      // 최종 활동 시간 업데이트
      await _updateLastActivityTime();
      
      // 토큰 유효성 검사
      final isValid = await checkAuthValidity();
      if (!isValid) {
        print('[AuthProvider] 세션 갱신 중 토큰 유효성 검사 실패');
        await logout();
        return;
      }
      
      // 타이머 재설정
      _startSessionTimer();
      
      print('[AuthProvider] 세션 갱신 완료');
    } catch (e) {
      print('[AuthProvider] 세션 갱신 오류: $e');
    }
  }

  // 로그인 처리
  Future<Map<String, dynamic>> login(String id, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('[AuthProvider] 로그인 시도: $id');
      // 1초 딜레이 (UI에서 로딩 표시를 위해)
      await Future.delayed(const Duration(seconds: 1));
      
      // Supabase에서 사용자 정보 조회
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('user_id', id)
          // is_approved 조건을 제거하여 모든 사용자 조회
          .maybeSingle();
      
      // 사용자가 존재하는 경우
      if (response != null) {
        final userData = response as Map<String, dynamic>;
        final hashedPassword = userData['password'] as String;
        final isApproved = userData['is_approved'] as bool? ?? false;
        
        // 비밀번호 검증
        if (PasswordUtil.verifyPassword(password, hashedPassword)) {
          // 승인되지 않은 사용자인 경우
          if (!isApproved) {
            _isLoading = false;
            notifyListeners();
            return {
              'success': false,
              'error': 'not_approved',
              'message': '아직 승인이 완료되지 않았습니다. 관리자 승인 후 로그인이 가능합니다.'
            };
          }
          
          final user = models.User(
            id: userData['id'].toString(),
            unionId: userData['union_id']?.toString(),
            userId: userData['user_id'] as String,
            userType: userData['user_type'] as String,
            name: userData['name'] as String,
            phone: userData['phone'] as String?,
            birth: userData['birth'] != null ? DateTime.parse(userData['birth'] as String) : null,
            propertyLocation: userData['property_location'] as String?,
            isApproved: isApproved,
            createdAt: DateTime.parse(userData['created_at'] as String),
          );
          
          _currentUser = user;
          _isLoggedIn = true;
          _isAdmin = user.userType == 'admin';
          _isMember = user.userType == 'member' || user.userType == 'admin';
          
          // 토큰 생성 (실제 환경에서는 서버에서 생성된 토큰을 사용)
          _token = 'user_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
          
          // 사용자 정보 및 토큰 저장
          await _saveUserToPrefs();
          
          // 웹 환경에서 localStorage에 직접 저장
          if (kIsWeb) {
            _saveToLocalStorage(user);
          }
          
          // 마지막 활동 시간 업데이트 및 세션 타이머 시작
          await _updateLastActivityTime();
          _startSessionTimer();
          
          print('[AuthProvider] 로그인 성공: ${user.name} (${user.userType})');
          _isLoading = false;
          notifyListeners();
          return {
            'success': true,
            'user_type': user.userType,
            'user_id': user.userId,
            'name': user.name
          };
        }
      }

      // 일치하는 계정이 없을 경우
      print('[AuthProvider] 로그인 실패: 일치하는 계정 없음');
      _isLoading = false;
      notifyListeners();
      return {'success': false};
    } catch (e) {
      print('[AuthProvider] 로그인 오류: $e');
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // 웹 환경에서 localStorage에 직접 저장
  void _saveToLocalStorage(models.User user) {
    if (!kIsWeb) return;
    
    try {
      final userJson = jsonEncode({
        'id': user.id,
        'userId': user.userId,
        'userType': user.userType,
        'name': user.name,
        'unionId': user.unionId,
        'isLoggedIn': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // localStorage에 저장
      js.context.callMethod('eval', [
        '''
        localStorage.setItem('auth_user', '$userJson');
        localStorage.setItem('auth_token', '${_token}');
        localStorage.setItem('auth_timestamp', '${DateTime.now().millisecondsSinceEpoch}');
        console.log('User data saved to localStorage');
        '''
      ]);
      
      print('[AuthProvider] 사용자 정보 localStorage에 저장 완료');
    } catch (e) {
      print('[AuthProvider] localStorage 저장 오류: $e');
    }
  }

  // localStorage에서 불러오기
  Future<bool> _loadFromLocalStorage() async {
    if (!kIsWeb) return false;
    
    try {
      // localStorage에서 데이터 불러오기
      final userJson = js.context.callMethod('eval', ["localStorage.getItem('auth_user')"]);
      final token = js.context.callMethod('eval', ["localStorage.getItem('auth_token')"]);
      final timestamp = js.context.callMethod('eval', ["localStorage.getItem('auth_timestamp')"]);
      
      if (userJson == null || userJson.toString() == 'null' || 
          token == null || token.toString() == 'null') {
        print('[AuthProvider] localStorage에 인증 정보 없음');
        return false;
      }
      
      // 타임스탬프 기반 만료 체크
      if (timestamp != null && timestamp.toString() != 'null') {
        final loginTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
        final now = DateTime.now();
        final difference = now.difference(loginTime).inMilliseconds;
        
        // 세션 타임아웃 검사
        if (difference > sessionTimeoutMs) {
          print('[AuthProvider] localStorage 세션 만료: $loginTime');
          
          // 만료된 데이터 정리
          js.context.callMethod('eval', [
            '''
            localStorage.removeItem('auth_user');
            localStorage.removeItem('auth_token');
            localStorage.removeItem('auth_timestamp');
            localStorage.removeItem('auth_last_activity');
            console.log('Expired auth data removed from localStorage');
            '''
          ]);
          
          return false;
        }
      }
      
      final userData = json.decode(userJson.toString()) as Map<String, dynamic>;
      
      final user = models.User(
        id: userData['id'],
        unionId: userData['unionId'],
        userId: userData['userId'],
        userType: userData['userType'],
        name: userData['name'],
        isApproved: true,
        createdAt: DateTime.now(), // 정확한 시간이 없으면 현재 시간 사용
      );
      
      _currentUser = user;
      _isLoggedIn = true;
      _isAdmin = user.userType == 'admin';
      _isMember = user.userType == 'member' || user.userType == 'admin';
      _token = token.toString();
      
      print('[AuthProvider] localStorage에서 인증 정보 복원 성공: ${user.name}');
      return true;
    } catch (e) {
      print('[AuthProvider] localStorage 복원 오류: $e');
      // 오류 발생 시 localStorage 정리
      try {
        js.context.callMethod('eval', [
          '''
          localStorage.removeItem('auth_user');
          localStorage.removeItem('auth_token');
          localStorage.removeItem('auth_timestamp');
          localStorage.removeItem('auth_last_activity');
          console.log('Corrupted auth data removed from localStorage');
          '''
        ]);
      } catch (cleanupError) {
        print('[AuthProvider] localStorage 정리 오류: $cleanupError');
      }
      return false;
    }
  }

  // 로그아웃 처리
  Future<void> logout({bool isAutoLogout = false}) async {
    print('[AuthProvider] 로그아웃 시작' + (isAutoLogout ? ' (자동 로그아웃)' : ''));
    _isLoading = true;
    notifyListeners();

    try {
      // 세션 타이머 취소
      _sessionTimer?.cancel();
      _sessionTimer = null;
      
      // 저장된 사용자 정보 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('token');
      await prefs.remove('auth_last_activity');
      
      // 웹에서는 localStorage의 데이터도 삭제
      if (kIsWeb) {
        js.context.callMethod('eval', [
          '''
          localStorage.removeItem('auth_user');
          localStorage.removeItem('auth_token');
          localStorage.removeItem('auth_timestamp');
          localStorage.removeItem('auth_last_activity');
          localStorage.removeItem('user_type');
          localStorage.removeItem('slug');
          console.log('Auth data removed from localStorage');
          '''
        ]);
      }

      _isLoggedIn = false;
      _isAdmin = false;
      _isMember = false;
      _currentUser = null;
      _token = null;
      _lastActivityTime = null;
      
      print('[AuthProvider] 로그아웃 완료');
    } catch (e) {
      print('[AuthProvider] 로그아웃 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 회원가입 처리
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 실제 API 연동 구현
      await Future.delayed(const Duration(seconds: 1));

      // 회원가입 성공 처리
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // SharedPreferences에 사용자 정보 저장
  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'id': _currentUser!.id,
        'name': _currentUser!.name,
        'userId': _currentUser!.userId,
        'userType': _currentUser!.userType,
        'unionId': _currentUser!.unionId,
        'isApproved': _currentUser!.isApproved,
        'createdAt': _currentUser!.createdAt.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString('user_data', userData);
      await prefs.setString('token', _token ?? '');
      
      print('[AuthProvider] SharedPreferences에 사용자 정보 저장 완료');
    } catch (e) {
      print('[AuthProvider] SharedPreferences 저장 오류: $e');
    }
  }

  // SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserFromPrefs() async {
    try {
      print('[AuthProvider] 인증 정보 복원 시작');
      
      // 웹 환경에서는 localStorage 우선 확인
      if (kIsWeb) {
        final success = await _loadFromLocalStorage();
        if (success) {
          print('[AuthProvider] localStorage에서 복원 성공');
          return;
        }
      }
      
      // SharedPreferences에서 확인
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('user_data')) {
        print('[AuthProvider] SharedPreferences에 인증 정보 없음');
        return;
      }

      final userData = prefs.getString('user_data');
      if (userData == null || userData.isEmpty) {
        print('[AuthProvider] user_data가 null 또는 비어있음');
        return;
      }

      final extractedUserData = json.decode(userData) as Map<String, dynamic>;
      
      // 타임스탬프 기반 만료 체크
      if (extractedUserData.containsKey('timestamp')) {
        final loginTime = DateTime.parse(extractedUserData['timestamp']);
        final now = DateTime.now();
        final difference = now.difference(loginTime).inMilliseconds;
        
        // 세션 타임아웃 검사
        if (difference > sessionTimeoutMs) {
          print('[AuthProvider] SharedPreferences 세션 만료: $loginTime');
          
          // 만료된 데이터 삭제
          await prefs.remove('user_data');
          await prefs.remove('token');
          await prefs.remove('auth_last_activity');
          
          return;
        }
      }
      
      final user = models.User(
        id: extractedUserData['id'],
        name: extractedUserData['name'],
        userId: extractedUserData['userId'] ?? extractedUserData['email'],
        userType: extractedUserData['userType'] ?? extractedUserData['role'],
        unionId: extractedUserData['unionId'],
        isApproved: extractedUserData['isApproved'] ?? true,
        createdAt: DateTime.parse(extractedUserData['createdAt'] ?? extractedUserData['created_at'] ?? DateTime.now().toIso8601String()),
      );

      _currentUser = user;
      _isLoggedIn = true;
      _isAdmin = user.userType == 'admin';
      _isMember = user.userType == 'member' || user.userType == 'admin';
      _token = prefs.getString('token');
      
      // 웹 환경에서는 localStorage에도 저장하여 동기화
      if (kIsWeb) {
        _saveToLocalStorage(user);
      }

      print('[AuthProvider] SharedPreferences에서 복원 성공: ${user.name}');
    } catch (e) {
      print('[AuthProvider] 인증 정보 복원 오류: $e');
      // 오류 발생 시 저장된 데이터 정리
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_data');
        await prefs.remove('token');
        await prefs.remove('auth_last_activity');
        print('[AuthProvider] 손상된 인증 데이터 정리 완료');
      } catch (cleanupError) {
        print('[AuthProvider] 데이터 정리 중 오류: $cleanupError');
      }
    }
  }
  
  // 인증 토큰 유효성 검사 (새로고침 후에도 로그인 상태 유지를 위해)
  Future<bool> checkAuthValidity() async {
    if (!_isLoggedIn || _token == null) return false;
    
    try {
      // 토큰 기본 검증
      if (_token == null || _token!.isEmpty) {
        print('[AuthProvider] 토큰 유효성 검사 실패: 토큰 없음');
        return false;
      }
      
      // 마지막 활동 시간 검사
      if (_lastActivityTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastActivityTime!).inMilliseconds;
        
        if (difference > sessionTimeoutMs) {
          print('[AuthProvider] 토큰 유효성 검사 실패: 세션 만료');
          return false;
        }
      }
      
      // TODO: 서버에 토큰 유효성 검증 요청 추가
      // 실제 환경에서는 서버에 토큰을 검증하는 API 호출 필요
      
      print('[AuthProvider] 토큰 유효성 검사 성공');
      return true;
    } catch (e) {
      print('[AuthProvider] 토큰 유효성 검증 오류: $e');
      return false;
    }
  }
} 