import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';    
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

class QuillEditorField extends StatefulWidget {
  final String? initialContent; // Delta JSON string
  final String? hintText;
  final double? height;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  // cleanup 메서드 등록용 콜백
  final void Function(Future<void> Function({String? content}) cleanupHandler)? registerCleanupHandler;

  const QuillEditorField({
    super.key,
    this.initialContent,
    this.hintText,
    this.height,
    required this.onChanged,
    this.readOnly = false,
    this.registerCleanupHandler,
  });

  @override
  State<QuillEditorField> createState() => _QuillEditorFieldState();
}

class _QuillEditorFieldState extends State<QuillEditorField> {
  late quill.QuillController _controller;
  Timer? _debounceTimer;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  // --- 이미지 업로드 및 임시파일 관리 ---
  final List<String> _uploadedImageUrls = [];
  final supabase = Supabase.instance.client;
  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _initializeController();
    _controller.addListener(_onChanged);
    // cleanup 메서드 등록
    widget.registerCleanupHandler?.call(cleanupUnusedImages);
  }

  void _initializeController() {
    try {
      final document = widget.initialContent != null && widget.initialContent!.isNotEmpty
          ? quill.Document.fromJson(
              List<dynamic>.from(
                jsonDecode(widget.initialContent!) as List,
              ),
            )
          : quill.Document();

      _controller = quill.QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
      _controller.readOnly = widget.readOnly;
    } catch (e) {
      // JSON 파싱 실패 시 빈 문서로 초기화
      _controller = quill.QuillController(
        document: quill.Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _controller.readOnly = widget.readOnly;
    }
  }

  @override
  void didUpdateWidget(covariant QuillEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // readOnly 상태 업데이트
    if (widget.readOnly != oldWidget.readOnly) {
      _controller.readOnly = widget.readOnly;
    }

    // 컨텐츠가 변경된 경우, 컨트롤러 재생성 없이 문서만 업데이트
    if (widget.initialContent != oldWidget.initialContent) {
      _updateDocument();
    }
  }

  void _updateDocument() {
    try {
      final newDocument = widget.initialContent != null && widget.initialContent!.isNotEmpty
          ? quill.Document.fromJson(
              List<dynamic>.from(
                jsonDecode(widget.initialContent!) as List,
              ),
            )
          : quill.Document();

      // 기존 선택 영역 저장
      final currentSelection = _controller.selection;
      
      // 리스너 제거 후 문서 업데이트
      _controller.removeListener(_onChanged);
      _controller.document = newDocument;
      
      // 커서 위치 복원/조정
      final newLength = newDocument.length;
      final newSelection = currentSelection.copyWith(
        baseOffset: currentSelection.baseOffset.clamp(0, newLength - 1),
        extentOffset: currentSelection.extentOffset.clamp(0, newLength - 1),
      );

      // 복원된 selection이 유효한 경우에만 업데이트
      if (newSelection.isValid && newSelection.isNormalized) {
        _controller.updateSelection(newSelection, quill.ChangeSource.local);
      } else {
        // 유효하지 않으면 문서 끝으로 커서 이동
        _controller.updateSelection(
          TextSelection.collapsed(offset: newLength - 1),
          quill.ChangeSource.local,
        );
      }
      
      // 리스너 재등록
      _controller.addListener(_onChanged);
    } catch (e) {
      // 파싱 실패 시 빈 문서로 설정
      _controller.removeListener(_onChanged);
      _controller.document = quill.Document();
      _controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.local,
      );
      _controller.addListener(_onChanged);
    }
  }

  void _onChanged() {
    // 디바운스 적용 (300ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        final delta = _controller.document.toDelta().toJson();
        widget.onChanged(jsonEncode(delta));
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 툴바 (readOnly가 아닐 때만 표시)
        if (!widget.readOnly)
          quill.QuillToolbar.simple(
            configurations: quill.QuillSimpleToolbarConfigurations(
              controller: _controller,
              // flutter_quill_extensions의 기본 임베드 버튼들 사용
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              // 커스텀 이미지 업로드 버튼 추가
              customButtons: [
                quill.QuillToolbarCustomButtonOptions(
                  icon: const Icon(Icons.add_photo_alternate),
                  tooltip: '이미지 업로드',
                  onPressed: _showImageUploadDialog,
                ),
              ],
            ),
          ),
        
        // 에디터 영역
        Container(
          height: widget.height ?? 300,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: quill.QuillEditor.basic(
            focusNode: _focusNode,
            scrollController: _scrollController,
            configurations: quill.QuillEditorConfigurations(
              controller: _controller,
              placeholder: widget.hintText ?? '내용을 입력해주세요',
              // 이미지 및 기타 embed 블록 지원
              embedBuilders: kIsWeb
                  ? FlutterQuillEmbeds.editorWebBuilders()
                  : FlutterQuillEmbeds.editorBuilders(),
            ),
          ),
        ),
      ],
    );
  }

  // 이미지 업로드 다이얼로그 표시
  Future<void> _showImageUploadDialog() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    
    if (file != null) {
      try {
        final bytes = await file.readAsBytes();
        final url = await _onImageUploadToSupabase(bytes, file.name);
        
        if (url != null) {
          // 현재 커서 위치에 이미지 삽입
          final index = _controller.selection.baseOffset;
          _controller.document.insert(index, quill.BlockEmbed.image(url));
          
          // 커서를 이미지 다음으로 이동
          _controller.updateSelection(
            TextSelection.collapsed(offset: index + 1),
            quill.ChangeSource.local,
          );
        } else {
          // 업로드 실패 알림
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
            );
          }
        }
      } catch (e) {
        debugPrint('이미지 선택 및 업로드 실패: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다.')),
          );
        }
      }
    }
  }

  // 이미지 업로드 핸들러
  Future<String?> _onImageUploadToSupabase(Uint8List fileBytes, String fileName, {String? mimeType, String? userId, String? unionId}) async {
    try {
      final storagePath = 'post-upload/temp/${uuid.v4()}_$fileName';
      await supabase.storage
          .from('post-upload')
          .uploadBinary(storagePath, fileBytes);
      final publicUrl =
          supabase.storage.from('post-upload').getPublicUrl(storagePath);
      _uploadedImageUrls.add(publicUrl);
      // attachments 테이블에 임시 레코드 생성 (target_id는 null)
      await supabase.from('attachments').insert({
        'union_id': unionId ?? '',
        'target_table': 'posts',
        'target_id': null,
        'file_url': publicUrl,
        'file_name': fileName,
        'file_type': mimeType,
        'uploaded_by': userId ?? '',
      });
      return publicUrl;
    } catch (e) {
      debugPrint('이미지 업로드 실패: $e');
      return null;
    }
  }

  // cleanup: content 내에 없는 이미지는 Storage/attachments에서 삭제
  Future<void> cleanupUnusedImages({String? content}) async {
    final usedUrls =
        content != null ? _extractImageUrlsFromDelta(content) : <String>[];

    final urlsToDelete =
        _uploadedImageUrls.where((url) => !usedUrls.contains(url)).toList();

    for (final url in urlsToDelete) {
      try {
        final path = extractPathFromUrl(url);
        if (path.isNotEmpty) {
          await supabase.storage.from('post-upload').remove([path]);
          await supabase.from('attachments').delete().eq('file_url', url);
        }
      } catch (e) {
        debugPrint('사용하지 않는 이미지 삭제 실패: $url, 오류: $e');
      }
    }
    _uploadedImageUrls.removeWhere((url) => urlsToDelete.contains(url));
  }

  // Delta JSON content에서 이미지 URL 추출
  List<String> _extractImageUrlsFromDelta(String deltaJson) {
    if (deltaJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      return ops
          .where((op) =>
              op is Map<String, dynamic> &&
              op['insert'] is Map<String, dynamic> &&
              op['insert']['image'] is String)
          .map((op) => op['insert']['image'] as String)
          .toList();
    } catch (e) {
      debugPrint('Delta JSON에서 이미지 URL 추출 실패: $e');
      return [];
    }
  }

  // public URL에서 storage 내부 경로 추출
  String extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      const bucketName = 'post-upload';
      final bucketIndex = pathSegments.indexOf(bucketName);

      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
    } catch (e) {
      debugPrint('URL 경로 추출 실패: $e');
    }
    return '';
  }
}

// 사용 예시를 위한 데모 페이지
class QuillEditorDemo extends StatefulWidget {
  const QuillEditorDemo({super.key});

  @override
  State<QuillEditorDemo> createState() => _QuillEditorDemoState();
}

class _QuillEditorDemoState extends State<QuillEditorDemo> {
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quill 에디터'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: QuillEditorField(
                hintText: '여기에 내용을 입력하세요...',
                height: 400,
                onChanged: (content) {
                  setState(() {
                    _content = content;
                  });
                  print('Content changed: ${content.length} characters');
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delta JSON 미리보기:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _content.isEmpty ? '(내용 없음)' : _content,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 