import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/models/notice_item_model.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/widgets/common/ad_banner_widget.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/list_template_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:johabon_pwa/screens/community/notice_write_screen.dart';
import 'package:johabon_pwa/screens/community/notice_detail_screen.dart';
import 'package:johabon_pwa/services/notice_service.dart';
// ignore: uri_does_not_exist
import 'dart:js' if (dart.library.io) 'package:johabon_pwa/utils/stub_js.dart' as js;
import 'dart:convert';

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
  int _totalItems = 0;
  String? _currentUserType;
  bool _isLoading = false;

  final NoticeService _noticeService = NoticeService();

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _loadPageData(_currentPage);
  }

  // 사용자 타입 로드
  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserType = prefs.getString('user_type');
    });
  }

  // 글쓰기 버튼 클릭 처리
  void _handleWriteButtonTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoticeWriteScreen(),
      ),
    );

    // 글쓰기 화면에서 저장 성공 시 리스트 새로고침
    if (result == true) {
      await _loadPageData(_currentPage);
    }
  }

  // 페이지 데이터 로드
  Future<void> _loadPageData(int page) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _noticeService.getNotices(
        page: page,
        itemsPerPage: _itemsPerPage,
      );

      setState(() {
        _currentPage = page;
        _noticeItems = result['items'];
        _totalItems = result['totalCount'];
        _isLoading = false;
      });
    } catch (e) {
      print('공지사항 데이터 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });

      // 에러 발생 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 검색 처리
  Future<void> _handleSearch(String category, String keyword) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _noticeService.getNotices(
        page: 1, // 검색 시 첫 페이지로 리셋
        itemsPerPage: _itemsPerPage,
        searchCategory: category,
        searchKeyword: keyword,
      );

      setState(() {
        _currentPage = 1;
        _noticeItems = result['items'];
        _totalItems = result['totalCount'];
        _isLoading = false;
      });
    } catch (e) {
      print('검색 실패: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // 아이템 클릭 처리
  void _handleItemTap(ListItemInterface item) async {
    if (item is NoticeItem) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoticeDetailScreen(noticeId: item.id),
        ),
      );

      // 상세 화면에서 삭제되었거나 수정되었을 때 리스트 새로고침
      if (result == true) {
        await _loadPageData(_currentPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    // 로딩 상태일 때 로딩 인디케이터 표시
    if (_isLoading && _noticeItems.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
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