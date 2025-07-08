import 'package:flutter/material.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/widgets/common/custom_text_field.dart';
import 'package:johabon_pwa/widgets/common/quill_editor_field.dart';
import 'package:johabon_pwa/widgets/common/attachment_field.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class NoticeEditScreen extends StatefulWidget {
  final String noticeId;

  const NoticeEditScreen({
    super.key,
    required this.noticeId,
  });

  @override
  State<NoticeEditScreen> createState() => _NoticeEditScreenState();
}

class _NoticeEditScreenState extends State<NoticeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final uuid = const Uuid();

  String _content = '';
  List<dynamic> _attachmentFiles = [];
  List<Map<String, dynamic>> _existingAttachments = [];
  List<String> _attachmentsToDelete = [];
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _noticeData;

  // Cleanup handler for Quill editor
  Future<void> Function({String? content})? _cleanupHandler;

  @override
  void initState() {
    super.initState();
    _loadNoticeData();
  }

  Future<void> _loadNoticeData() async {
    try {
      setState(() => _isLoading = true);

      // 1. 공지사항 데이터 로드
      final noticeResponse = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('id', widget.noticeId)
          .single();

      // 2. 첨부파일 데이터 로드
      final attachmentResponse = await Supabase.instance.client
          .from('attachments')
          .select()
          .eq('target_table', 'posts')
          .eq('target_id', widget.noticeId);

      setState(() {
        _noticeData = noticeResponse;
        _existingAttachments = List<Map<String, dynamic>>.from(attachmentResponse);
        
        // 폼 필드 초기화
        _titleController.text = _noticeData!['title'] ?? '';
        _categoryController.text = _noticeData!['category'] ?? '';
        _subcategoryController.text = _noticeData!['subcategory'] ?? '';
        _content = _noticeData!['content'] ?? '';
        
        _isLoading = false;
      });

      print('[수정 화면] 데이터 로드 완료');
      print('[수정 화면] 제목: ${_titleController.text}');
      print('[수정 화면] 첨부파일 개수: ${_existingAttachments.length}');
    } catch (e) {
      print('[수정 화면] 데이터 로드 실패: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _saveNotice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);

    if (authProvider.currentUser == null || unionProvider.currentUnion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. 게시글 업데이트
      await Supabase.instance.client
          .from('posts')
          .update({
            'title': _titleController.text.trim(),
            'content': _content,
            'category': _categoryController.text.trim(),
            'subcategory': _subcategoryController.text.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.noticeId);

      print('[수정] 게시글 업데이트 완료');

      // 2. 삭제할 첨부파일 처리
      await _deleteRemovedAttachments();

      // 3. 새로운 첨부파일 업로드
      await _uploadNewAttachments();

      // 4. Quill 에디터 cleanup
      if (_cleanupHandler != null) {
        await _cleanupHandler!(content: _content);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('수정이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // 수정 완료를 알리며 상세 화면으로 돌아가기
      }
    } catch (e) {
      print('[수정] 저장 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteRemovedAttachments() async {
    for (final attachmentId in _attachmentsToDelete) {
      try {
        // Storage에서 파일 삭제
        final attachment = _existingAttachments.firstWhere(
          (a) => a['id'] == attachmentId,
        );
        final fileUrl = attachment['file_url'] as String;
        final storagePath = _extractStoragePathFromUrl(fileUrl);
        
        if (storagePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('post-upload')
              .remove([storagePath]);
        }

        // DB에서 첨부파일 레코드 삭제
        await Supabase.instance.client
            .from('attachments')
            .delete()
            .eq('id', attachmentId);

        print('[수정] 첨부파일 삭제 완료: $attachmentId');
      } catch (e) {
        print('[수정] 첨부파일 삭제 실패 ($attachmentId): $e');
      }
    }
  }

  Future<void> _uploadNewAttachments() async {
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    for (final file in _attachmentFiles) {
      try {
        if (file.bytes != null) {
          final originalFileName = file.name;
          final fileExtension = originalFileName.contains('.') 
              ? originalFileName.substring(originalFileName.lastIndexOf('.'))
              : '';
          final attachmentId = uuid.v4();
          final uniqueFileName = '$attachmentId$fileExtension';
          final storagePath = 'posts/${widget.noticeId}/$uniqueFileName';
          
          // Storage에 업로드
          await Supabase.instance.client.storage
              .from('post-upload')
              .uploadBinary(storagePath, file.bytes!);
          
          // 공개 URL 생성
          final publicUrl = Supabase.instance.client.storage
              .from('post-upload')
              .getPublicUrl(storagePath);
          
          // attachments 테이블에 정보 저장
          await Supabase.instance.client.from('attachments').insert({
            'id': attachmentId,
            'union_id': unionProvider.currentUnion!.id,
            'target_table': 'posts',
            'target_id': widget.noticeId,
            'file_url': publicUrl,
            'file_name': originalFileName,
            'file_type': fileExtension.isNotEmpty ? fileExtension.substring(1) : null,
            'file_size': file.bytes!.length,
            'uploaded_by': authProvider.currentUser!.id,
            'uploaded_at': DateTime.now().toIso8601String(),
          });
          
          print('[수정] 새 첨부파일 업로드 완료: $originalFileName');
        }
      } catch (e) {
        print('[수정] 첨부파일 업로드 실패: ${file.name} - $e');
      }
    }
  }

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
      print('[경로 추출] 오류: $e');
      return '';
    }
  }

  void _removeExistingAttachment(String attachmentId) {
    setState(() {
      _attachmentsToDelete.add(attachmentId);
      _existingAttachments.removeWhere((a) => a['id'] == attachmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentLayoutTemplate(
      title: '공지사항 수정',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            CustomTextField(
              controller: _titleController,
              label: '제목',
              hint: '제목을 입력해주세요',
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 카테고리
            CustomTextField(
              controller: _categoryController,
              label: '카테고리',
              hint: '카테고리를 입력해주세요',
            ),
            const SizedBox(height: 16),

            // 서브카테고리
            CustomTextField(
              controller: _subcategoryController,
              label: '서브카테고리',
              hint: '서브카테고리를 입력해주세요',
            ),
            const SizedBox(height: 16),

            // 내용
            const Text(
              '내용',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF41505D),
              ),
            ),
            const SizedBox(height: 8),
            QuillEditorField(
              initialContent: _content,
              hintText: '내용을 입력해주세요',
              height: 400,
              onChanged: (content) => _content = content,
              registerCleanupHandler: (handler) => _cleanupHandler = handler,
            ),
            const SizedBox(height: 24),

            // 기존 첨부파일
            if (_existingAttachments.isNotEmpty) ...[
              const Text(
                '기존 첨부파일',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF41505D),
                ),
              ),
              const SizedBox(height: 8),
              _buildExistingAttachments(),
              const SizedBox(height: 16),
            ],

            // 새 첨부파일
            const Text(
              '새 첨부파일 추가',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF41505D),
              ),
            ),
            const SizedBox(height: 8),
            AttachmentField(
              onChanged: (files) => _attachmentFiles = files,
            ),
            const SizedBox(height: 32),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveNotice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('저장'),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingAttachments() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: _existingAttachments.map((attachment) {
          final fileName = attachment['file_name'] as String;
          final fileSize = _getFileSize(attachment['file_size']);
          
          return ListTile(
            leading: const Icon(Icons.attach_file),
            title: Text(fileName, style: const TextStyle(fontSize: 14)),
            subtitle: Text('크기: $fileSize', style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeExistingAttachment(attachment['id']),
              tooltip: '삭제',
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFileSize(dynamic fileSize) {
    if (fileSize == null) return '알 수 없음';
    
    final bytes = fileSize is int ? fileSize : int.tryParse(fileSize.toString()) ?? 0;
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }
} 