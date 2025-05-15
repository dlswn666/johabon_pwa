import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';
import 'package:johabon_pwa/widgets/common/custom_text_field.dart';
import 'package:johabon_pwa/widgets/common/address_search_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:js' as js;

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
  
  // 회원가입 모달 컨트롤러
  final _registerFormKey = GlobalKey<FormState>();
  final _registerIdController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerPasswordConfirmController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerBirthController = TextEditingController();
  final _registerAddressController = TextEditingController();
  final _registerDetailAddressController = TextEditingController();
  
  // 날짜 포맷터 추가
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _selectedDate;
  
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
    
    _idController.text = 'test123';
    _passwordController.text = '123';
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 배경 전환 시간
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // 부드러운 전환 효과
      ),
    );
    
    // 첫 번째 이미지 즉시 표시 후 애니메이션 시작
    // _animationController.forward(); // 초기에는 바로 forward 하지 않고, 첫 이미지 표시 후 전환

    // 배경 이미지 전환 타이머 (예: 10초마다 변경)
    // Timer.periodic(const Duration(seconds: 10), (timer) {
    //   if (mounted) {
    //     setState(() {
    //       _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
    //       _animationController.reset();
    //       _animationController.forward();
    //     });
    //   }
    // });
    // initState에서는 첫 번째 이미지를 즉시 로드하고, 이후 애니메이션을 통해 전환합니다.
    // Timer를 사용한 자동 전환 대신, _animationController의 addStatusListener를 활용합니다.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 애니메이션 완료 후 다음 이미지로 설정하고 다시 애니메이션 시작
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
        _animationController.reset(); // 애니메이션 컨트롤러 리셋
        _animationController.forward(); // 다시 애니메이션 시작
      }
    });
    // 앱 시작 시 첫 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    _registerIdController.dispose();
    _registerPasswordController.dispose();
    _registerPasswordConfirmController.dispose();
    _registerNameController.dispose();
    _registerPhoneController.dispose();
    _registerBirthController.dispose();
    _registerAddressController.dispose();
    _registerDetailAddressController.dispose();
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

  // 날짜 선택 다이얼로그 표시
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? DateTime(now.year - 20, now.month, now.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('ko', 'KR'), // 한국어 로케일 설정
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
            // 한국어 텍스트 설정
            textTheme: const TextTheme(
              // 헤더 타이틀 스타일
              titleLarge: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
              // 버튼 텍스트 스타일
              labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _registerBirthController.text = _dateFormat.format(picked);
      });
    }
  }

  // 회원가입 처리 함수
  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }
    
    // 권리소재지와 상세 주소 결합
    String fullAddress = _registerAddressController.text;
    if (_registerDetailAddressController.text.isNotEmpty) {
      fullAddress += ", " + _registerDetailAddressController.text;
    }
    
    // TODO: 실제 API에 전달할 때는 fullAddress 값을 사용
    
    // 임시로 Dialog 닫기만 처리
    if (mounted) {
      Navigator.of(context).pop();
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입 요청이 완료되었습니다. 관리자 승인 후 이용 가능합니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    // TODO: 실제 회원가입 API 연동 로직 추가
  }

  // 웹 회원가입 모달 표시
  void _showWebRegisterModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _registerFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 회원가입 타이틀
                    const Text(
                      '재개발/재건축 조합원 회원가입',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // ID
                    TextFormField(
                      controller: _registerIdController,
                      decoration: InputDecoration(
                        labelText: 'ID',
                        hintText: 'ID를 입력해주세요',
                        prefixIcon: const Icon(Icons.account_circle_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // 비밀번호
                    TextFormField(
                      controller: _registerPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력해주세요',
                        prefixIcon: const Icon(Icons.lock_outline),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 8) {
                          return '비밀번호는 8자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // 비밀번호 확인
                    TextFormField(
                      controller: _registerPasswordConfirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        hintText: '비밀번호를 다시 입력해주세요',
                        prefixIcon: const Icon(Icons.lock_outline),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요';
                        }
                        if (value != _registerPasswordController.text) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // 이름(소유자명)
                    TextFormField(
                      controller: _registerNameController,
                      decoration: InputDecoration(
                        labelText: '이름(소유자명)',
                        hintText: '이름을 입력해주세요',
                        prefixIcon: const Icon(Icons.person_outline),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // 전화번호
                    TextFormField(
                      controller: _registerPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '핸드폰 번호',
                        hintText: '연락 가능한 핸드폰 번호를 입력해주세요',
                        prefixIcon: const Icon(Icons.smartphone_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '핸드폰 번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    
                    // 생년월일 (캘린더 적용)
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _registerBirthController,
                            decoration: InputDecoration(
                              labelText: '생년월일',
                              hintText: '생년월일을 선택해주세요',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '생년월일을 선택해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // 권리소재지
                    GestureDetector(
                      onTap: () {
                        if (kIsWeb) {
                          // 웹 환경에서는 JavaScript 함수 직접 호출
                          js.context.callMethod('openKakaoPostcode');
                          
                          // 주소 선택 리스너 등록
                          js.context.callMethod('setupAddressSelectedListener', [
                            js.allowInterop((String address) {
                              setState(() {
                                _registerAddressController.text = address;
                              });
                              
                              // 리스너 해제
                              js.context.callMethod('tearDownAddressSelectedListener');
                            })
                          ]);
                        } else {
                          // 앱 환경에서는 모달 다이얼로그 사용
                          AddressSearchDialog.show(
                            context: context,
                            onAddressSelected: (address) {
                              setState(() {
                                _registerAddressController.text = address;
                              });
                            },
                            onDetailAddressSelected: (address, detail) {
                              setState(() {
                                _registerAddressController.text = address;
                                _registerDetailAddressController.text = detail;
                              });
                            },
                          );
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _registerAddressController,
                            decoration: InputDecoration(
                              labelText: '권리소재지',
                              hintText: '권리소재지 주소를 검색하려면 클릭하세요',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              suffixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '권리소재지를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // 상세 주소 입력 필드 추가
                    TextFormField(
                      controller: _registerDetailAddressController,
                      decoration: InputDecoration(
                        labelText: '상세 주소',
                        hintText: '상세 주소를 입력해주세요',
                        prefixIcon: const Icon(Icons.home_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '상세 주소를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    
                    // 안내 텍스트
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        '* 회원가입 신청 후 관리자 승인 절차가 필요합니다.\n* 승인 완료 시 등록하신 연락처로 알림이 발송됩니다.',
                        style: TextStyle(fontSize: 18, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 버튼 영역
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            '회원가입 신청',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // 현재 이미지 (애니메이션 시작 전 또는 전환 중 이전 이미지)
                  Image.asset(
                    _backgroundImages[_currentImageIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // 다음 이미지 (페이드인 효과 적용)
                  Opacity(
                    opacity: _animation.value,
                    child: Image.asset(
                      _backgroundImages[(_currentImageIndex + 1) % _backgroundImages.length],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ],
              );
            },
          ),
          // 배경 위 색상 처리 -> 사용자 요청에 따라 수정
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(color: Colors.transparent), // 왼쪽 50% 투명
              ),
              Expanded(
                flex: 1, // 오른쪽 50%
                child: Row(
                  children: [
                    Expanded(
                      flex: 1, // 오른쪽 영역의 왼쪽 (전체 화면의 25%)
                      child: Container(color: const Color(0x99233C22)), // #233C2299
                    ),
                    Expanded(
                      flex: 1, // 오른쪽 영역의 오른쪽 (전체 화면의 25%)
                      child: Container(color: const Color(0xE5233C22)), // #233C22E5
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          isWeb 
              ? _buildWebUI(context) 
              : _buildAppUI(context),
        ],
      ),
    );
  }
  
  Widget _buildWebUI(BuildContext context) {
    // 웹 UI 상단 로고/타이틀 제거 (Figma 디자인에 없음)
    return Align(
      alignment: Alignment.centerRight, // 로그인 폼을 오른쪽 정렬
      child: Container(
        width: 420, // 로그인 폼 너비 조정
        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08), // 오른쪽 여백
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50), // 내부 패딩
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // 모서리 둥글기
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // 그림자 색상 및 투명도
              blurRadius: 15, // 그림자 번짐 반경
              spreadRadius: 2, // 그림자 확산 반경
              offset: const Offset(0, 5), // 그림자 위치
            ),
          ],
        ),
        child: _buildLoginForm(isWeb: true),
      ),
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
              child: _buildLoginForm(isWeb: false),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoginForm({required bool isWeb}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Figma 디자인에 맞춰 아이콘과 조합 이름 추가 (웹/앱 공통)
          Center( // 아이콘과 텍스트를 중앙 정렬하기 위한 Center 위젯
            child: Column(
              children: [
                // 문서 아이콘 (Figma 디자인의 페이퍼 아이콘과 유사)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF66DE9C), // 상단 녹색
                        const Color(0xFF3BB643), // 하단 녹색
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4EDD5C).withOpacity(0.5),
                        blurRadius: 21,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '작전현대아파트구역\n주택재개발정비사업조합',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF41505D), // Figma의 텍스트 색상
                    height: 1.4, // 줄 간격
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40), // 간격 증가
          
          // 에러 메시지 (스타일 유지)
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
          
          // ID 입력 - Figma 스타일 적용
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
            ),
            child: TextFormField(
              controller: _idController,
              focusNode: _idFocusNode,
              decoration: const InputDecoration(
                hintText: '아이디를 입력하세요.',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '아이디를 입력해주세요';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),
          ),
          
          const SizedBox(height: 16), // Figma 간격
          
          // 비밀번호 입력 - Figma 스타일 적용
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
            ),
            child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '비밀번호를 입력하세요.',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                return null;
              },
              onFieldSubmitted: (_) => _login(),
            ),
          ),
          
          const SizedBox(height: 55), // Figma 간격
          
          // 로그인 버튼 - Figma 스타일 적용
          SizedBox(
            width: 256, // Figma 너비
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF75D49B), // Figma 색상
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Figma 둥글기
                ),
                elevation: 0, // 그림자 없음
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22675F), // Figma 텍스트 색상
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 28), // Figma 간격
          
          // 회원가입 및 ID/PW 찾기 버튼 - Figma 스타일 적용
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              TextButton(
                onPressed: () {
                  // ID/PW 찾기 기능
                   showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: const Text(
                            '아이디/비밀번호 찾기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          content: const Text(
                            '조합사무실에 연락주시면 아이디/비밀번호를 안내해 드립니다.',
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                '확인',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '아이디/비밀번호 찾기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF41505D), // Figma 색상
                  ),
                ),
              ),
              const SizedBox(width: 16), // 간격 조정
              TextButton(
                onPressed: () {
                  if (isWeb) {
                    _showWebRegisterModal(context);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.register);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '회원가입하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF41505D), // Figma 색상
                  ),
                ),
              ),
            ],
          ),
          
          // 테스트 계정 안내 (디자인 일관성을 위해 일단 유지, 필요시 제거 또는 스타일 변경)
          const SizedBox(height: 30),
          if (kDebugMode) // 디버그 모드에서만 보이도록
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              // ... (기존 테스트 계정 정보 내용) ...
              child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '테스트 계정 정보',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                     color: Color(0xFF424242),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ID: test123',
                  style: TextStyle(fontSize: 13, color: Color(0xFF424242)),
                ),
                Text(
                  'PW: 123',
                  style: TextStyle(fontSize: 13, color: Color(0xFF424242)),
                ),
              ],
            ),
            ),
        ],
      ),
    );
  }
} 