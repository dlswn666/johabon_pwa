import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../widgets/common/web_header.dart';

// API 응답을 가정한 샘플 데이터 (HomeScreen 클래스 바깥에 정의)
const List<Map<String, dynamic>> boardInfoSampleData = [
  {
    'visitUser': 2252,
    'totaljohabon': 1089,
    'totalArea': 1025.20,
    'step': '구역지정단계',
    'agreePercent': 58.5,
  }
];

// PostItem 모델 정의
class PostItem {
  final String id;
  final String title;
  final String content; // 요약 내용
  final String author;
  final String date;

  PostItem({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
  });
}

// InformationPanel 위젯 정의
class InformationPanel extends StatelessWidget {
  final Map<String, dynamic> boardDetails;

  const InformationPanel({Key? key, required this.boardDetails}) : super(key: key);

  // 일반 정보 행을 만드는 내부 헬퍼 위젯
  Widget _buildStaticRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 각 행 간격
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Wanted Sans')),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor, fontFamily: 'Wanted Sans')),
        ],
      ),
    );
  }

  // 프로그레스 바 정보 행을 만드는 내부 헬퍼 위젯
  Widget _buildProgressBarRow(BuildContext context, String label, double percentValue) {
    String progressText = '${percentValue.toStringAsFixed(1)}%'; // 소수점 한자리까지 표시
    double progressFraction = percentValue / 100.0; // 0.0 ~ 1.0 사이 값으로 변환

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimaryColor, fontFamily: 'Wanted Sans')),
          const SizedBox(width: 16), // 레이블과 프로그레스 바 사이 간격
          Expanded(
            child: Container(
              height: 12, // 프로그레스 바 높이
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LayoutBuilder( // 실제 그려질 너비를 기준으로 내부 바 너비 계산
                  builder: (ctx, constraints) {
                    return Container(
                      width: constraints.maxWidth * progressFraction,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xFF4DB588), // 이미지와 유사한 색상
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }
                ),
              ),
            ),
          ),
          const SizedBox(width: 16), // 프로그레스 바와 텍스트 퍼센트 사이 간격
          Text(progressText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 추출 및 형 변환
    String visitUserStr = boardDetails['visitUser']?.toString() ?? 'N/A';
    String totalJohabonStr = boardDetails['totaljohabon']?.toString() ?? 'N/A';
    String totalAreaStr = boardDetails['totalArea']?.toStringAsFixed(2) ?? 'N/A'; // 소수점 2자리
    String stepStr = boardDetails['step']?.toString() ?? 'N/A';
    double agreePercentVal = (boardDetails['agreePercent'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Column이 내용만큼만 높이를 차지하도록 설정
        children: [
          Text(
            'Information',
            style: TextStyle(
              color: const Color(0xFF4DB588),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Wanted Sans',
            ),
          ),
          const SizedBox(height: 20), // 제목과 첫 항목 사이 간격

          _buildStaticRow(context, '방문자 수', '$visitUserStr 명'),
          _buildStaticRow(context, '조합원 수', '$totalJohabonStr 명'),
          _buildStaticRow(context, '면적', '$totalAreaStr m²'),
          _buildStaticRow(context, '단계', stepStr),
          _buildProgressBarRow(context, '동의율', agreePercentVal),
          
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;

  final List<Map<String, dynamic>> boardItems = [
    {
      'category': '공지사항',
      'title': '2023년 조합 정기총회 개최 안내',
      'date': '2023-12-01',
    },
    {
      'category': '자유게시판',
      'title': '재개발 일정에 대한 질문',
      'date': '2023-11-28',
    },
    {
      'category': '공지사항',
      'title': '재개발 사업 진행 현황 보고',
      'date': '2023-11-25',
    },
  ];

  // 각 탭을 위한 샘플 게시글 데이터
  final List<PostItem> sampleNoticePosts = [
    PostItem(id: 'n1', title: '[중요] 조합 정기총회 개최 안내 (2025-05-10)', content: '이것은 매우 매우 매우 긴 테스트용 문자열입니다. 이 문자열은 반드시 네 줄을 넘어가서 화면 끝에 줄임표가 표시되어야 합니다. 과연 이 긴 내용이 어떻게 처리될지 지켜봅시다. 계속해서 내용을 추가하여 네 줄을 확실히 넘기도록 하겠습니다. 하나 둘 셋 넷 다섯 여섯 일곱 여덟 아홉 열.', author: '관리자', date: '2025-04-20'),
    PostItem(id: 'n2', title: '사업 진행 현황 업데이트 (4월 3주차)', content: '현재 철거 작업이 80% 완료되었으며, 이주 관련하여...', author: '관리자', date: '2025-04-18'),
    PostItem(id: 'n3', title: '조합 사무실 이전 안내', content: '5월 1일부터 새로운 사무실에서 업무를 시작합니다. 위치는...', author: '관리자', date: '2025-04-15'),
    PostItem(id: 'n4', title: '제휴 업체 선정 결과 공고', content: '투명한 심사를 통해 아래와 같이 제휴 업체가 선정되었음을 알려드립니다...', author: '관리자', date: '2025-04-10'),
  ];

  final List<PostItem> sampleQnaPosts = [
    PostItem(id: 'q1', title: '분담금 납부 일정 문의드립니다.', content: '안녕하세요, 일반 분양 관련하여 분담금 납부 일정이 어떻게 되는지 궁금합니다...', author: '조합원A', date: '2025-04-22'),
    PostItem(id: 'q2', title: '이주비 대출 관련 질문', content: '이주비 대출 신청 시 필요한 서류와 절차에 대해 자세히 알려주세요...', author: '조합원B', date: '2025-04-19'),
    PostItem(id: 'q3', title: '어린이집 설치 계획 있나요?', content: '새 아파트 단지 내에 어린이집이 설치될 예정인지, 규모는 어느 정도인지 궁금합니다...', author: '입주예정C', date: '2025-04-17'),
    PostItem(id: 'q4', title: '주차 공간 배정 방식 문의', content: '세대당 주차 공간은 어떻게 배정되나요? 추가 주차 공간 확보는 가능한가요?...', author: '조합원D', date: '2025-04-12'),
  ];

  final List<PostItem> sampleInfoSharePosts = [
    PostItem(id: 'i1', title: '인근 맛집 정보 공유합니다 (파스타집)', content: '최근에 오픈한 파스타집 가봤는데 정말 맛있어서 공유해요! 위치는 정문 앞...', author: '주민1', date: '2025-04-21'),
    PostItem(id: 'i2', title: '카풀 하실 분 찾습니다 (매일 아침 강남 방향)', content: '매일 아침 8시에 강남 방향으로 출근하는데 카풀 하실 분 계신가요? 유류비는...', author: '주민2', date: '2025-04-20'),
    PostItem(id: 'i3', title: '안 쓰는 유아용품 나눔합니다.', content: '아이가 커서 더 이상 사용하지 않는 유아용품들 나눔합니다. 상태는 깨끗하고...', author: '주민3', date: '2025-04-16'),
    PostItem(id: 'i4', title: '단지 내 헬스장 이용 후기', content: '새로 생긴 헬스장 기구도 다양하고 관리도 잘 되는 것 같아서 만족스럽네요! 다만...', author: '주민4', date: '2025-04-11'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width > 800;
    return isWeb ? _buildWebHomeScreen(context) : _buildAppHomeScreen(context);
  }
  
  Widget _buildWebHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    
    return Scaffold(
      body: Column(
        children: [
          WebHeader(isLoggedIn: isLoggedIn),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMainBanner(),
                  _buildCommunitySection(context),
                  _buildContentSection(context, boardItems),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunitySection(BuildContext context) {
    return Column( // 전체를 Column으로 감싸서 상단 탭 영역과 하단 바로가기 영역을 배치
      children: [
        Container( // 상단: 기존 탭 및 게시글 내용 영역
          color: Colors.white, 
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 80.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1, // InformationPanel이 차지할 비율을 1로 수정
                child: InformationPanel(boardDetails: boardInfoSampleData[0]),
              ),
              const SizedBox(width: 30),
              Expanded(
                flex: 4, // 오른쪽 탭/게시판 영역이 차지할 비율을 3으로 유지
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 48,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        indicatorColor: AppTheme.primaryColor,
                        indicatorWeight: 3.0,
                        labelStyle: const TextStyle(
                          fontFamily: 'Wanted Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontFamily: 'Wanted Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: '공지사항'),
                          Tab(text: 'Q&A'),
                          Tab(text: '정보공유방'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox( // TabBarView의 높이를 명시적으로 지정하거나 Flexible/Expanded 처리 필요
                      height: 300, // 임시 높이, 실제 내용에 따라 조절 필요
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSingleBoardView(context, '공지사항', sampleNoticePosts),
                          _buildSingleBoardView(context, 'Q&A', sampleQnaPosts),
                          _buildSingleBoardView(context, '정보공유방', sampleInfoSharePosts),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildBottomQuickLinksSection(context), // 하단: 바로가기 및 협력업체 영역
      ],
    );
  }
  
  Widget _buildMainBanner() {
    return Container(
      width: double.infinity,
      height: 600,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '작전현대아파트구역',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '주택재개발정비사업조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  '더 나은 미래를 위한 도약',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentSection(BuildContext context, List<Map<String, dynamic>> boardItems) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 48),
      color: Colors.white,
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image(
                          image: NetworkImage('https://images.unsplash.com/photo-1464938050520-ef2270bb8ce8?q=80&w=2074&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '조합소개',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '작전현대아파트구역 주택재개발정비사업조합은\n더 나은 주거환경을 만들기 위해 노력하고 있습니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image(
                          image: NetworkImage('https://images.unsplash.com/photo-1504307651254-35680f356dfd?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '재개발 소개',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '재개발 사업의 진행 과정과 미래 계획에 대해\n확인하실 수 있습니다.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '최근 소식',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Wanted Sans',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.notice);
                          },
                          child: const Text('더보기', style: TextStyle(fontFamily: 'Wanted Sans')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...boardItems.map((item) => _buildBoardItem(context, item)).toList(),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사무실 안내',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Wanted Sans',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=Incheon,Korea&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7CIncheon,Korea&key=YOUR_API_KEY'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '사무실 위치',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '인천광역시 계양구 작전동 123-45',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '연락처',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '전화: 032-123-4567\n이메일: info@jakhyun.org',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBoardItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['category'],
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Wanted Sans',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Wanted Sans',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              item['date'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Wanted Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      color: Colors.grey.shade900,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '재개발조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '작전현대아파트구역 주택재개발정비사업조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2023 작전현대아파트구역 주택재개발정비사업조합. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '주소',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '인천광역시 계양구 작전동 123-45',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '연락처',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '전화: 032-123-4567\n이메일: info@jakhyun.org',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '약관 및 정책',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이용약관', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('개인정보처리방침', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이메일무단수집거부', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHomeScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;
    final isMember = authProvider.isMember;

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
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView(
          children: [
            BannerSlider(banners: banners),
            const SizedBox(height: 24),
            if (!isLoggedIn) ...[
              _buildLoginCard(context),
            ] else ...[
              _buildMemberInfoCard(context, authProvider),
            ],
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
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
              fontFamily: 'Wanted Sans',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '조합원 전용 정보 및 커뮤니티 이용을 위해 로그인이 필요합니다.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
              fontFamily: 'Wanted Sans',
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
                  child: const Text('로그인', style: TextStyle(fontFamily: 'Wanted Sans')),
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
                  child: const Text('회원가입', style: TextStyle(fontFamily: 'Wanted Sans')),
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
                    fontFamily: 'Wanted Sans',
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
                        fontFamily: 'Wanted Sans',
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
                        fontFamily: 'Wanted Sans',
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
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.person_outline_rounded),
            label: const Text('내 정보 관리', style: TextStyle(fontFamily: 'Wanted Sans')),
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
              fontFamily: 'Wanted Sans',
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
                  fontFamily: 'Wanted Sans',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notice);
                },
                child: const Row(
                  children: [
                    Text('더보기', style: TextStyle(fontFamily: 'Wanted Sans')),
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
                    fontFamily: 'Wanted Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  '조합원 회원 가입 후 이용해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    fontFamily: 'Wanted Sans',
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
                  child: const Text('로그인하기', style: TextStyle(fontFamily: 'Wanted Sans')),
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

  Widget _buildLatestPostSummary(BuildContext context, PostItem post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.title,
          style: const TextStyle(
            fontFamily: 'Wanted Sans',
            fontSize: 20, // 이미지와 유사하게 조정
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          post.content,
          style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 16, color: AppTheme.textPrimaryColor, height: 1.5), // 내용 스타일 조정
          maxLines: 4, // 내용 미리보기 줄 수 이미지에 맞게 조정
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16), // 하단 간격 조정
        Row(
          children: [
            Text(post.author, style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 13, color: Colors.grey[600])),
            const Spacer(),
            Text(post.date, style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 13, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  // 오른쪽 게시글 목록 아이템을 위한 헬퍼 위젯
  Widget _buildCompactPostListItem(BuildContext context, PostItem post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // 아이템 간 수직 간격 조정
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey[700], // 글머리 기호 색상
              fontFamily: 'Wanted Sans',
            ),
          ),
          Expanded(
            child: Text(
              post.title,
              style: const TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 18, // 제목 폰트 크기
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            post.author,
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            post.date,
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 기존 _buildBoardTabView의 내용을 분리한 메서드
  Widget _buildSingleBoardView(BuildContext context, String boardTitle, List<PostItem> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Text('$boardTitle 게시글이 없습니다.', style: const TextStyle(fontFamily: 'Wanted Sans')),
      );
    }

    List<PostItem> listPosts = posts.length > 1 ? posts.sublist(1, posts.length > 4 ? 4 : posts.length) : [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: _buildLatestPostSummary(context, posts[0]),
            ),
          ),
          if (posts.isNotEmpty && listPosts.isNotEmpty)
            Container(
              width: 1,
              height: MediaQuery.of(context).size.height * 0.2, // 임시 높이
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
            ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: listPosts.map((post) => _buildCompactPostListItem(context, post)).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: TextButton(
                onPressed: () {
                  // TODO: 각 게시판 전체 목록 페이지로 이동 (boardTitle에 따라 분기)
                  String route = AppRoutes.notice; // 기본값
                  if (boardTitle == 'Q&A') route = AppRoutes.qna;
                  if (boardTitle == '정보공유방') route = AppRoutes.infoSharing;
                  Navigator.pushNamed(context, route);
                },
                child: const Text('+ 더보기', style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _buildShortcutsCard(BuildContext context) {
    // TODO: "바로가기" 섹션 UI 구현 (다음 단계에서 진행)
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(right: 8.0), // 오른쪽 카드와의 간격
        decoration: BoxDecoration(
          color: Colors.grey[200], // 임시 배경색
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('바로가기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Wanted Sans')),
            SizedBox(height: 16),
            // 여기에 아이콘 버튼들 추가
            Text('네이버 카페, 유튜브 등 아이콘 버튼 예정'),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersCard(BuildContext context) {
    // TODO: "협력업체" 섹션 UI 구현 (다음 단계에서 진행)
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(left: 8.0), // 왼쪽 카드와의 간격
        decoration: BoxDecoration(
          color: Colors.grey[200], // 임시 배경색
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('협력업체', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Wanted Sans')),
            SizedBox(height: 16),
            // 여기에 협력업체 목록 추가
            Text('협력업체 1, 2, 3 목록 예정'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomQuickLinksSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShortcutsCard(context),
          _buildPartnersCard(context),
        ],
      ),
    );
  }

  // _buildBoardTabView를 재구성하여 상단과 하단으로 나눔
  Widget _buildBoardTabView(BuildContext context, String boardTitle, List<PostItem> posts) {
    // 이 메서드는 TabBarView의 children으로 각 탭에 대해 호출됩니다.
    // 따라서 이 메서드 자체가 "공지사항", "Q&A", "정보공유방" 탭 뷰를 모두 포함하는 것이 아니라,
    // 각 탭의 내용을 구성합니다. 
    // 사용자의 요청은 _buildCommunitySection 전체를 위아래로 나누는 것으로 해석하여 수정합니다.
    // 즉, _buildCommunitySection 내에 TabBar + TabBarView가 있고, 그 아래에 _buildBottomQuickLinksSection이 와야합니다.
    
    // 혼란을 피하기 위해, 이 메서드는 원래대로 단일 _buildSingleBoardView를 호출하도록 되돌리고,
    // _buildCommunitySection을 수정하여 하단 링크 섹션을 추가하는 방향으로 진행합니다.

    // 이전에 _buildBoardTabView가 하던 역할을 _buildSingleBoardView가 하도록 변경했으므로,
    // _buildCommunitySection의 TabBarView children에서 _buildSingleBoardView를 직접 호출합니다.
    // 따라서 이 _buildBoardTabView 메서드는 사실상 사용되지 않거나, _buildSingleBoardView의 별칭이 됩니다.
    
    // 여기서는 _buildSingleBoardView를 그대로 반환합니다.
    return _buildSingleBoardView(context, boardTitle, posts);
  }
} 