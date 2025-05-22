import 'package:flutter/material.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';

// 리스트 아이템 인터페이스
abstract class ListItemInterface {
  String get id;
  String get title;
  String get author;
  String get date;
  bool get isPinned;
  bool get isLocked;
  bool get hasImage;
  bool get hasLink;
}

class ListTemplateWidget extends StatefulWidget {
  // 필수 매개변수
  final String title;
  final List<String> breadcrumbItems;
  final List<ListItemInterface> items;
  
  // 선택적 매개변수
  final List<String>? searchCategories;
  final Function(String, String)? onSearch;
  final Function(ListItemInterface)? onItemTap;
  final Widget? leftSidebar;
  final Widget? rightSidebar;

  // 페이지네이션 관련 매개변수
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final Function(int)? onPageChanged;

  // 권한 관련 매개변수 추가
  final List<String> writePermissionTypes;
  final String? currentUserType;
  final VoidCallback? onWriteButtonTap;

  const ListTemplateWidget({
    super.key,
    required this.title,
    required this.breadcrumbItems,
    required this.items,
    this.searchCategories,
    this.onSearch,
    this.onItemTap,
    this.leftSidebar,
    this.rightSidebar,
    this.currentPage = 1,
    this.totalItems = 0,
    this.itemsPerPage = 10,
    this.onPageChanged,
    this.writePermissionTypes = const ['admin'],
    this.currentUserType,
    this.onWriteButtonTap,
  });

  @override
  State<ListTemplateWidget> createState() => _ListTemplateWidgetState();
}

class _ListTemplateWidgetState extends State<ListTemplateWidget> {
  // 상태 변수
  late String _selectedSearchCategory;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _defaultSearchCategories = ['제목', '내용', '작성자'];

  @override
  void initState() {
    super.initState();
    _selectedSearchCategory = widget.searchCategories?.first ?? _defaultSearchCategories.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 처리
  void _handleSearch() {
    if (widget.onSearch != null) {
      widget.onSearch!(_selectedSearchCategory, _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentLayoutTemplate(
      title: widget.title,
      leftSidebarContent: widget.leftSidebar,
      rightSidebarContent: widget.rightSidebar,
      applyPadding: false,
      body: _buildListContent(context),
    );
  }

  Widget _buildListContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 경로 표시
          _buildBreadcrumb(context),
          
          const SizedBox(height: 16),
          
          // 제목과 검색 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'Wanted Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF41505D),
                    ),
                  ),
                  if (widget.currentUserType != null && 
                      widget.writePermissionTypes.contains(widget.currentUserType))
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onWriteButtonTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF75D49B),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '글쓰기',
                                  style: TextStyle(
                                    fontFamily: 'Wanted Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _buildSearchArea(context),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // 리스트 헤더
          _buildListHeader(context),
          
          // 리스트 아이템들
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEAEAEA), width: 1),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                return _buildListItem(context, widget.items[index], index + 1);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 페이지네이션
          _buildPagination(context),
        ],
      ),
    );
  }

  // 이하 필요한 메서드들은 notice_list_screen.dart에서 가져와서 수정할 예정입니다.
  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < widget.breadcrumbItems.length; i++) ...[
          if (i > 0) _buildBreadcrumbDivider(),
          _buildBreadcrumbItem(
            widget.breadcrumbItems[i],
            () {},
            isActive: i == widget.breadcrumbItems.length - 1,
          ),
        ],
      ],
    );
  }

  Widget _buildBreadcrumbDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: Color(0xFF41505D),
      ),
    );
  }

  Widget _buildBreadcrumbItem(String text, VoidCallback onPressed, {bool isActive = false}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Wanted Sans',
          fontSize: 16,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          color: Color(0xFF41505D),
        ),
      ),
    );
  }

  // 나머지 메서드들은 계속해서 구현할 예정입니다.
  Widget _buildSearchArea(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 드롭다운 (검색 카테고리)
        SizedBox(
          width: 200,
          height: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFCED4DA)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<String>(
              value: _selectedSearchCategory,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF343A40),
                size: 16,
              ),
              underline: Container(),
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 14,
                fontFamily: 'Wanted Sans',
              ),
              items: (widget.searchCategories ?? _defaultSearchCategories).map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(value),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSearchCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
        
        SizedBox(width: 10),
        
        // 검색 입력 필드
        SizedBox(
          width: 400,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF41505D), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '검색어를 입력해주세요',
                      hintStyle: TextStyle(
                        color: Color(0xFF6C757D),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    style: TextStyle(
                      color: Color(0xFF41505D),
                      fontSize: 14,
                    ),
                    onSubmitted: (_) => _handleSearch(),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _handleSearch,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF41505D),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFEAEAEA), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '번호',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF41505D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '제목',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF41505D),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              '글쓴이',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF41505D),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              '등록일',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF41505D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ListItemInterface item, int number) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.onItemTap != null) {
            widget.onItemTap!(item);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFC9CACC), width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 번호
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontFamily: 'Wanted Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF41505D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 제목 및 아이콘
              Expanded(
                child: Row(
                  children: [
                    if (item.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Color(0xFF41505D),
                        ),
                      ),
                    if (item.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.lock,
                          size: 16,
                          color: Color(0xFF41505D),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Wanted Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF41505D),
                        ),
                      ),
                    ),
                    if (item.hasLink)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.link,
                          size: 16,
                          color: Color(0xFF41505D),
                        ),
                      ),
                    if (item.hasImage)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.image,
                          size: 16,
                          color: Color(0xFF41505D),
                        ),
                      ),
                  ],
                ),
              ),

              // 글쓴이
              SizedBox(
                width: 200,
                child: Text(
                  item.author,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF41505D),
                  ),
                ),
              ),
              
              // 등록일
              SizedBox(
                width: 120,
                child: Text(
                  item.date,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 13,
                    color: Color(0xFF41505D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    if (widget.totalItems == 0) return Container();

    final totalPages = (widget.totalItems / widget.itemsPerPage).ceil();
    final currentPage = widget.currentPage;
    
    // 표시할 페이지 번호 계산
    List<int> pageNumbers = [];
    if (totalPages <= 10) {
      pageNumbers = List.generate(totalPages, (index) => index + 1);
    } else {
      // 현재 페이지 주변의 페이지 번호만 표시
      if (currentPage <= 5) {
        pageNumbers = [...List.generate(7, (index) => index + 1), -1, totalPages - 1, totalPages];
      } else if (currentPage >= totalPages - 4) {
        pageNumbers = [1, 2, -1, ...List.generate(7, (index) => totalPages - 6 + index)];
      } else {
        pageNumbers = [1, 2, -1, currentPage - 2, currentPage - 1, currentPage, currentPage + 1, currentPage + 2, -1, totalPages];
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 페이지 정보
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Text(
            '총 $totalPages 페이지',
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 16,
              color: Color(0xFF212529),
            ),
          ),
        ),
        
        // 페이지네이션 버튼
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFDEE2E6)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이전 페이지 버튼
              _buildPaginationButton(
                Icons.chevron_left,
                currentPage > 1,
                () {
                  if (currentPage > 1 && widget.onPageChanged != null) {
                    widget.onPageChanged!(currentPage - 1);
                  }
                },
              ),
              
              // 페이지 번호 버튼들
              for (var pageNum in pageNumbers)
                if (pageNum == -1)
                  _buildPageNumberButton('...', isEllipsis: true)
                else
                  _buildPageNumberButton(
                    pageNum.toString(),
                    isActive: pageNum == currentPage,
                    onTap: () {
                      if (pageNum != currentPage && widget.onPageChanged != null) {
                        widget.onPageChanged!(pageNum);
                      }
                    },
                  ),
              
              // 다음 페이지 버튼
              _buildPaginationButton(
                Icons.chevron_right,
                currentPage < totalPages,
                () {
                  if (currentPage < totalPages && widget.onPageChanged != null) {
                    widget.onPageChanged!(currentPage + 1);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationButton(IconData icon, bool enabled, VoidCallback onPressed) {
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Color(0xFFDEE2E6)),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? Color(0xFF41505D) : Color(0xFFDEE2E6),
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(String number, {bool isActive = false, bool isEllipsis = false, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: (onTap != null && !isEllipsis) ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: (!isEllipsis && onTap != null) ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Color(0xFF75D49B) : Colors.transparent,
            border: Border(
              right: BorderSide(color: Color(0xFFDEE2E6)),
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 16,
              color: isActive ? Colors.white : Color(0xFF41505D),
            ),
          ),
        ),
      ),
    );
  }
} 