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
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isMember = false;
  models.User? _currentUser;
  bool _isLoading = false;
  String? _token;

  // 게터
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isMember => _isMember;
  models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // 생성자에서 저장된 사용자 정보 확인
  AuthProvider() {
    _loadUserFromPrefs();
  }

  // 로그인 처리
  Future<Map<String, dynamic>> login(String id, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1초 딜레이 (UI에서 로딩 표시를 위해)
      await Future.delayed(const Duration(seconds: 1));
      
      // 테스트 계정 확인
      if (id == 'test123' && password == '123') {
        final user = models.User(
          id: '1',
          userId: 'test123',
          name: '테스트 사용자',
          userType: 'member',
          isApproved: true,
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = user.userType == 'admin';
        _isMember = user.userType == 'member' || user.userType == 'admin';
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        // 추가: 세션 정보를 로컬 스토리지에 직접 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', user.userType);
        
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'user_type': user.userType,
          'user_id': user.userId,
          'name': user.name
        };
      }
      
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
          _token = 'user_token_${user.id}'; // 실제 토큰 관리는 별도로 구현 필요
          
          // 사용자 정보 저장
          await _saveUserToPrefs();
          
          // 추가: 세션 정보를 로컬 스토리지에 직접 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_type', user.userType);
          
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

      // 여기까지 왔다면 임시 구현된 아이디 체크 (테스트용)
      if (id.startsWith('admin')) {
        final user = models.User(
          id: '2',
          userId: id,
          name: '관리자',
          userType: 'admin',
          isApproved: true,
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = true;
        _isMember = true;
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        // 추가: 세션 정보를 로컬 스토리지에 직접 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', user.userType);
        
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'user_type': user.userType,
          'user_id': user.userId,
          'name': user.name
        };
      } else if (id.startsWith('member')) {
        final user = models.User(
          id: '3',
          userId: id,
          name: '조합원',
          userType: 'member',
          isApproved: true,
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = false;
        _isMember = true;
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        // 추가: 세션 정보를 로컬 스토리지에 직접 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_type', user.userType);
        
        _isLoading = false;
        notifyListeners();
        return {
          'success': true,
          'user_type': user.userType,
          'user_id': user.userId,
          'name': user.name
        };
      }

      // 일치하는 계정이 없을 경우
      _isLoading = false;
      notifyListeners();
      return {'success': false};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    print('[AuthProvider] logout() called'); // 메소드 호출 확인
    _isLoading = true;
    notifyListeners(); // 로딩 시작 알림

    try {
      // 저장된 사용자 정보 삭제
      final prefs = await SharedPreferences.getInstance();
      print('[AuthProvider] Removing user_data from SharedPreferences...');
      await prefs.remove('user_data');
      print('[AuthProvider] Removing token from SharedPreferences...');
      await prefs.remove('token');
      
      // 추가: 세션 데이터 삭제
      await prefs.remove('user_type');
      await prefs.remove('slug');
      
      // 웹에서는 localStorage의 데이터도 삭제
      if (kIsWeb) {
        js.context.callMethod('eval', 
          ['localStorage.removeItem("user_type"); localStorage.removeItem("slug");']);
      }

      _isLoggedIn = false;
      _isAdmin = false;
      _isMember = false;
      _currentUser = null;
      _token = null;
      
      print('[AuthProvider] User state after logout: isLoggedIn=$_isLoggedIn, currentUser=$_currentUser');

    } catch (e) {
      if (kDebugMode) {
        print('[AuthProvider] Logout error: $e');
      }
    } finally { // try-catch-finally 구조로 변경하여 항상 로딩 해제 및 최종 알림 보장
      _isLoading = false;
      print('[AuthProvider] isLoading set to false, calling final notifyListeners()');
      notifyListeners(); // 최종 상태 (로그아웃 및 로딩 완료) 알림
    }
    
    // 이 메소드가 끝나면 모든 처리가 완료됨
    return;
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

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'id': _currentUser!.id,
      'name': _currentUser!.name,
      'userId': _currentUser!.userId,
      'userType': _currentUser!.userType,
      'unionId': _currentUser!.unionId,
      'isApproved': _currentUser!.isApproved,
      'createdAt': _currentUser!.createdAt.toIso8601String(),
    });

    await prefs.setString('user_data', userData);
    await prefs.setString('token', _token ?? '');
  }

  // SharedPreferences에서 사용자 정보 로드
  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_data')) return;

    final userData = prefs.getString('user_data');
    if (userData == null) return;

    final extractedUserData = json.decode(userData) as Map<String, dynamic>;
    final user = models.User(
      id: extractedUserData['id'],
      name: extractedUserData['name'],
      userId: extractedUserData['userId'] ?? extractedUserData['email'], // 하위 호환성
      userType: extractedUserData['userType'] ?? extractedUserData['role'], // 하위 호환성
      unionId: extractedUserData['unionId'],
      isApproved: extractedUserData['isApproved'] ?? true,
      createdAt: DateTime.parse(extractedUserData['createdAt'] ?? extractedUserData['created_at']),
    );

    _currentUser = user;
    _isLoggedIn = true;
    _isAdmin = user.userType == 'admin';
    _isMember = user.userType == 'member' || user.userType == 'admin';
    _token = prefs.getString('token');

    notifyListeners();
  }
} 