import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';
import 'package:johabon_pwa/widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
                '라텔 재개발/재건축 조합원 회원가입',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // 이름
              CustomTextField(
                controller: _nameController,
                label: '이름',
                hint: '실명을 입력해주세요',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 이메일
              CustomTextField(
                controller: _emailController,
                label: '이메일',
                hint: '이메일 주소를 입력해주세요',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 비밀번호
              CustomTextField(
                controller: _passwordController,
                label: '비밀번호',
                hint: '8자 이상의 비밀번호를 입력해주세요',
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
              
              // 전화번호
              CustomTextField(
                controller: _phoneController,
                label: '전화번호',
                hint: '연락 가능한 전화번호를 입력해주세요',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 권리소재지
              CustomTextField(
                controller: _addressController,
                label: '권리소재지',
                hint: '권리소재지 주소를 입력해주세요',
                prefixIcon: Icons.home_outlined,
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