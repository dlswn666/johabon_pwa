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
import '../../widgets/common/web_footer.dart'; // WebFooter 임포트 추가
// import 'package:url_launcher/url_launcher.dart'; // 임시로 주석 처리
import 'dart:math'; // Random 클래스 사용을 위해 추가
import 'dart:async'; // Timer 사용을 위해 추가

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

// PartnerItem 모델 정의 (새로 추가)
class PartnerItem {
  final String id;
  final String introduction;
  final String name;

  PartnerItem({
    required this.id,
    required this.introduction,
    required this.name,
  });
}

// AdBannerItem 모델 정의 (새로 추가)
class AdBannerItem {
  final String id;
  final String? imageUrl; // 이미지가 없을 수 있으므로 nullable
  final String altText;
  final String? linkUrl; // 클릭 시 이동할 URL (선택 사항)

  AdBannerItem({
    required this.id,
    this.imageUrl,
    required this.altText,
    this.linkUrl,
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
  PageController? _adPageController; // 광고 슬라이더용 PageController 추가
  Timer? _adSlideTimer; // 광고 자동 슬라이드용 Timer 추가
  int _currentAdPage = 0; // 광고 슬라이더 초기 페이지 (무한 스크롤용)

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
    PostItem(id: 'n1', title: '[중요] 조합 정기총회 개최 안내 (2025-05-10)', content: '조합원 여러분의 많은 참여 바랍니다. 상세 내용은 첨부파일을 확인해주세요...', author: '관리자', date: '2025-04-20'),
    PostItem(id: 'n2', title: '사업 진행 현황 업데이트 (4월 3주차)', content: '현재 철거 작업이 80% 완료되었으며, 이주 관련하여...', author: '관리자', date: '2025-04-18'),
    PostItem(id: 'n3', title: '조합 사무실 이전 안내', content: '5월 1일부터 새로운 사무실에서 업무를 시작합니다. 위치는...', author: '관리자', date: '2025-04-15'),
    PostItem(id: 'n4', title: '제휴 업체 선정 결과 공고', content: '투명한 심사를 통해 아래와 같이 제휴 업체가 선정되었음을 알려드립니다...', author: '관리자', date: '2025-04-10'),
    PostItem(id: 'n5', title: '공지사항 테스트 5번 글', content: '이것은 다섯 번째 공지사항 테스트 게시물입니다. 내용이 충분히 길어 여러 줄을 차지할 수 있습니다.', author: '관리자', date: '2025-04-08'),
    PostItem(id: 'n6', title: '공지사항 테스트 6번 글', content: '여섯 번째 공지사항입니다. 목록 테스트를 위해 추가되었습니다.', author: '관리자', date: '2025-04-05'),
    PostItem(id: 'n7', title: '공지사항 테스트 7번 글 (더보기 확인용)', content: '일곱 번째 공지사항입니다. 이 글은 목록에 나오지 않아야 합니다.', author: '관리자', date: '2025-04-02'),
  ];

  final List<PostItem> sampleQnaPosts = [
    PostItem(id: 'q1', title: '분담금 납부 일정 문의드립니다.', content: '안녕하세요, 일반 분양 관련하여 분담금 납부 일정이 어떻게 되는지 궁금합니다...', author: '조합원A', date: '2025-04-22'),
    PostItem(id: 'q2', title: '이주비 대출 관련 질문', content: '이주비 대출 신청 시 필요한 서류와 절차에 대해 자세히 알려주세요...', author: '조합원B', date: '2025-04-19'),
    PostItem(id: 'q3', title: '어린이집 설치 계획 있나요?', content: '새 아파트 단지 내에 어린이집이 설치될 예정인지, 규모는 어느 정도인지 궁금합니다...', author: '입주예정C', date: '2025-04-17'),
    PostItem(id: 'q4', title: '주차 공간 배정 방식 문의', content: '세대당 주차 공간은 어떻게 배정되나요? 추가 주차 공간 확보는 가능한가요?...', author: '조합원D', date: '2025-04-12'),
    PostItem(id: 'q5', title: 'Q&A 테스트 5번 질문', content: '다섯 번째 Q&A 테스트 질문입니다.', author: '조합원E', date: '2025-04-09'),
    PostItem(id: 'q6', title: 'Q&A 테스트 6번 질문', content: '여섯 번째 Q&A 테스트 질문입니다.', author: '조합원F', date: '2025-04-06'),
    PostItem(id: 'q7', title: 'Q&A 테스트 7번 질문 (더보기 확인용)', content: '일곱 번째 질문입니다. 목록에는 나오지 않아야 합니다.', author: '조합원G', date: '2025-04-03'),
  ];

  final List<PostItem> sampleInfoSharePosts = [
    PostItem(id: 'i1', title: '인근 맛집 정보 공유합니다 (파스타집)', content: '최근에 오픈한 파스타집 가봤는데 정말 맛있어서 공유해요! 위치는 정문 앞...', author: '주민1', date: '2025-04-21'),
    PostItem(id: 'i2', title: '카풀 하실 분 찾습니다 (매일 아침 강남 방향)', content: '매일 아침 8시에 강남 방향으로 출근하는데 카풀 하실 분 계신가요? 유류비는...', author: '주민2', date: '2025-04-20'),
    PostItem(id: 'i3', title: '안 쓰는 유아용품 나눔합니다.', content: '아이가 커서 더 이상 사용하지 않는 유아용품들 나눔합니다. 상태는 깨끗하고...', author: '주민3', date: '2025-04-16'),
    PostItem(id: 'i4', title: '단지 내 헬스장 이용 후기', content: '새로 생긴 헬스장 기구도 다양하고 관리도 잘 되는 것 같아서 만족스럽네요! 다만...', author: '주민4', date: '2025-04-11'),
    PostItem(id: 'i5', title: '정보공유방 테스트 5번', content: '다섯 번째 정보공유방 테스트 글입니다.', author: '주민5', date: '2025-04-07'),
    PostItem(id: 'i6', title: '정보공유방 테스트 6번', content: '여섯 번째 정보공유방 테스트 글입니다.', author: '주민6', date: '2025-04-04'),
    PostItem(id: 'i7', title: '정보공유방 테스트 7번 (더보기 확인용)', content: '일곱 번째 정보입니다. 목록에는 안 나옵니다.', author: '주민7', date: '2025-04-01'),
  ];

  // 샘플 협력업체 데이터 (새로 추가)
  final List<PartnerItem> _allPartners = [
    PartnerItem(id: 'p1', introduction: '주식회사 감성건축은 혁신적인 디자인을 제공하며, 고객 맞춤형 솔루션을 통해 건축의 새로운 기준을 제시합니다.', name: '주식회사 감성건축'),
    PartnerItem(id: 'p2', introduction: '미래도시설계는 지속 가능한 도시 개발을 위한 창의적이고 실용적인 계획을 수립합니다.', name: '미래도시설계'),
    PartnerItem(id: 'p3', introduction: '안전제일 건설은 모든 프로젝트에서 안전을 최우선으로 생각하며, 고품질 시공을 약속드립니다.', name: '안전제일 건설'),
    PartnerItem(id: 'p4', introduction: '더조은 법률사무소는 전문적인 법률 서비스를 제공하여, 고객의 권익 보호를 최우선으로 합니다.', name: '더조은 법률사무소'),
    PartnerItem(id: 'p5', introduction: '우리 세무회계는 맞춤형 세무 및 회계 서비스를 제공하며, 고객의 재정적 성공을 지원합니다.', name: '우리 세무회계'),
  ];

  // 화면에 표시될 랜덤 협력업체 리스트 (새로 추가)
  List<PartnerItem> _displayedPartners = [];

  // 샘플 광고 배너 데이터 (새로 추가)
  final List<AdBannerItem> _adBanners = [
    AdBannerItem(id: 'ad1', altText: '광고 1: 현대건설 건축자재 Sale', imageUrl: 'https://via.placeholder.com/320x100/FF0000/FFFFFF?Text=Ad+1'),
    AdBannerItem(id: 'ad2', altText: '광고 2: 삼화 철강 자재', imageUrl: 'https://via.placeholder.com/320x100/00FF00/FFFFFF?Text=Ad+2'),
    AdBannerItem(id: 'ad3', altText: '광고 3: 건축자재 백화점', imageUrl: 'https://via.placeholder.com/320x100/0000FF/FFFFFF?Text=Ad+3'),
    AdBannerItem(id: 'ad4', altText: '광고 4: 타일 시공 청소 업체 홍보', imageUrl: 'https://via.placeholder.com/320x100/FFFF00/000000?Text=Ad+4'),
    AdBannerItem(id: 'ad5', altText: '광고 5: 또 다른 청소 업체', imageUrl: 'https://via.placeholder.com/320x100/FF00FF/FFFFFF?Text=Ad+5'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 랜덤 협력업체 3개 선택 (새로 추가)
    final random = Random();
    final shuffledPartners = List<PartnerItem>.from(_allPartners)..shuffle(random);
    _displayedPartners = shuffledPartners.take(3).toList();

    // 광고 슬라이더 초기화 (새로 추가)
    if (_adBanners.isNotEmpty) {
      _currentAdPage = _adBanners.length * 100; // 왼쪽으로 스크롤 할 여지
      _adPageController = PageController(initialPage: _currentAdPage, viewportFraction: 0.35); // viewportFraction 수정하여 3개 보이도록
      _startAdSlideTimer();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _adPageController?.dispose(); // PageController dispose 추가
    _adSlideTimer?.cancel(); // Timer cancel 추가
    super.dispose();
  }

  // 광고 자동 슬라이드 타이머 시작 함수 (새로 추가)
  void _startAdSlideTimer() {
    _adSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_adPageController != null && _adPageController!.hasClients) {
        _currentAdPage++;
        _adPageController!.animateToPage(
          _currentAdPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutQuad, // 부드러운 이동 효과
        );
      }
    });
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
                  _buildAdSliderSection(context), // 광고 슬라이더 섹션 추가
                  const WebFooter(), // _buildFooter() 대신 WebFooter() 사용
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommunitySection(BuildContext context) {
    return Container( // 전체 커뮤니티 섹션의 패딩과 배경 등을 관리
      color: Colors.white, 
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0), // 섹션 전체 좌우 패딩
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: Information Panel
          Expanded(
            flex: 1, 
            child: InformationPanel(boardDetails: boardInfoSampleData[0]), // 사용자의 boardDetails 수정 반영
          ),
          const SizedBox(width: 30), // InformationPanel과 오른쪽 컨텐츠 사이 간격 (사용자 수정 반영)

          // 오른쪽: 탭 및 게시글 내용 + 하단 바로가기/협력업체 영역
          Expanded(
            flex: 4, // 오른쪽 영역의 flex 값 (사용자 수정 반영)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 탭 영역
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
                const SizedBox(height: 16), // TabBar와 TabBarView 사이 간격
                SizedBox( // TabBarView 컨테이너
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
                // 여기에 _buildBottomQuickLinksSection를 추가
                _buildBottomQuickLinksSection(context), 
              ],
            ),
          ),
        ],
      ),
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
                  '미아동 791-2882일대  ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '신속통합 재개발 정비사업',
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
            Text(post.author, style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 16, color: AppTheme.textPrimaryColor)),
            const Spacer(),
            Text(post.date, style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 16, color: AppTheme.textPrimaryColor)),
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
              color: AppTheme.textPrimaryColor, // 글머리 기호 색상
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
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            post.date,
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 16,
              color: AppTheme.textPrimaryColor,
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

    // 오른쪽 목록에 표시할 게시글 (2번째부터 최대 6개, 즉 인덱스 1~6)
    List<PostItem> listPosts = posts.length > 1 ? posts.sublist(1, posts.length > 7 ? 7 : posts.length) : [];

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
              child: Padding( // Center의 자식을 Padding으로 감싸서 하단 여백을 줍니다.
                padding: const EdgeInsets.only(bottom: 32.0), // 예시 값, 원하는 만큼 조절하세요.
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
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _buildShortcutsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 180.0, // 고정된 높이 추가
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // 세로 가운데 정렬로 변경
        children: [
          Expanded(
            flex: 1,
            child: _buildShortcutItem(
              context, 
              'assets/icons/naver.png', 
              '네이버카페 \n바로가기',
              () => _launchURL('https://cafe.naver.com/yourcafe'),
              const Color(0xFF02C75C), // ARGB 값 수정
            ),
          ),
          const SizedBox(width: 12), // SizedBox의 방향을 width로 수정
          Expanded(
            flex: 1,
            child: _buildShortcutItem(
              context, 
              'assets/icons/youtube.png', 
              '유튜브 채널 \n바로가기',
              () => _launchURL('https://www.youtube.com/yourchannel'),
              const Color(0xFF41505D), // ARGB 값 수정
            ),
          ),
          const SizedBox(width: 12), // SizedBox의 방향을 width로 수정
          Expanded(
            flex: 1,
            child: _buildShortcutItem(
              context, 
              'assets/icons/kakao.png', 
              '카카오톡\n단톡방',
              () => _launchURL('https://open.kakao.com/o/yourchatlink'),
              const Color(0xFF381E1F), // ARGB 값 수정
            ),
          ),
        ],
      ),
    );
  }

  // 바로가기 항목을 만드는 헬퍼 위젯 추가
  Widget _buildShortcutItem(BuildContext context, String iconPath, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              iconPath,
              width: 58,
              height: 58,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 24); // 에러 시 기본 아이콘
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontFamily: 'Wanted Sans', fontSize: 16, color: color, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnersCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 180.0, // 고정된 높이 추가
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _displayedPartners.map((partner) {
          return _buildPartnerListItem(context, partner);
        }).toList(),
      ),
    );
  }

  // 협력업체 리스트 아이템을 만드는 헬퍼 위젯 (새로 추가)
  Widget _buildPartnerListItem(BuildContext context, PartnerItem partner) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // 아이템 간 수직 간격 조정
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 모든 자식을 상단 기준으로 정렬
        children: [
          Expanded(
            flex: 6, // 설명 부분이 더 많은 공간을 차지하도록 비율 조정
            child: Text(
              partner.introduction.length > 80 
                ? partner.introduction.substring(0, 80) + '...' 
                : partner.introduction, // 80자 제한
              style: TextStyle(
                fontFamily: 'Wanted Sans', 
                fontSize: 18, 
                color: AppTheme.textPrimaryColor, 
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis, // 내용이 넘칠 경우 말줄임표
            ),
          ),
          SizedBox(width: 20), // 각 섹션 사이 간격
          Expanded(
            flex: 2, // 비율 조정 가능
            child: Text(
              partner.name,
              style: TextStyle(
                fontFamily: 'Wanted Sans', 
                fontSize: 16, 
                color: AppTheme.textPrimaryColor, 
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left, // 업체명은 오른쪽 정렬
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomQuickLinksSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // stretch 대신 start로 변경
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    '바로가기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Wanted Sans'),
                  ),
                ),
                _buildShortcutsCard(context),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    '협력업체',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Wanted Sans'),
                  ),
                ),
                _buildPartnersCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // URL 실행을 위한 헬퍼 메서드
  Future<void> _launchURL(String urlString) async {
    // 기존 코드 대신 간단한 콘솔 로그로 대체
    print('클릭 이벤트 발생: $urlString');
    // 나중에 url_launcher 패키지가 추가되면 아래 코드의 주석을 해제하세요
    /*
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('연결할 수 없습니다: $urlString')),
      // );
    }
    */
    
    // 사용자에게 URL 클릭 정보를 알려주는 임시 대체 기능
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$urlString 링크를 클릭했습니다.\n(url_launcher 패키지 추가 후 실제 동작합니다)'),
        duration: Duration(seconds: 2),
      )
    );
  }

  // 광고 배너 아이템 위젯 (새로 추가)
  Widget _buildAdBannerItem(BuildContext context, AdBannerItem adItem) {
    return Container(
      width: 320,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8.0), // 아이템 간 간격
      decoration: BoxDecoration(
        color: Colors.grey[300], // 이미지 없을 시 배경색
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[400]!) // 테두리 추가
      ),
      child: ClipRRect( // 이미지가 borderRadius를 따르도록
        borderRadius: BorderRadius.circular(8.0),
        child: adItem.imageUrl != null && adItem.imageUrl!.isNotEmpty
            ? Image.network(
                adItem.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      adItem.altText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  );
                },
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  adItem.altText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
      ),
    );
  }

  // 광고 슬라이더 섹션 위젯 (새로 추가)
  Widget _buildAdSliderSection(BuildContext context) {
    if (_adBanners.isEmpty) {
      return const SizedBox.shrink(); // 광고 데이터 없으면 아무것도 표시 안 함
    }
    return Container(
      height: 130, // 슬라이더 전체 높이 (아이템 높이 + 상하 패딩 고려)
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      // color: Colors.blueGrey[50], // 섹션 배경색 (디버깅 또는 디자인용)
      child: PageView.builder(
        controller: _adPageController,
        // itemCount: _adBanners.length, // 무한 스크롤을 위해 주석 처리 또는 매우 큰 값
        itemBuilder: (context, pageIndex) {
          final itemIndex = pageIndex % _adBanners.length;
          return _buildAdBannerItem(context, _adBanners[itemIndex]);
        },
        onPageChanged: (page) {
          // 사용자가 직접 스크롤 시 _currentAdPage 업데이트 (선택적이지만 권장)
          // _currentAdPage = page; 
          // 무한 스크롤 시에는 이부분이 자동 스크롤과 충돌할 수 있어 타이머 재시작 로직이 필요할 수 있음
        },
      ),
    );
  }
} 