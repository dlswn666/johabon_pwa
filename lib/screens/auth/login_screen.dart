import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/address_search_dialog.dart';
import 'package:johabon_pwa/widgets/common/loading_dialog.dart';
import 'package:johabon_pwa/widgets/common/calendar_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:js' as js;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:johabon_pwa/utils/password_util.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
  bool _isRegisterLoading = false;
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
  
  // 아이디 중복 확인 상태
  bool _isIdChecked = false;
  bool _isIdAvailable = false;
  
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
    
    // 아이디 입력 필드의 값이 변경될 때마다 중복 확인 상태 리셋
    _registerIdController.addListener(() {
      if (_isIdChecked) {
        setState(() {
          _isIdChecked = false;
          _isIdAvailable = false;
        });
      }
    });
    
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

  // 유효성 검사 오류 모달 다이얼로그 표시 함수
  void _showValidationErrorModal(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 성공 모달 다이얼로그 표시 함수
  void _showSuccessModal(String title, String message, [Function? onConfirm]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) {
                  onConfirm();
                }
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
  }

  Future<void> _login() async {
    // 아이디 유효성 검사
    if (_idController.text.isEmpty) {
      _showValidationErrorModal('로그인 오류', '아이디를 입력해주세요.');
      return;
    }

    // 비밀번호 유효성 검사
    if (_passwordController.text.isEmpty) {
      _showValidationErrorModal('로그인 오류', '비밀번호를 입력해주세요.');
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
          // 슬러그 기반으로 홈 화면으로 이동
          final unionProvider = Provider.of<UnionProvider>(context, listen: false);
          final slug = unionProvider.currentUnion?.homepage;
          
          if (slug != null) {
            // 슬러그/home 형식으로 이동
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/$slug', // 슬러그 홈으로 이동 (AppRoutes.home은 자동으로 포함됨)
              (route) => false,
            );
          } else {
            // 슬러그가 없는 경우 404 페이지로 이동
            Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.notFound, 
              (route) => false,
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showValidationErrorModal('로그인 오류', '로그인에 실패했습니다. 아이디와 비밀번호를 확인해주세요.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showValidationErrorModal('오류', '오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  // 날짜 선택 다이얼로그 표시
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? DateTime(now.year - 20, now.month, now.day);
    
    // table_calendar를 사용한 달력 다이얼로그 표시
    final DateTime? pickedDate = await CalendarDialog.show(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _registerBirthController.text = _dateFormat.format(pickedDate);
      });
    }
  }

  // 아이디 중복 확인 메소드
  Future<void> _checkUsernameExists() async {
    final username = _registerIdController.text.trim();
    
    // 유효성 검사
    if (username.isEmpty) {
      _showValidationErrorModal('아이디 오류', '아이디를 입력해주세요.');
      return;
    }
    
    if (username.length < 6) {
      _showValidationErrorModal('아이디 오류', '아이디는 6자 이상이어야 합니다.');
      return;
    }
    
    try {
      // 로딩 표시
      LoadingDialog.show(context);
      
      // Supabase에서 아이디 중복 확인
      final result = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('user_id', username)
          .maybeSingle();
      
      // 로딩 다이얼로그 닫기
      LoadingDialog.hide(context);
      
      setState(() {
        _isIdChecked = true;
        _isIdAvailable = result == null; // 결과가 없으면 사용 가능한 아이디
      });
      
      // 결과에 따른 메시지 표시
      if (_isIdAvailable) {
        // 사용 가능한 아이디일 경우 모달 다이얼로그 표시
        _showSuccessModal(
          '아이디 사용 가능',
          '입력하신 아이디는 사용 가능합니다.\n이 아이디로 가입을 진행하시겠습니까?'
        );
      } else {
        _showValidationErrorModal('아이디 중복', '이미 사용 중인 아이디입니다.');
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) LoadingDialog.hide(context);
      
      // 오류 메시지
      _showValidationErrorModal('오류', '중복 확인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 회원가입 처리 함수
  Future<void> _register() async {
    // 각 필드별 유효성 검사
    if (_registerIdController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '아이디를 입력해주세요.');
      return;
    }
    
    if (_registerIdController.text.length < 6) {
      _showValidationErrorModal('회원가입 오류', '아이디는 6자 이상이어야 합니다.');
      return;
    }
    
    if (!_isIdChecked || !_isIdAvailable) {
      _showValidationErrorModal('회원가입 오류', '아이디 중복 확인을 먼저 진행해주세요.');
      return;
    }
    
    if (_registerPasswordController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '비밀번호를 입력해주세요.');
      return;
    }
    
    if (_registerPasswordController.text.length < 10) {
      _showValidationErrorModal('회원가입 오류', '비밀번호는 10자 이상이어야 합니다.');
      return;
    }
    
    if (_registerPasswordConfirmController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '비밀번호 확인을 입력해주세요.');
      return;
    }
    
    if (_registerPasswordController.text != _registerPasswordConfirmController.text) {
      _showValidationErrorModal('회원가입 오류', '비밀번호가 일치하지 않습니다.');
      return;
    }
    
    if (_registerNameController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '이름을 입력해주세요.');
      return;
    }
    
    if (_registerPhoneController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '핸드폰 번호를 입력해주세요.');
      return;
    }
    
    if (_registerBirthController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '생년월일을 선택해주세요.');
      return;
    }
    
    if (_registerAddressController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '관리소재지를 입력해주세요.');
      return;
    }
    
    // 로딩 상태 시작 - 스피너는 버튼에 직접 표시, 전체 화면 로딩은 별도로 표시
    setState(() {
      _isRegisterLoading = true;
    });
    
    // 전체 화면 로딩 다이얼로그 표시
    LoadingDialog.show(context);
    
    try {
      // 권리소재지와 상세 주소 결합
      String fullAddress = _registerAddressController.text;
      if (_registerDetailAddressController.text.isNotEmpty) {
        fullAddress += " ${_registerDetailAddressController.text}";
      }

      final homepage = Provider.of<UnionProvider>(context, listen: false).currentUnion?.homepage;

      if (homepage == null) {
        throw Exception('조합 homepage 주소를 찾을 수 없습니다.');
      }

      final response = await Supabase.instance.client.from('unions').select('id').eq('homepage', homepage).single();

      if (response == null) {
        throw Exception('조합 정보를 찾을 수 없습니다.');
      }

      final unionId = response['id'];

      // 비밀번호 암호화
      final hashedPassword = PasswordUtil.hashPassword(_registerPasswordController.text);
      
      // Supabase users 테이블에 데이터 저장
      final userResponse = await Supabase.instance.client.from('users').insert({
        'user_id': _registerIdController.text,
        'password': hashedPassword, // 암호화된 비밀번호 저장
        'name': _registerNameController.text,
        'phone': _registerPhoneController.text,
        'birth': _registerBirthController.text,
        'property_location': fullAddress,
        'user_type': 'member',
        'is_approved': false,
        'created_at': DateTime.now().toIso8601String(),
        'union_id': unionId,
      }).select();
      
      if (mounted) {
        // 로딩 상태 종료
        setState(() {
          _isRegisterLoading = false;
        });
        
        // 로딩 다이얼로그 닫기
        LoadingDialog.hide(context);
        
        Navigator.of(context).pop(); // 모달 닫기
        
        // 성공 메시지 모달 표시
        _showSuccessModal(
          '회원가입 완료',
          '회원 가입이 완료되었습니다.\n관리자 승인 후 로그인 가능합니다.'
        );
      }
    } catch (e) {
      if (mounted) {
        // 로딩 상태 종료
        setState(() {
          _isRegisterLoading = false;
        });
        
        // 로딩 다이얼로그 닫기
        LoadingDialog.hide(context);
        
        Navigator.of(context).pop(); // 모달 닫기
        
        // 실패 메시지 모달 표시
        _showValidationErrorModal(
          '회원가입 실패',
          '회원 가입에 실패했습니다.\n시스템 관리자에게 문의하세요.'
        );
      }
    }
  }

  // 웹 회원가입 모달 표시
  void _showWebRegisterModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // 모달 배경 흰색으로 명시
          elevation: 4, // 약간의 그림자 효과 (이미지에는 없지만, 구분 위해 추가. 원치 않으면 0)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 이미지와 유사하게 모서리 둥글기 조정
          ),
          child: Container(
            width: 580,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), // 패딩 미세 조정
            child: Form(
              key: _registerFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 자식들을 가로로 꽉 채움
                  children: [
                    // 회원가입 타이틀
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        '회원가입',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Wanted Sans',
                        ),
                      ),
                    ),
                    
                    // ID 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '아이디',
                      controller: _registerIdController,
                      hintText: '아이디를 입력하세요. (6자 이상)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요';
                        }
                        if (value.length < 6) {
                          return '아이디는 6자 이상이어야 합니다.';
                        }
                        return null;
                      },
                      suffix: SizedBox(
                        width: 90,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: _checkUsernameExists,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            '중복확인',
                            style: TextStyle(
                              fontSize: 13,
                              color: _isIdChecked && _isIdAvailable 
                                  ? Colors.green 
                                  : Colors.grey.shade700,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 비밀번호 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '비밀번호',
                      controller: _registerPasswordController,
                      hintText: '비밀번호를 입력하세요. (10자 이상)',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 10) {
                          return '비밀번호는 10자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 비밀번호 확인 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '비밀번호 확인', // '인'이 잘리므로 일단 이렇게 표시
                      controller: _registerPasswordConfirmController,
                      hintText: '비밀번호를 다시 입력해주세요.',
                      obscureText: true,
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
                    const SizedBox(height: 16),

                    // 이름(소유자명) 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '이름(소유자)', // '명'이 잘리므로 일단 이렇게 표시
                      controller: _registerNameController,
                      hintText: '이름을 입력해주세요.',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 휴대폰 번호 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '휴대폰번호',
                      controller: _registerPhoneController,
                      hintText: '연락 가능한 핸드폰 번호를 입력해주세요.',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                        LengthLimitingTextInputFormatter(11), // 최대 11자리 (예: 01012345678)
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 생년월일 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '생년월일',
                      controller: _registerBirthController,
                      hintText: '1900.00.00',
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      suffix: Icon(
                        Icons.calendar_today_rounded,
                        size: 18.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 관리소재지 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '관리소재지',
                      controller: _registerAddressController,
                      hintText: '클릭하여 주소를 검색하세요.',
                      readOnly: true,
                      onTap: () {
                        if (kIsWeb) {
                          js.context.callMethod('openKakaoPostcode');
                          js.context.callMethod('setupAddressSelectedListener', [
                            js.allowInterop((String address) {
                              setState(() {
                                _registerAddressController.text = address;
                              });
                              js.context.callMethod('tearDownAddressSelectedListener');
                            })
                          ]);
                        } else {
                          AddressSearchDialog.show(
                            context: context,
                            onAddressSelected: (address) {
                              setState(() {
                                _registerAddressController.text = address;
                              });
                            },
                            onDetailAddressSelected: (address, detail) {
                              // 상세주소는 별도 필드에서 받으므로 여기서는 기본 주소만 처리
                              setState(() {
                                _registerAddressController.text = address;
                                // _registerDetailAddressController.text = detail; // 이 부분은 상세주소 필드에서 처리
                              });
                            },
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '관리소재지를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 상세주소 입력 필드
                    _buildRegisterTextFieldRow(
                      label: '상세주소',
                      controller: _registerDetailAddressController,
                      hintText: '상세주소를 입력하세요.',
                      validator: (value) { // 상세주소는 선택 사항일 수 있으므로, 필요에 따라 유효성 검사 추가
                        // if (value == null || value.isEmpty) {
                        //   return '상세주소를 입력해주세요';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    
                    // 안내 텍스트 (기존 스타일 유지)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical:10, horizontal: 5),
                      child: Text(
                        '* 회원가입 신청 후 관리자 승인 절차가 필요합니다.\n* 승인 완료 시 등록하신 연락처로 알림이 발송됩니다.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.normal, fontFamily: 'Wanted Sans', height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 버튼 영역
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isRegisterLoading ? null : () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontFamily: 'Wanted Sans',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isRegisterLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF75D49B),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF75D49B).withOpacity(0.7),
                            ),
                            child: _isRegisterLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  '가입하기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Wanted Sans',
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // 하단 여백
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 회원가입 폼의 각 항목을 만드는 헬퍼 위젯 (validator 제거)
  Widget _buildRegisterTextFieldRow({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool readOnly = false,
    FormFieldValidator<String>? validator, // 사용하지 않지만 호환성을 위해 유지
    VoidCallback? onTap,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15, 
              color: const Color(0xFF4A5568), // 이미지 레이블 색상과 유사하게
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16), // 레이블과 필드 사이 간격 조정
        Expanded(
          flex: 5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // suffix 버튼과 정렬 위해
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  readOnly: readOnly,
                  onTap: onTap,
                  inputFormatters: inputFormatters,
                  style: TextStyle( // 입력 텍스트 스타일
                    fontFamily: 'Wanted Sans',
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500, 
                      fontFamily: 'Wanted Sans', 
                      fontSize: 14,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // 기본 밑줄 색상 및 두께
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10), // 내부 수직 패딩
                    isDense: true, // 높이를 컴팩트하게
                  ),
                  validator: null, // 인라인 validator 제거
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 10),
                suffix, // suffix 위젯 (예: 중복확인 버튼)
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // 배경 위 색상 처리 -> ResponsiveLayout.isDesktop 사용
          if(ResponsiveLayout.isDesktop(context))
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
          
          ResponsiveLayout(
            mobileBody: _buildAppUI(context),
            desktopBody: _buildWebUI(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWebUI(BuildContext context) {
    // 웹 UI 상단 로고/타이틀 제거 (Figma 디자인에 없음)
    return Align(
      alignment: Alignment.centerRight, // 로그인 폼을 오른쪽 정렬
      child: Container(
        width: 500, // 로그인 폼 너비 조정
        margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08), // 오른쪽 여백
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50), // 내부 패딩
        decoration: BoxDecoration(
          color: Colors.white,
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
            
            const SizedBox(height: 30),
            
            // 로그인 패널
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
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
                Text(
                  '미아동 791-2882일대',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 32 : 20,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Wanted Sans',
                    color: Color(0xFF41505D), // Figma의 텍스트 색상
                    height: 1.4, // 줄 간격
                  ),
                ),
                Text(
                  '신속통합 재개발 정비사업조합',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 32 : 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Wanted Sans',
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
                  fontFamily: 'Wanted Sans',
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: null, // 인라인 validator 제거
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
                  fontFamily: 'Wanted Sans',
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              validator: null, // 인라인 validator 제거
              onFieldSubmitted: (_) => _login(),
            ),
          ),
          
          const SizedBox(height: 55), // Figma 간격
          
          // 로그인 버튼 - Figma 스타일 적용
          SizedBox(
            width: 256, // Figma 너비
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF75D49B), // Figma 색상
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2), // Figma 둥글기
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
                        fontFamily: 'Wanted Sans',
                        color: Color(0xFF22675F), // Figma 텍스트 색상
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 28), // Figma 간격
          
          // 회원가입 및 ID/PW 찾기 버튼 - Figma 스타일 적용
          Column(
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
              const SizedBox(height:16), // 간격 조정
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