import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';    
import 'dart:convert';
import 'dart:async';

class QuillEditorField extends StatefulWidget {
  final String? initialContent; // Delta JSON string
  final String? hintText;
  final double? height;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  const QuillEditorField({
    super.key,
    this.initialContent,
    this.hintText,
    this.height,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<QuillEditorField> createState() => _QuillEditorFieldState();
}

class _QuillEditorFieldState extends State<QuillEditorField> {
  late quill.QuillController _controller;
  Timer? _debounceTimer;
  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _initializeController();
    _controller.addListener(_onChanged);
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
      
      // 커서 위치 유지 (문서 길이 체크)
      final newLength = newDocument.length;
      if (currentSelection.baseOffset <= newLength) {
        _controller.updateSelection(currentSelection, quill.ChangeSource.local);
      } else {
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
              // 이미지 삽입 버튼 포함
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
            ),
          ),
        
        // 에디터 영역
        Container(
          height: widget.height ?? 300,
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