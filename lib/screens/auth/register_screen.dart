import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';
import 'package:johabon_pwa/widgets/common/custom_text_field.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  
  // 날짜 포맷터 추가
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
    super.dispose();
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
        _birthController.text = _dateFormat.format(picked);
      });
    }
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: 회원가입 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 요청이 완료되었습니다. 관리자 승인 후 이용 가능합니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '재개발/재건축 조합원 회원가입',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // ID
              CustomTextField(
                controller: _idController,
                label: 'ID',
                hint: 'ID를 입력해주세요',
                prefixIcon: Icons.account_circle_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 비밀번호
              CustomTextField(
                controller: _passwordController,
                label: '비밀번호',
                hint: '비밀번호를 입력해주세요',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
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
              const SizedBox(height: 16),
              
              // 비밀번호 확인
              CustomTextField(
                controller: _passwordConfirmController,
                label: '비밀번호 확인',
                hint: '비밀번호를 다시 입력해주세요',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 이름(소유자명)
              CustomTextField(
                controller: _nameController,
                label: '이름(소유자명)',
                hint: '이름을 입력해주세요',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 전화번호
              CustomTextField(
                controller: _phoneController,
                label: '핸드폰 번호',
                hint: '연락 가능한 핸드폰 번호를 입력해주세요',
                prefixIcon: Icons.smartphone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '핸드폰 번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 생년월일 (캘린더 적용)
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _birthController,
                    label: '생년월일',
                    hint: '생년월일을 선택해주세요',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일을 선택해주세요';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 권리소재지
              CustomTextField(
                controller: _addressController,
                label: '권리소재지',
                hint: '권리소재지 주소를 입력해주세요',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '권리소재지를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // 회원가입 버튼
              CustomButton(
                text: '회원가입 신청',
                onPressed: _register,
              ),
              const SizedBox(height: 20),
              
              // 안내문구
              const Text(
                '* 회원가입 신청 후 관리자 승인 절차가 필요합니다.\n* 승인 완료 시 등록하신 연락처로 알림이 발송됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 