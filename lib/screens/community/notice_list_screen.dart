import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/widgets/common/ad_banner_widget.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/list_template_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:johabon_pwa/screens/community/notice_write_screen.dart';
// ignore: uri_does_not_exist
import 'dart:js' if (dart.library.io) 'package:johabon_pwa/utils/stub_js.dart' as js;
import 'dart:convert';

// NoticeItem 클래스 정의 (ListItemInterface 구현)
class NoticeItem implements ListItemInterface {
  @override
  final String id;
  @override
  final String title;
  @override
  final String author;
  @override
  final String date;
  @override
  final bool isPinned;
  @override
  final bool isLocked;
  @override
  final bool hasImage;
  @override
  final bool hasLink;

  NoticeItem({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    this.isPinned = false,
    this.isLocked = false,
    this.hasImage = false,
    this.hasLink = false,
  });
}

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  // 상태 변수
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<NoticeItem> _noticeItems = [];
  int _totalItems = 85; // 임시로 총 85개 아이템이 있다고 가정
  String? _currentUserType;

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    _loadPageData(_currentPage);
    _loadUserType();
  }

  // 사용자 타입 로드
  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserType = prefs.getString('user_type');
    });
  }

  // 글쓰기 버튼 클릭 처리
  void _handleWriteButtonTap() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const NoticeWriteScreen(),
      ),
    );
  }

  // 페이지 데이터 로드 (임시 데이터 생성)
  void _loadPageData(int page) {
    setState(() {
      _currentPage = page;
      _noticeItems = List.generate(
        _itemsPerPage,
        (index) {
          final itemIndex = (page - 1) * _itemsPerPage + index;
          return NoticeItem(
            id: '$itemIndex',
            title: '2025년 제${itemIndex + 1}차 대의원회 소집 안내',
            author: '관리자',
            date: '2025.05.${20 - (itemIndex % 20)}',
            isPinned: itemIndex < 2,
            isLocked: itemIndex % 3 == 0,
            hasImage: itemIndex % 5 == 0,
            hasLink: itemIndex % 4 == 0,
          );
        },
      );
    });
  }

  // 검색 처리
  void _handleSearch(String category, String keyword) {
    print('검색: $category - $keyword');
    // 실제로는 여기서 검색 API를 호출하게 됩니다.
  }

  // 아이템 클릭 처리
  void _handleItemTap(ListItemInterface item) {
    print('선택된 아이템: ${item.title}');
    // 실제로는 여기서 상세 페이지로 이동하게 됩니다.
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    // 좌측 광고 배너
    final leftSidebar = AdBannersColumn(
      banners: [
        AdBannerWidget(
          title: '빈자리에요\n어서오세요',
          description: '광고배너\n문의환영',
          imageUrl: 'assets/images/banner_hundea.png',
          backgroundColor: Colors.white,
          onTap: () {
            // 광고 클릭 처리
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고 문의: 02-123-1234')),
            );
          },
        ),
      ],
    );
    
    // 우측 광고 배너
    final rightSidebar = AdBannersColumn(
      banners: [
        AdBannerWidget(
          title: '홈페이지 내\n광고문의',
          description: '02-123-1234',
          imageUrl: 'assets/images/banner_default.png',
          backgroundColor: Colors.white,
          onTap: () {
            // 광고 클릭 처리
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고 문의: 02-123-1234')),
            );
          },
        ),
      ],
    );

    return ListTemplateWidget(
      title: '공지사항',
      breadcrumbItems: ['홈', '커뮤니티', '공지사항'],
      items: _noticeItems,
      currentPage: _currentPage,
      totalItems: _totalItems,
      itemsPerPage: _itemsPerPage,
      leftSidebar: leftSidebar,
      rightSidebar: rightSidebar,
      onSearch: _handleSearch,
      onItemTap: _handleItemTap,
      onPageChanged: _loadPageData,
      writePermissionTypes: const ['admin', 'member', 'systemadmin'],
      currentUserType: _currentUserType,
      onWriteButtonTap: _handleWriteButtonTap,
    );
  }
} 