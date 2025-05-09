import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';
import 'package:johabon_pwa/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  
  // 배경 이미지 페이드 효과를 위한 변수
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentImageIndex = 0;
  final List<String> _backgroundImages = [
    'images/bg1.jpg',
    'images/bg2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    // 개발 모드에서는 테스트 계정 정보 자동 입력
    _idController.text = 'test123';
    _passwordController.text = '123';
    
    // 배경 이미지 페이드 효과 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 다음 이미지로 전환
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await Provider.of<AuthProvider>(context, listen: false)
          .login(_idController.text, _passwordController.text);

      if (success) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            AppRoutes.home, 
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 웹인지 앱인지 판단 (넓이 기준)
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지 (페이드인/아웃)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 현재 이미지
                  Positioned.fill(
                    child: Image.asset(
                      _backgroundImages[_currentImageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 다음 이미지 (페이드인)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _animation.value,
                      child: Image.asset(
                        _backgroundImages[(_currentImageIndex + 1) % _backgroundImages.length],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          isWeb 
              ? _buildWebUI(context) 
              : _buildAppUI(context),
        ],
      ),
    );
  }
  
  Widget _buildWebUI(BuildContext context) {
    return Stack(
      children: [
        // 상단 로고와 타이틀
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              Image.asset(
                'images/logo.jpg',
                width: 100,
                height: 100,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              const Text(
                '재개발/재건축 조합원 홈페이지',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 로그인 패널
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 400,
            margin: const EdgeInsets.only(right: 50),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppUI(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 버전의 로고 및 타이틀
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset(
                    'images/logo.jpg',
                    width: 120,
                    height: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '재개발/재건축 조합원 홈페이지',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 로그인 패널
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _buildLoginForm(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 로그인 타이틀
          const Text(
            '로그인',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A3F68),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // 에러 메시지
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          
          // ID 입력
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: _idController,
              focusNode: _idFocusNode,
              decoration: const InputDecoration(
                labelText: 'ID',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                hintText: '예: test123',
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '아이디를 입력해주세요';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 비밀번호 입력
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PW',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
                hintText: '예: 123',
              ),
              onFieldSubmitted: (_) => _login(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 로그인 버튼
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A3F68),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          
          const SizedBox(height: 15),
          
          // 회원가입 및 ID/PW 찾기 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF2A3F68)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2A3F68),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // ID/PW 찾기 기능
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF2A3F68)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'ID/PW 찾기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2A3F68),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // 테스트 계정 안내
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '테스트 계정 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ID: test123',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  'PW: 123',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 