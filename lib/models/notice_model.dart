class NoticeModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;
  final String? attachmentUrl;
  final String? authorId;
  final String? authorName;
  final int? viewCount;
  final bool? isSendAlarm;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isImportant,
    this.attachmentUrl,
    this.authorId,
    this.authorName,
    this.viewCount,
    this.isSendAlarm,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isImportant: json['isImportant'] ?? false,
      attachmentUrl: json['attachmentUrl'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      viewCount: json['viewCount'],
      isSendAlarm: json['isSendAlarm'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
      'attachmentUrl': attachmentUrl,
      'authorId': authorId,
      'authorName': authorName,
      'viewCount': viewCount,
      'isSendAlarm': isSendAlarm,
    };
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isImportant,
    String? attachmentUrl,
    String? authorId,
    String? authorName,
    int? viewCount,
    bool? isSendAlarm,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      viewCount: viewCount ?? this.viewCount,
      isSendAlarm: isSendAlarm ?? this.isSendAlarm,
    );
  }
} 