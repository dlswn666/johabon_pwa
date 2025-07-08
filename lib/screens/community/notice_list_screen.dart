import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/widgets/common/ad_banner_widget.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/list_template_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:johabon_pwa/screens/community/notice_write_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  final String? content;
  final String? unionId;
  final String? subcategoryId;
  final String? categoryId;
  final bool popup;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? _categoryName;
  final String? _subcategoryName;

  // ListItemInterface의 categoryName, subcategoryName getter 오버라이드
  @override
  String? get categoryName => _categoryName;
  
  @override
  String? get subcategoryName => _subcategoryName;

  NoticeItem({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    this.isPinned = false,
    this.isLocked = false,
    this.hasImage = false,
    this.hasLink = false,
    this.content,
    this.unionId,
    this.subcategoryId,
    this.categoryId,
    this.popup = false,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
    String? categoryName,
    String? subcategoryName,
  }) : _categoryName = categoryName,
       _subcategoryName = subcategoryName;

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['created_by'] ?? '',
      date: json['created_at'] != null ? 
        DateTime.parse(json['created_at']).toLocal().toString().split(' ')[0] :
        '',
      isPinned: json['popup'] ?? false,
      isLocked: false,
      hasImage: json['has_image'] ?? false,
      hasLink: json['has_attachments'] ?? false,
      content: json['content'],
      unionId: json['union_id'],
      subcategoryId: json['subcategory_id'],
      categoryId: json['category_id'],
      popup: json['popup'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      updatedBy: json['updated_by'],
      categoryName: json['category_name'],
      subcategoryName: json['subcategory_name'],
    );
  }
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
  int _totalItems = 0;
  String? _currentUserType;
  bool _isLoading = false;
  String? _noticesCategoryId;
  
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    _loadNoticesCategoryId();
  }

  // 사용자 타입 로드
  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserType = prefs.getString('user_type');
    });
  }

  // 공지사항 카테고리 ID 로드
  Future<void> _loadNoticesCategoryId() async {
    try {
      final response = await _supabase
          .from('post_categories')
          .select('id')
          .eq('key', 'notice')
          .single();
      
      setState(() {
        _noticesCategoryId = response['id'];
      });
      
      // 카테고리 ID가 로드되면 데이터 로드
      if (_noticesCategoryId != null) {
        await _loadPageData(_currentPage);
      }
    } catch (e) {
      print('공지사항 카테고리 ID 로드 실패: $e');
    }
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
    if (_noticesCategoryId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 총 개수 조회
      final countResponse = await _supabase
          .from('posts')
          .select('id')
          .eq('category_id', _noticesCategoryId!)
          .count();
      
      final totalCount = countResponse.count;
      
      // 페이지 데이터 조회 (카테고리, 서브카테고리 정보 포함)
      final dataResponse = await _supabase
          .from('posts')
          .select('''
            *,
            post_categories!inner(name),
            post_subcategories(name)
          ''')
          .eq('category_id', _noticesCategoryId!)
          .order('created_at', ascending: false)
          .range(
            (page - 1) * _itemsPerPage,
            page * _itemsPerPage - 1,
          );
      
      // 각 게시글에 대해 첨부파일 개수 확인
      final List<NoticeItem> items = [];
      for (final item in dataResponse as List) {
        // 관계형 데이터 플래튼화
        final flattenedItem = Map<String, dynamic>.from(item);
        if (item['post_categories'] != null) {
          flattenedItem['category_name'] = item['post_categories']['name'];
        }
        if (item['post_subcategories'] != null) {
          flattenedItem['subcategory_name'] = item['post_subcategories']['name'];
        }
        
        // 첨부파일 개수 확인
        try {
          final attachmentCount = await _supabase
              .from('attachments')
              .select('id')
              .eq('target_table', 'posts')
              .eq('target_id', item['id'])
              .count();
          
          flattenedItem['has_attachments'] = (attachmentCount.count > 0);
        } catch (e) {
          print('첨부파일 개수 확인 실패: $e');
          flattenedItem['has_attachments'] = false;
        }
        
        // 콘텐츠에 이미지가 있는지 확인
        final content = item['content']?.toString() ?? '';
        flattenedItem['has_image'] = _hasImageInContent(content);
        
        items.add(NoticeItem.fromJson(flattenedItem));
      }

      setState(() {
        _currentPage = page;
        _noticeItems = items;
        _totalItems = totalCount;
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
    if (_noticesCategoryId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      String searchField = 'title';
      if (category == '작성자') {
        searchField = 'created_by';
      } else if (category == '내용') {
        searchField = 'content';
      }
      
      // 검색 결과 개수 조회
      final countResponse = await _supabase
          .from('posts')
          .select('id')
          .eq('category_id', _noticesCategoryId!)
          .ilike(searchField, '%$keyword%')
          .count();
      
      final totalCount = countResponse.count;
      
      // 검색 결과 조회 (카테고리, 서브카테고리 정보 포함)
      final dataResponse = await _supabase
          .from('posts')
          .select('''
            *,
            post_categories!inner(name),
            post_subcategories(name)
          ''')
          .eq('category_id', _noticesCategoryId!)
          .ilike(searchField, '%$keyword%')
          .order('created_at', ascending: false)
          .range(0, _itemsPerPage - 1);
      
      // 각 게시글에 대해 첨부파일 개수 확인
      final List<NoticeItem> items = [];
      for (final item in dataResponse as List) {
        // 관계형 데이터 플래튼화
        final flattenedItem = Map<String, dynamic>.from(item);
        if (item['post_categories'] != null) {
          flattenedItem['category_name'] = item['post_categories']['name'];
        }
        if (item['post_subcategories'] != null) {
          flattenedItem['subcategory_name'] = item['post_subcategories']['name'];
        }
        
        // 첨부파일 개수 확인
        try {
          final attachmentCount = await _supabase
              .from('attachments')
              .select('id')
              .eq('target_table', 'posts')
              .eq('target_id', item['id'])
              .count();
          
          flattenedItem['has_attachments'] = (attachmentCount.count > 0);
        } catch (e) {
          print('첨부파일 개수 확인 실패: $e');
          flattenedItem['has_attachments'] = false;
        }
        
        // 콘텐츠에 이미지가 있는지 확인
        final content = item['content']?.toString() ?? '';
        flattenedItem['has_image'] = _hasImageInContent(content);
        
        items.add(NoticeItem.fromJson(flattenedItem));
      }

      setState(() {
        _currentPage = 1;
        _noticeItems = items;
        _totalItems = totalCount;
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

  // 콘텐츠에 이미지가 있는지 확인하는 메서드
  bool _hasImageInContent(String content) {
    if (content.isEmpty) return false;
    
    // HTML img 태그가 있는지 확인
    if (content.contains('<img')) return true;
    
    // 이미지 URL이 있는지 확인 (일반적인 이미지 확장자)
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'];
    for (final ext in imageExtensions) {
      if (content.toLowerCase().contains(ext)) return true;
    }
    
    // Quill 에디터의 이미지 형식 확인 ({"insert":{"image":"url"}})
    try {
      if (content.contains('"image"')) {
        return true;
      }
    } catch (e) {
      // JSON 파싱 실패 시 무시
    }
    
    return false;
  }

  // 아이템 클릭 처리
  void _handleItemTap(ListItemInterface item) {
    print('선택된 아이템: ${item.title}');
    // 실제로는 여기서 상세 페이지로 이동하게 됩니다.
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