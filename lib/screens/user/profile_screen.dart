import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 정보 카드
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름 및 권리소재지
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            '홍',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '홍길동님',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '조합원 (승인완료)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // 권리소재지
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.home_outlined, 
                          color: AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '권리소재지',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '서울특별시 강남구 신사동 123-456',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 연락처
                    const Row(
                      children: [
                        Icon(Icons.phone_outlined, 
                          color: AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '연락처',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '010-1234-5678',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 내 활동 섹션
            const Text(
              '내 활동',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 내 활동 목록
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 내 문의
                  ListTile(
                    leading: const Icon(Icons.question_answer_outlined),
                    title: const Text('내 문의'),
                    subtitle: const Text('내가 작성한 질문과 답변을 확인합니다'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: 내 문의 화면으로 이동
                    },
                  ),
                  const Divider(height: 1),
                  
                  // 내 게시글
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: const Text('내 게시글'),
                    subtitle: const Text('내가 작성한 게시글을 확인합니다'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: 내 게시글 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 계정 관리 섹션
            const Text(
              '계정 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 계정 관리 목록
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 정보 수정
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('정보 수정'),
                    subtitle: const Text('연락처 등 내 정보를 수정합니다'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: 정보 수정 화면으로 이동
                    },
                  ),
                  const Divider(height: 1),
                  
                  // 비밀번호 변경
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('비밀번호 변경'),
                    subtitle: const Text('비밀번호를 변경합니다'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: 비밀번호 변경 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 로그아웃 버튼
            CustomButton(
              text: '로그아웃',
              onPressed: () {
                // TODO: 로그아웃 로직 구현
              },
              backgroundColor: Colors.grey.shade200,
              textColor: AppTheme.textPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
} 