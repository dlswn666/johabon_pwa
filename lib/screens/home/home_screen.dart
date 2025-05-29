import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/models/banner_model.dart';
import 'package:johabon_pwa/models/notice_model.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/layout/layout_template.dart';
import 'package:johabon_pwa/widgets/common/custom_card.dart';
import 'package:johabon_pwa/widgets/home/banner_slider.dart';
import 'package:johabon_pwa/widgets/home/info_card.dart';
import 'package:johabon_pwa/widgets/home/notice_card.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:johabon_pwa/widgets/common/app_drawer.dart';
import 'package:johabon_pwa/widgets/common/mobile_header.dart';

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

  const InformationPanel({super.key, required this.boardDetails});

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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  PageController? _adPageController; // 광고 슬라이더용 PageController 추가
  Timer? _adSlideTimer; // 광고 자동 슬라이드용 Timer 추가
  int _currentAdPage = 0; // 광고 슬라이더 초기 페이지 (무한 스크롤용)

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // LayoutTemplate에서 관리하므로 제거

  // HTML 태그 제거 유틸리티 함수
  String _stripHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

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
    // 홈 화면의 본문 내용을 정의
    Widget homeBody = ResponsiveLayout(
      mobileBody: _buildAppHomeScreenContent(context),
      desktopBody: _buildWebHomeScreenContent(context),
    );

    return LayoutTemplate(
      body: homeBody,
      title: '미아동 791-2882일대 신속통합 재개발 정비사업', // 모바일 타이틀
      currentIndex: 0, // 홈 화면의 BottomNavBar 인덱스
      // 웹에서는 LayoutTemplate 내부에서 WebHeader/WebFooter를 자동으로 처리
      // 모바일에서는 LayoutTemplate 내부에서 MobileHeader/AppDrawer/BottomNavBar를 자동으로 처리
    );
  }
  
  // 웹 홈스크린 UI 빌드
  Widget _buildWebHomeScreenContent(BuildContext context) {
    // WebHeader와 WebFooter는 LayoutTemplate에서 처리하므로 여기서는 순수 콘텐츠만 구성
    return Column(
      children: [
        _buildMainBanner(),
        _buildCommunitySection(context),
        _buildCombinedLinksAndPartnersSection(context),
        _buildAdSliderSection(context),
      ],
    );
  }

  // 모바일 홈스크린 UI 빌드
  Widget _buildAppHomeScreenContent(BuildContext context) {
    // MobileHeader, AppDrawer, BottomNavBar는 LayoutTemplate에서 처리하므로 여기서는 순수 콘텐츠만 구성
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 로그인 상태 표시 섹션 (새로 추가)
          _buildLoginStatusSection(context),
          // 2. 메인 배너 영역
          Stack(
            children: [
              Image.network(
                'https://via.placeholder.com/800x400/4A90E2/FFFFFF?text=재개발+진행상황+안내',
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
              Container(
                width: double.infinity,
                height: 220,
                color: const Color.fromRGBO(35, 60, 34, 0.6),
              ),
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '조합원들의 방문을 환영합니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Wanted Sans',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '작전현대아파트구역\n주택재개발정비사업조합',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Wanted Sans',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF70DFAF),
                                width: 4.0,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '공지사항',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimaryColor,
                                fontFamily: 'Wanted Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: const Center(
                          child: Text(
                            'Q&A',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: const Center(
                          child: Text(
                            '정보공유방',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sampleNoticePosts[0].title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stripHtmlTags(sampleNoticePosts[0].content).length > 50
                                ? _stripHtmlTags(sampleNoticePosts[0].content).substring(0, 50) + '...'
                                : _stripHtmlTags(sampleNoticePosts[0].content),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sampleNoticePosts[0].author,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimaryColor,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                              Text(
                                sampleNoticePosts[0].date,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimaryColor,
                                  fontFamily: 'Wanted Sans',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1),
                      ...sampleNoticePosts.sublist(1, 4).map((post) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimaryColor,
                                  fontFamily: 'Wanted Sans',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              post.author,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimaryColor,
                                fontFamily: 'Wanted Sans',
                              ),
                            ),
                          ],
                        ),
                      )),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.notice);
                            },
                            child: const Text(
                              '+ 더보기',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Wanted Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '협력업체',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                      fontFamily: 'Wanted Sans',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: _displayedPartners.map((partner) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.introduction,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            partner.name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                          if (partner != _displayedPartners.last)
                            const Divider(height: 24, thickness: 1),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InformationPanel(boardDetails: boardInfoSampleData[0]),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    '바로가기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                      fontFamily: 'Wanted Sans',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickLinkItem('assets/icons/naver.png', '네이버카페\n바로가기', () => _launchURL('https://cafe.naver.com/yourcafe')),
                      _buildQuickLinkItem('assets/icons/youtube.png', '유튜브 채널\n바로가기', () => _launchURL('https://www.youtube.com/yourchannel')),
                      _buildQuickLinkItem('assets/icons/kakao.png', '카카오톡\n단톡방', () => _launchURL('https://open.kakao.com/o/yourchatlink')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _adPageController,
              itemBuilder: (context, pageIndex) {
                final itemIndex = pageIndex % _adBanners.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          _adBanners[itemIndex].imageUrl ?? 'https://via.placeholder.com/320x100',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        color: const Color(0xFFF9F9F9),
                        child: Center(
                          child: Text(
                            _adBanners[itemIndex].altText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                              fontFamily: 'Wanted Sans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onPageChanged: (page) {
                _currentAdPage = page;
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 웹 홈스크린 UI 빌드
  Widget _buildCommunitySection(BuildContext context) {
    return Container( 
      color: Colors.white, 
      padding: const EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0), // 좌우 패딩 추가
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // 정보 패널 flex 조정 (기존 1 -> 3)
            child: InformationPanel(boardDetails: boardInfoSampleData[0]),
          ),
          const SizedBox(width: 30), // 간격 30
          Expanded(
            flex: 7, // 탭/게시판 flex 조정 (기존 4 -> 7)
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
                const SizedBox(height: 16), // TabBar와 TabBarView 사이 간격
                SizedBox( // TabBarView 컨테이너
                  height: 300, // 높이 증가 (기존 250 -> 300)
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
    // WebFooter는 LayoutTemplate에서 처리하므로 제거 가능
    return Container();
  }

  // 빠른 링크 아이템 위젯 생성 메서드 추가
  Widget _buildQuickLinkItem(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image, size: 40);
                },
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimaryColor,
              fontFamily: 'Wanted Sans',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // URL 실행을 위한 헬퍼 메서드
  Future<void> _launchURL(String urlString) async {
    print('클릭 이벤트 발생: $urlString');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$urlString 링크를 클릭했습니다.\n(url_launcher 패키지 추가 후 실제 동작합니다)'),
        duration: Duration(seconds: 2),
      )
    );
  }

  // 광고 슬라이더 섹션 위젯 (새로 추가)
  Widget _buildAdSliderSection(BuildContext context) {
    if (_adBanners.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 230,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: PageView.builder(
        controller: _adPageController,
        itemBuilder: (context, pageIndex) {
          final itemIndex = pageIndex % _adBanners.length;
          return _buildAdBannerItem(context, _adBanners[itemIndex]);
        },
        onPageChanged: (page) {
        },
      ),
    );
  }

  // 게시판 탭 콘텐츠를 구성하는 메서드
  Widget _buildSingleBoardView(BuildContext context, String boardTitle, List<PostItem> posts) {
    if (posts.isEmpty) {
      return const Center(child: Text('게시물이 없습니다.', style: TextStyle(fontFamily: 'Wanted Sans')));
    }

    final firstPost = posts.first;
    final remainingPosts = posts.skip(1).take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstPost.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _stripHtmlTags(firstPost.content).length > 100
                      ? '${_stripHtmlTags(firstPost.content).substring(0, 100)}...'
                      : _stripHtmlTags(firstPost.content),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Wanted Sans',
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      firstPost.author,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Wanted Sans',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|',
                       style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Wanted Sans',
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      firstPost.date,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Wanted Sans',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: remainingPosts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = remainingPosts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                    title: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Wanted Sans',
                        color: AppTheme.textPrimaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          post.author,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Wanted Sans',
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          post.date,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Wanted Sans',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      print('Navigate to post: ${post.id}');
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 120.0),
            child: TextButton(
              onPressed: () {
                if (boardTitle == '공지사항') {
                  Navigator.pushNamed(context, AppRoutes.notice);
                } else if (boardTitle == 'Q&A') {
                  Navigator.pushNamed(context, AppRoutes.qna);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('정보공유방 페이지는 아직 준비 중입니다.'))
                  );
                }
              },
              child: const Text(
                '+ 더보기',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Wanted Sans',
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 새로운 통합 바로가기 및 협력업체 섹션
  Widget _buildCombinedLinksAndPartnersSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0), // 좌우 패딩 추가
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // flex 조정 (기존 2 -> 3)
            child: _buildQuickLinksWebSection(context),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 7, // flex 조정 (기존 3, 5 -> 7)
            child: _buildPartnersWebSection(context),
          ),
        ],
      ),
    );
  }

  // 웹용 바로가기 섹션
  Widget _buildQuickLinksWebSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding (
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            '바로가기',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
              fontFamily: 'Wanted Sans',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWebQuickLinkItem(
                imageUrl: 'assets/icons/naver.png',
                label: '네이버 카페 \n 바로가기',
                color: Color(0xFF02C75C),
                onTap: () => _launchURL('https://cafe.naver.com/yourcafe'),
              ),
              _buildWebQuickLinkItem(
                imageUrl: 'assets/icons/youtube.png',
                label: '유튜브 채널 \n 바로가기',
                color: Color(0xFF41505D),
                onTap: () => _launchURL('https://www.youtube.com/yourchannel'),
              ),
              _buildWebQuickLinkItem(
                imageUrl: 'assets/icons/kakao.png',
                label: '카카오톡 단톡방 \n 바로가기',
                color: Color(0xFF381E1F),
                onTap: () => _launchURL('https://open.kakao.com/o/yourchatlink'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 웹용 협력업체 섹션
  Widget _buildPartnersWebSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '협력업체',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
            fontFamily: 'Wanted Sans',
          ),
        ),
        const SizedBox(height: 16.0),
        if (_displayedPartners.isEmpty)
          const Center(child: Text('등록된 협력업체가 없습니다.', style: TextStyle(fontFamily: 'Wanted Sans')))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _displayedPartners.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
            itemBuilder: (context, index) {
              final partner = _displayedPartners[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                title: Text(
                  partner.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Wanted Sans',
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  partner.introduction,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Wanted Sans',
                    color: AppTheme.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  print('Tapped partner: ${partner.name}');
                },
              );
            },
          ),
      ],
    );
  }

  // 웹 화면용 바로가기 아이템 위젯
  Widget _buildWebQuickLinkItem({
    required String imageUrl,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imageUrl,
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.link, size: 32, color: AppTheme.primaryColor);
              },
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
                fontFamily: 'Wanted Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 광고 배너 아이템 위젯
  Widget _buildAdBannerItem(BuildContext context, AdBannerItem banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GestureDetector(
          onTap: banner.linkUrl != null
              ? () => _launchURL(banner.linkUrl!)
              : null,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: banner.imageUrl != null
                    ? Image.network(
                        banner.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.broken_image, size: 48),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            banner.altText,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    banner.altText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Wanted Sans',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (banner.linkUrl != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '더보기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Wanted Sans',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 로그인 상태 표시 섹션 (새로 추가)
  Widget _buildLoginStatusSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('인증 상태 확인 중...'),
              ],
            ),
          );
        }

        if (authProvider.isLoggedIn && authProvider.currentUser != null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  authProvider.isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${authProvider.currentUser!.name}님, 안녕하세요!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        authProvider.isAdmin ? '관리자로 로그인됨' : '일반 사용자로 로그인됨',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (authProvider.lastActivityTime != null)
                  Text(
                    '마지막 활동: ${authProvider.lastActivityTime!.hour}:${authProvider.lastActivityTime!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.login, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '로그인이 필요합니다',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '더 많은 서비스를 이용하려면 로그인하세요',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
                    final slug = unionProvider.currentUnion?.homepage;
                    
                    if (slug != null) {
                      Navigator.pushNamed(context, '/$slug/${AppRoutes.login}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('로그인'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
} 