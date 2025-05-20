import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/widgets/common/address_search_dialog.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js;

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
  
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _selectedDate;

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
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('ko', 'KR'),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
            textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
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
        _birthController.text = _dateFormat.format(picked);
      });
    }
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      String fullAddress = _addressController.text;
      if (_detailAddressController.text.isNotEmpty) {
        fullAddress += ", ${_detailAddressController.text}";
      }
      
      // TODO: 실제 API 연동 로직
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입 요청이 완료되었습니다. 관리자 승인 후 이용 가능합니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
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
    FormFieldValidator<String>? validator,
    VoidCallback? onTap,
    Widget? suffix,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
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
                    validator: validator,
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
                  validator: validator,
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
                    hintText: '아이디를 입력하세요. (6자 이상)',
                    validator: (value) {
                      if (value == null || value.isEmpty) return '아이디를 입력해주세요';
                      if (value.length < 6) return '아이디는 6자 이상이어야 합니다.';
                      return null;
                    },
                    suffix: SizedBox(
                      width: 90,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: 아이디 중복 확인 로직
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('아이디 중복 확인 기능 구현 예정')),
                          );
                        },
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
                            color: Colors.grey.shade700,
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
                    hintText: '비밀번호를 입력하세요. (10자 이상)',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '비밀번호를 입력해주세요';
                      if (value.length < 10) return '비밀번호는 10자 이상이어야 합니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  _buildRegisterTextFieldRow(
                    label: '비밀번호 확인',
                    controller: _passwordConfirmController,
                    hintText: '비밀번호를 다시 입력해주세요.',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '비밀번호 확인을 입력해주세요';
                      if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '이름(소유자)',
                    controller: _nameController,
                    hintText: '이름을 입력해주세요.',
                    validator: (value) {
                      if (value == null || value.isEmpty) return '이름을 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '휴대폰번호',
                    controller: _phoneController,
                    hintText: '연락 가능한 핸드폰 번호를 입력해주세요.',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '핸드폰 번호를 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '생년월일',
                    controller: _birthController,
                    hintText: '1900.00.00',
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '생년월일을 선택해주세요';
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) return '관리소재지를 입력해주세요';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildRegisterTextFieldRow(
                    label: '상세주소',
                    controller: _detailAddressController,
                    hintText: '상세주소를 입력하세요.',
                    validator: (value) {
                      // 상세주소는 선택 사항일 수 있으므로, 필요에 따라 유효성 검사 수정
                      // if (value == null || value.isEmpty) {
                      //   return '상세주소를 입력해주세요';
                      // }
                      return null;
                    },
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
                          onPressed: () {
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
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75D49B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
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