
import 'package:johabon_pwa/models/notice_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NoticeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final uuid = const Uuid();

  // 공지사항 카테고리 ID 가져오기
  Future<String?> getNoticesCategoryId() async {
    try {
      final response = await _supabase
          .from('post_categories')
          .select('id')
          .eq('key', 'notice')
          .single();
      return response['id'];
    } catch (e) {
      print('Error fetching notices category ID: $e');
      return null;
    }
  }

  // 콘텐츠에 이미지가 있는지 확인
  bool _hasImageInContent(String content) {
    if (content.isEmpty) return false;
    if (content.contains('<img')) return true;
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.svg'
    ];
    for (final ext in imageExtensions) {
      if (content.toLowerCase().contains(ext)) return true;
    }
    try {
      if (content.contains('"image"')) {
        return true;
      }
    } catch (e) {
      // JSON parsing failed
    }
    return false;
  }

  // 공지사항 목록 가져오기
  Future<Map<String, dynamic>> getNotices({
    required int page,
    required int itemsPerPage,
    String? searchCategory,
    String? searchKeyword,
  }) async {
    final noticesCategoryId = await getNoticesCategoryId();
    if (noticesCategoryId == null) {
      throw Exception('공지사항 카테고리를 찾을 수 없습니다.');
    }

    var query = _supabase
        .from('posts')
        .select('*, post_categories!inner(name), post_subcategories(name)')
        .eq('category_id', noticesCategoryId);

    if (searchKeyword != null && searchKeyword.isNotEmpty) {
      String searchField = 'title';
      if (searchCategory == '작성자') {
        searchField = 'created_by';
      } else if (searchCategory == '내용') {
        searchField = 'content';
      }
      query = query.ilike(searchField, '%$searchKeyword%');
    }

    final countQuery = query.count();
    final dataQuery = query
        .order('created_at', ascending: false)
        .range((page - 1) * itemsPerPage, page * itemsPerPage - 1);

    final countResponse = await countQuery;
    final dataResponse = await dataQuery;

    final totalCount = countResponse.count;

    final List<NoticeItem> items = [];
    for (final item in dataResponse as List) {
      final flattenedItem = Map<String, dynamic>.from(item);
      if (item['post_categories'] != null) {
        flattenedItem['category_name'] = item['post_categories']['name'];
      }
      if (item['post_subcategories'] != null) {
        flattenedItem['subcategory_name'] =
            item['post_subcategories']['name'];
      }

      try {
        final attachmentCount = await _supabase
            .from('attachments')
            .select('id')
            .eq('target_table', 'posts')
            .eq('target_id', item['id'])
            .count();
        flattenedItem['has_attachments'] = (attachmentCount.count > 0);
      } catch (e) {
        print('Error counting attachments: $e');
        flattenedItem['has_attachments'] = false;
      }

      final content = item['content']?.toString() ?? '';
      flattenedItem['has_image'] = _hasImageInContent(content);

      items.add(NoticeItem.fromJson(flattenedItem));
    }

    return {'items': items, 'totalCount': totalCount};
  }

  // 공지사항 상세 정보 가져오기
  Future<Map<String, dynamic>> getNoticeDetails(String noticeId) async {
    try {
      final postResponse =
          await _supabase.from('posts').select().eq('id', noticeId).single();

      final attachmentResponse = await _supabase
          .from('attachments')
          .select()
          .eq('target_table', 'posts')
          .eq('target_id', noticeId);

      return {
        'noticeData': postResponse,
        'attachments': List<Map<String, dynamic>>.from(attachmentResponse),
      };
    } catch (e) {
      print('Error fetching notice details: $e');
      rethrow;
    }
  }

  // 공지사항 생성
  Future<void> createNotice({
    required String title,
    required String content,
    required String categoryId,
    required String subcategoryId,
    required String unionId,
    required String createdBy,
    required List<dynamic> attachmentFiles,
  }) async {
    final postData = {
      'union_id': unionId,
      'title': title,
      'content': content,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'popup': false,
      'created_by': createdBy,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response =
        await _supabase.from('posts').insert(postData).select().single();
    final postId = response['id'];

    await _uploadNewAttachments(
        postId: postId,
        attachmentFiles: attachmentFiles,
        unionId: unionId,
        userId: createdBy);
  }

  // 공지사항 수정
  Future<void> updateNotice({
    required String noticeId,
    required String title,
    required String content,
    required String categoryId,
    required String subcategoryId,
    required List<dynamic> newAttachmentFiles,
    required List<String> attachmentsToDelete,
    required List<Map<String, dynamic>> existingAttachments,
    required String unionId,
    required String userId,
  }) async {
    await _supabase.from('posts').update({
      'title': title.trim(),
      'content': content,
      'category_id': categoryId.trim(),
      'subcategory_id': subcategoryId.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', noticeId);

    await _deleteRemovedAttachments(
        attachmentsToDelete: attachmentsToDelete,
        existingAttachments: existingAttachments);
    await _uploadNewAttachments(
        postId: noticeId,
        attachmentFiles: newAttachmentFiles,
        unionId: unionId,
        userId: userId);
  }

  // 공지사항 삭제
  Future<void> deleteNotice(String noticeId) async {
    final attachmentResponse = await _supabase
        .from('attachments')
        .select()
        .eq('target_table', 'posts')
        .eq('target_id', noticeId);

    final attachments = List<Map<String, dynamic>>.from(attachmentResponse);

    for (final attachment in attachments) {
      try {
        final fileUrl = attachment['file_url'] as String;
        final storagePath = _extractStoragePathFromUrl(fileUrl);

        if (storagePath.isNotEmpty) {
          await _supabase.storage.from('post-upload').remove([storagePath]);
        }
      } catch (e) {
        print(
            '[Delete] Failed to delete attachment: ${attachment['file_name']} - $e');
      }
    }

    await _supabase
        .from('attachments')
        .delete()
        .eq('target_table', 'posts')
        .eq('target_id', noticeId);

    await _supabase.from('posts').delete().eq('id', noticeId);
  }

  // 새로운 첨부파일 업로드
  Future<void> _uploadNewAttachments({
    required String postId,
    required List<dynamic> attachmentFiles,
    required String unionId,
    required String userId,
  }) async {
    for (final file in attachmentFiles) {
      try {
        if (file.bytes != null) {
          final originalFileName = file.name;
          final fileExtension = originalFileName.contains('.')
              ? originalFileName.substring(originalFileName.lastIndexOf('.'))
              : '';
          final attachmentId = uuid.v4();
          final uniqueFileName = '$attachmentId$fileExtension';
          final storagePath = 'posts/$postId/$uniqueFileName';

          await _supabase.storage
              .from('post-upload')
              .uploadBinary(storagePath, file.bytes!);

          final publicUrl =
              _supabase.storage.from('post-upload').getPublicUrl(storagePath);

          await _supabase.from('attachments').insert({
            'id': attachmentId,
            'union_id': unionId,
            'target_table': 'posts',
            'target_id': postId,
            'file_url': publicUrl,
            'file_name': originalFileName,
            'file_type':
                fileExtension.isNotEmpty ? fileExtension.substring(1) : null,
            'file_size': file.bytes!.length,
            'uploaded_by': userId,
            'uploaded_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        print('Failed to upload attachment: ${file.name} - $e');
      }
    }
  }

  // 삭제된 첨부파일 처리
  Future<void> _deleteRemovedAttachments({
    required List<String> attachmentsToDelete,
    required List<Map<String, dynamic>> existingAttachments,
  }) async {
    for (final attachmentId in attachmentsToDelete) {
      try {
        final attachment =
            existingAttachments.firstWhere((a) => a['id'] == attachmentId);
        final fileUrl = attachment['file_url'] as String;
        final storagePath = _extractStoragePathFromUrl(fileUrl);

        if (storagePath.isNotEmpty) {
          await _supabase.storage.from('post-upload').remove([storagePath]);
        }

        await _supabase.from('attachments').delete().eq('id', attachmentId);
      } catch (e) {
        print('Failed to delete attachment ($attachmentId): $e');
      }
    }
  }

  // URL에서 스토리지 경로 추출
  String _extractStoragePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      final bucketIndex = pathSegments.indexOf('post-upload');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }

      if (pathSegments.contains('object')) {
        final objectIndex = pathSegments.indexOf('object');
        if (objectIndex + 3 < pathSegments.length &&
            pathSegments[objectIndex + 2] == 'post-upload') {
          return pathSegments.sublist(objectIndex + 3).join('/');
        }
      }

      return '';
    } catch (e) {
      print('Error extracting storage path: $e');
      return '';
    }
  }
}

