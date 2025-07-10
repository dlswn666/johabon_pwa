import 'package:johabon_pwa/widgets/common/list_template_widget.dart';

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
  })  : _categoryName = categoryName,
        _subcategoryName = subcategoryName;

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['created_by'] ?? '',
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal().toString().split(' ')[0]
          : '',
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
