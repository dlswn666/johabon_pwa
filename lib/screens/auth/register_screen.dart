import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/widgets/common/address_search_dialog.dart';
import 'package:johabon_pwa/widgets/common/calendar_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:johabon_pwa/utils/password_util.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  
  // 아이디 중복 확인 상태
  bool _isIdChecked = false;
  bool _isIdAvailable = false;
  bool _isLoading = false; // 로딩 상태 추가
  
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _selectedDate;
  
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

  @override
  void initState() {
    super.initState();
    // 아이디 입력 필드의 값이 변경될 때마다 중복 확인 상태 리셋
    _idController.addListener(() {
      if (_isIdChecked) {
        setState(() {
          _isIdChecked = false;
          _isIdAvailable = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }
  
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
        _birthController.text = _dateFormat.format(pickedDate);
      });
    }
  }

  // 아이디 중복 확인 메소드
  Future<void> _checkUsernameExists() async {
    final username = _idController.text.trim();
    
    // 유효성 검사
    if (username.isEmpty) {
      _showValidationErrorModal('아이디 오류', '아이디를 입력해주세요.');
      return;
    }
    
    if (username.length < 3) {
      _showValidationErrorModal('아이디 오류', '아이디는 3자 이상이어야 합니다.');
      return;
    }
    
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      );
      
      // Supabase에서 아이디 중복 확인
      final result = await Supabase.instance.client
          .from('users')
          .select('*')
          .eq('user_id', username)
          .maybeSingle();
      
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();
      
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
      if (context.mounted) Navigator.of(context).pop();
      
      // 오류 메시지
      _showValidationErrorModal('오류', '중복 확인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  Future<void> _register() async {
    // 각 필드별 유효성 검사
    if (_idController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '아이디를 입력해주세요.');
      return;
    }
    
    if (_idController.text.length < 3) {
      _showValidationErrorModal('회원가입 오류', '아이디는 3자 이상이어야 합니다.');
      return;
    }
    
    // 아이디 중복 확인 여부 체크
    if (!_isIdChecked || !_isIdAvailable) {
      _showValidationErrorModal('회원가입 오류', '아이디 중복 확인을 먼저 진행해주세요.');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '비밀번호를 입력해주세요.');
      return;
    }
    
    if (_passwordController.text.length < 8) {
      _showValidationErrorModal('회원가입 오류', '비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    
    if (_passwordConfirmController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '비밀번호 확인을 입력해주세요.');
      return;
    }
    
    if (_passwordController.text != _passwordConfirmController.text) {
      _showValidationErrorModal('회원가입 오류', '비밀번호가 일치하지 않습니다.');
      return;
    }
    
    if (_nameController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '이름을 입력해주세요.');
      return;
    }
    
    if (_phoneController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '핸드폰 번호를 입력해주세요.');
      return;
    }
    
    if (_birthController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '생년월일을 선택해주세요.');
      return;
    }
    
    if (_addressController.text.isEmpty) {
      _showValidationErrorModal('회원가입 오류', '관리소재지를 입력해주세요.');
      return;
    }
    
    // 로딩 상태 시작
    setState(() {
      _isLoading = true;
    });
    
    try {
      String fullAddress = _addressController.text;
      if (_detailAddressController.text.isNotEmpty) {
        fullAddress += " ${_detailAddressController.text}";
      }
      
      // 비밀번호 암호화
      final hashedPassword = PasswordUtil.hashPassword(_passwordController.text);
      
      // 조합 정보 가져오기
      final homepage = Provider.of<UnionProvider>(context, listen: false).currentUnion?.homepage;
      
      if (homepage == null) {
        throw Exception('조합 homepage 주소를 찾을 수 없습니다.');
      }
      
      final unionResponse = await Supabase.instance.client.from('unions').select('id').eq('homepage', homepage).single();
      
      if (unionResponse == null) {
        throw Exception('조합 정보를 찾을 수 없습니다.');
      }
      
      final unionId = unionResponse['id'];
      
      // Supabase users 테이블에 데이터 저장
      await Supabase.instance.client.from('users').insert({
        'user_id': _idController.text,
        'password': hashedPassword, // 암호화된 비밀번호 저장
        'name': _nameController.text,
        'phone': _phoneController.text,
        'birth': _birthController.text,
        'property_location': fullAddress,
        'user_type': 'member',
        'is_approved': false,
        'created_at': DateTime.now().toIso8601String(),
        'union_id': unionId,
      }).select().then((_) {
        if (mounted) {
          // 로딩 상태 종료
          setState(() {
            _isLoading = false;
          });
          
          // 성공 메시지 모달 표시
          _showSuccessModal(
            '회원가입 완료',
            '회원 가입이 완료되었습니다.\n관리자 승인 후 로그인 가능합니다.',
            () {
              // 슬러그 기반으로 로그인 페이지로 이동
              final unionProvider = Provider.of<UnionProvider>(context, listen: false);
              final slug = unionProvider.currentUnion?.homepage;
              
              if (slug != null) {
                // 슬러그/login 경로로 이동
                Navigator.pushReplacementNamed(context, '/$slug/${AppRoutes.login}');
              } else {
                // 슬러그가 없는 경우 이전 화면으로 돌아가기
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  // 이전 화면이 없으면 404 페이지로 이동
                  Navigator.pushReplacementNamed(context, AppRoutes.notFound);
                }
              }
            }
          );
        }
      }).catchError((error) {
        if (mounted) {
          // 로딩 상태 종료
          setState(() {
            _isLoading = false;
          });
          
          // 실패 메시지 모달 표시
          _showValidationErrorModal(
            '회원가입 실패',
            '회원 가입에 실패했습니다.\n시스템 관리자에게 문의하세요.'
          );
        }
      });
    } catch (error) {
      if (mounted) {
        // 로딩 상태 종료
        setState(() {
          _isLoading = false;
        });
        
        // 실패 메시지 모달 표시
        _showValidationErrorModal(
          '회원가입 실패',
          '회원 가입에 실패했습니다.\n시스템 관리자에게 문의하세요.'
        );
      }
    }
  }

  // login_screen.dart의 _buildRegisterTextFieldRow와 유사한 UI를 만드는 헬퍼 위젯
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
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // kIsWeb 대신 화면 너비로 분기
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600; // 예: 600px 미만을 좁은 화면으로 간주

    if (!isNarrowScreen) { // 넓은 화면 (웹 데스크탑 등)
      // 웹 환경일 때: 레이블과 입력 필드가 가로로 배치
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF4A5568),
                fontFamily: 'Wanted Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    readOnly: readOnly,
                    onTap: onTap,
                    textInputAction: textInputAction,
                    onFieldSubmitted: onFieldSubmitted,
                    inputFormatters: inputFormatters,
                    style: const TextStyle(
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
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                    validator: null, // 인라인 validator 제거
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 10),
                  suffix,
                ],
              ],
            ),
          ),
        ],
      );
    } else { // 좁은 화면 (모바일 웹, 모바일 앱 등)
      // 모바일 환경일 때: 레이블이 위, 입력 필드가 아래에 배치
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15, 
              color: const Color(0xFF4A5568), // 웹과 동일한 레이블 스타일 사용
              fontFamily: 'Wanted Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8), // 레이블과 입력 필드 사이 간격
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  readOnly: readOnly,
                  onTap: onTap,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
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
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                  validator: null, // 인라인 validator 제거
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 10),
                suffix,
              ],
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: kIsWeb ? 580 : MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  
                  _buildRegisterTextFieldRow(
                    label: '아이디',
                    controller: _idController,
                    hintText: '아이디를 입력하세요. (3자 이상)',
                    validator: null,
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
                  
                  _buildRegisterTextFieldRow(
                    label: '비밀번호',
                    controller: _passwordController,
                    hintText: '비밀번호를 입력하세요. (8자 이상)',
                    obscureText: true,
                    validator: null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildRegisterTextFieldRow(
                    label: '비밀번호 확인',
                    controller: _passwordConfirmController,
                    hintText: '비밀번호를 다시 입력해주세요.',
                    obscureText: true,
                    validator: null,
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '이름(소유자)',
                    controller: _nameController,
                    hintText: '이름을 입력해주세요.',
                    validator: null,
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '휴대폰번호',
                    controller: _phoneController,
                    hintText: '연락 가능한 핸드폰 번호를 입력해주세요.',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 숫자만 입력 가능
                      LengthLimitingTextInputFormatter(11), // 최대 11자리 (예: 01012345678)
                    ],
                    validator: null,
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '생년월일',
                    controller: _birthController,
                    hintText: '1900.00.00',
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffix: Icon(
                      Icons.calendar_today_rounded,
                      size: 18.0,
                      color: Colors.grey.shade600,
                    ),
                    validator: null,
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '관리소재지',
                    controller: _addressController,
                    hintText: '클릭하여 주소를 검색하세요.',
                    readOnly: true,
                    onTap: () {
                      if (kIsWeb) {
                        js.context.callMethod('openKakaoPostcode');
                        js.context.callMethod('setupAddressSelectedListener', [
                          js.allowInterop((String address) {
                            setState(() {
                              _addressController.text = address;
                            });
                            js.context.callMethod('tearDownAddressSelectedListener');
                          })
                        ]);
                      } else {
                        AddressSearchDialog.show(
                          context: context,
                          onAddressSelected: (address) {
                            setState(() {
                              _addressController.text = address;
                            });
                          },
                          onDetailAddressSelected: (address, detail) {
                            // 상세주소는 별도 필드에서 받으므로 여기서는 기본 주소만 처리
                            setState(() {
                              _addressController.text = address;
                              // _detailAddressController.text = detail;
                            });
                          },
                        );
                      }
                    },
                    validator: null,
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '상세주소',
                    controller: _detailAddressController,
                    hintText: '상세주소를 입력하세요.',
                    validator: null,
                  ),
                  const SizedBox(height: 30),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical:10, horizontal: 5),
                    child: Text(
                      '* 회원가입 신청 후 관리자 승인 절차가 필요합니다.\n* 승인 완료 시 등록하신 연락처로 알림이 발송됩니다.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.normal, fontFamily: 'Wanted Sans', height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            }
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
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75D49B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFF75D49B).withOpacity(0.7),
                          ),
                          child: _isLoading
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
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 