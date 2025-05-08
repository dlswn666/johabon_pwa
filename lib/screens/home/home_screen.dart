import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/models/banner_model.dart';
import 'package:johabon_pwa/models/notice_model.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/widgets/common/base_screen.dart';
import 'package:johabon_pwa/widgets/common/custom_card.dart';
import 'package:johabon_pwa/widgets/home/banner_slider.dart';
import 'package:johabon_pwa/widgets/home/info_card.dart';
import 'package:johabon_pwa/widgets/home/notice_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final isMember = authProvider.isMember;

    // 임시 배너 데이터
    final List<BannerModel> banners = [
      BannerModel(
        id: '1',
        imageUrl: 'https://via.placeholder.com/800x400/4A90E2/FFFFFF?text=재개발+진행상황+안내',
        title: '재개발 진행상황 안내',
        description: '현재 진행중인 재개발 상황을 확인하세요.',
        linkType: 'notice',
        linkId: '1',
      ),
      BannerModel(
        id: '2',
        imageUrl: 'https://via.placeholder.com/800x400/2ECC71/FFFFFF?text=조합+소식',
        title: '조합 소식',
        description: '중요한 조합 소식을 확인하세요.',
        linkType: 'notice',
        linkId: '2',
      ),
      BannerModel(
        id: '3',
        imageUrl: 'https://via.placeholder.com/800x400/E74C3C/FFFFFF?text=제휴업체+안내',
        title: '제휴업체 안내',
        description: '새로운 제휴업체를 확인하세요.',
        linkType: 'company',
        linkId: '1',
      ),
    ];

    // 임시 공지사항 데이터
    final List<NoticeModel> notices = [
      NoticeModel(
        id: '1',
        title: '2023년 조합 정기총회 개최 안내',
        content: '정기총회가 2023년 12월 15일에 개최됩니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isImportant: true,
      ),
      NoticeModel(
        id: '2',
        title: '재개발 사업 진행 현황 보고',
        content: '현재 진행 중인 재개발 사업의 현황을 보고드립니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isImportant: false,
      ),
      NoticeModel(
        id: '3',
        title: '조합원 의견 수렴 안내',
        content: '조합원 여러분의 의견을 수렴하고자 합니다.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isImportant: false,
      ),
    ];

    return BaseScreen(
      title: '라텔 재개발/재건축',
      showBackButton: false,
      currentIndex: 0,
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침 로직 구현
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            // 슬라이드 배너
            BannerSlider(banners: banners),
            
            const SizedBox(height: 24),
            
            // 로그인/회원 정보 카드
            if (!isLoggedIn) ...[
              _buildLoginCard(context),
            ] else ...[
              _buildMemberInfoCard(context, authProvider),
            ],
            
            const SizedBox(height: 24),
            
            // 정보 카드 섹션
            _buildInfoSection(),
            
            const SizedBox(height: 24),
            
            // 공지사항 섹션
            _buildNoticeSection(context, notices, isMember),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '로그인하여 더 많은 정보를 확인하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '조합원 전용 정보 및 커뮤니티 이용을 위해 로그인이 필요합니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('회원가입'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfoCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final name = user?.name ?? '사용자';

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                radius: 24,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name님, 환영합니다',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.isAdmin
                          ? '관리자'
                          : authProvider.isMember
                              ? '조합원'
                              : '일반 사용자',
                      style: TextStyle(
                        fontSize: 14,
                        color: authProvider.isAdmin
                            ? AppTheme.errorColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // 마이페이지로 이동
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('내 정보 관리'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '빠른 메뉴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: '조합 소개',
                icon: Icons.business_rounded,
                color: AppTheme.primaryColor,
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.associationIntro);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                title: '재개발 소개',
                icon: Icons.apartment_rounded,
                color: AppTheme.secondaryColor,
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.developmentProcess);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: '사무실 안내',
                icon: Icons.location_on_rounded,
                color: const Color(0xFF8E44AD),
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.officeInfo);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                title: '제휴업체',
                icon: Icons.handshake_rounded,
                color: const Color(0xFFE67E22),
                onTap: (context) {
                  Navigator.pushNamed(context, AppRoutes.companyBoard);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoticeSection(BuildContext context, List<NoticeModel> notices, bool isMember) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '공지사항',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notice);
                },
                child: const Row(
                  children: [
                    Text('더보기'),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isMember) ...[
          CustomCard(
            child: Column(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: AppTheme.textTertiaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '조합원 전용 컨텐츠입니다',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '조합원 회원 가입 후 이용해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('로그인하기'),
                ),
              ],
            ),
          ),
        ] else ...[
          ...notices.map((notice) => NoticeCard(notice: notice)).toList(),
        ],
      ],
    );
  }
} 