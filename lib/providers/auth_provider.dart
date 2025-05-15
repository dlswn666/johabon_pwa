import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  bool _isMember = false;
  User? _currentUser;
  bool _isLoading = false;
  String? _token;

  // 게터
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isMember => _isMember;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get token => _token;

  // 생성자에서 저장된 사용자 정보 확인
  AuthProvider() {
    _loadUserFromPrefs();
  }

  // 로그인 처리
  Future<bool> login(String id, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1초 딜레이 (UI에서 로딩 표시를 위해)
      await Future.delayed(const Duration(seconds: 1));
      
      // 테스트 계정 확인
      if (id == 'test123' && password == '123') {
        final user = User(
          id: '1',
          name: '테스트 사용자',
          email: 'test123@example.com',
          role: 'member',
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = user.role == 'admin';
        _isMember = user.role == 'member' || user.role == 'admin';
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // 임시 구현: 이메일이 "admin"으로 시작하면 관리자, "member"로 시작하면 조합원으로 판단
      if (id.startsWith('admin')) {
        final user = User(
          id: '2',
          name: '관리자',
          email: '$id@example.com',
          role: 'admin',
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = true;
        _isMember = true;
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (id.startsWith('member')) {
        final user = User(
          id: '3',
          name: '조합원',
          email: '$id@example.com',
          role: 'member',
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        _isAdmin = false;
        _isMember = true;
        _token = 'dummy_token_${user.id}';
        
        // 사용자 정보 저장
        await _saveUserToPrefs();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // 일치하는 계정이 없을 경우
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
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
      'email': _currentUser!.email,
      'role': _currentUser!.role,
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
    final user = User(
      id: extractedUserData['id'],
      name: extractedUserData['name'],
      email: extractedUserData['email'],
      role: extractedUserData['role'],
      createdAt: DateTime.parse(extractedUserData['createdAt']),
    );

    _currentUser = user;
    _isLoggedIn = true;
    _isAdmin = user.role == 'admin';
    _isMember = user.role == 'member' || user.role == 'admin';
    _token = prefs.getString('token');

    notifyListeners();
  }
} 