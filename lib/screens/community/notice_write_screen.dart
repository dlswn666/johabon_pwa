import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';
import 'package:johabon_pwa/widgets/common/ad_banner_widget.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:johabon_pwa/widgets/common/custom_grid_form.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoticeWriteScreen extends StatefulWidget {
  const NoticeWriteScreen({super.key});

  @override
  State<NoticeWriteScreen> createState() => _NoticeWriteScreenState();
}

class _NoticeWriteScreenState extends State<NoticeWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final HtmlEditorController _contentController = HtmlEditorController();
  late DropzoneViewController _dropzoneController;
  
  // 상태 변수
  bool _isNotice = false;
  bool _isPinned = false;
  bool _isPrivate = false;
  List<PlatformFile> _pickedFiles = [];
  List<Map<String, dynamic>> _droppedFiles = [];

  // --- 추가: 카테고리 옵션 및 선택값 상태 ---
  List<DropdownOption> _subcategoryOptions = [];
  dynamic _selectedSubcategory;
  Map<String, dynamic> _formValues = {};

  // --- 추가: QuillEditorField cleanup 핸들러 ---
  late Future<void> Function({String? content}) cleanupEditorImages;

  @override
  void initState() {
    super.initState();
    _fetchSubcategories();
  }

  Future<void> _fetchSubcategories() async {
    final response = await Supabase.instance.client
        .from('post_subcategories')
        .select('id, name')
        .eq('category', 'notice');
    setState(() {
      _subcategoryOptions = (response as List)
          .map((e) => DropdownOption(label: e['name'], value: e['id']))
          .toList();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 파일 선택 처리
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 선택 오류: $e')),
      );
    }
  }

  // 파일 드롭존 초기화
  void _onDropzoneCreated(DropzoneViewController controller) {
    _dropzoneController = controller;
  }

  // 파일 드랍 처리
  Future<void> _onFileDrop(dynamic event) async {
    final name = await _dropzoneController.getFilename(event);
    final mime = await _dropzoneController.getFileMIME(event);
    final size = await _dropzoneController.getFileSize(event);
    final url = await _dropzoneController.createFileUrl(event);
    
    setState(() {
      _droppedFiles.add({
        'name': name,
        'mime': mime,
        'size': size,
        'url': url,
        'event': event,
      });
    });
  }

  // 파일 삭제
  void _removePickedFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  void _removeDroppedFile(int index) {
    setState(() {
      _droppedFiles.removeAt(index);
    });
  }

  // 게시글 저장
  Future<void> _savePost() async {
    final title = _titleController.text;
    final content = await _contentController.getText();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요')),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요')),
      );
      return;
    }

    // 글 저장 전: 에디터 이미지 cleanup (content 내에 없는 이미지는 삭제)
    if (cleanupEditorImages != null) {
      await cleanupEditorImages(content: content);
    }

    // TODO: 서버에 데이터 저장 구현
    print('제목: $title');
    print('내용: $content');
    print('공지: $_isNotice');
    print('상단고정: $_isPinned');
    print('나만보기: $_isPrivate');
    print('첨부파일 수: ${_pickedFiles.length + _droppedFiles.length}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글이 저장되었습니다')),
    );
    
    Navigator.pop(context);
  }

  // 임시저장
  Future<void> _saveTemp() async {
    final title = _titleController.text;
    final content = await _contentController.getText();
    
    // 글 임시저장 전: 에디터 이미지 cleanup (content 내에 없는 이미지는 삭제)
    if (cleanupEditorImages != null) {
      await cleanupEditorImages(content: content);
    }

    // TODO: 임시저장 기능 구현
    print('임시저장 - 제목: $title');
    print('임시저장 - 내용: $content');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('임시저장되었습니다')),
    );
  }

  // 임시저장 불러오기
  void _loadTemp() {
    // TODO: 임시저장 불러오기 구현
    _titleController.text = "임시 저장된 제목";
    _contentController.setText("<p>임시 저장된 내용입니다.</p>");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('임시저장된 글을 불러왔습니다')),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('광고 문의: 02-123-1234')),
            );
          },
        ),
      ],
    );

    return ContentLayoutTemplate(
      title: '글 작성하기',
      leftSidebarContent: leftSidebar,
      rightSidebarContent: rightSidebar,
      body: _buildWriteForm(context),
    );
  }

  Widget _buildWriteForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 12),

          // 게시판 표시
          const Text(
            '공지사항',
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF41505D),
            ),
          ),
          const SizedBox(height: 8),
          
          // 글 작성 제목
          const Text(
            '글 작성하기',
            style: TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF41505D),
            ),
          ),
          
          
          const SizedBox(height: 24),

          CustomGroupedForm(
            formValues: _formValues,
            onChanged: (key, value) {
              setState(() {
                _formValues[key] = value;
                if (key == 'subcategory') {
                  _selectedSubcategory = value;
                }
              });
            },
            groups: [
              FormFieldGroup(
                columnCount: 1,
                fields: [
                  FormFieldConfig(
                    keyName: 'title',
                    label: '제목',
                    type: FormFieldType.input,
                  )
                ]
              ),
              FormFieldGroup(
                columnCount: 2,
                fields: [
                  FormFieldConfig(
                    keyName: 'subcategory',
                    label: '카테고리',
                    type: FormFieldType.dropdown,
                    options: _subcategoryOptions,
                  ),
                  FormFieldConfig(
                    keyName: 'isAlimTalk',
                    label: '알림톡 발송',
                    type: FormFieldType.checkbox,
                    value: false,
                  ),
                ],
              ),
              FormFieldGroup(
                columnCount: 1,
                fields: [
                  FormFieldConfig(
                    keyName: 'attachFile',
                    label: '첨부파일',
                    type: FormFieldType.attachment,
                  ),
                  FormFieldConfig(
                    keyName: 'content',
                    label: '내용',
                    type: FormFieldType.quillEditor,
                    registerCleanupHandler: (cleanup) {
                      cleanupEditorImages = cleanup;
                    },
                  ),
                ],
              ),
            ],
          ),
          
          
          
          const SizedBox(height: 32),
          
          // 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 임시저장 버튼
              OutlinedButton(
                onPressed: _saveTemp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF41505D),
                  side: const BorderSide(
                    color: Color(0xFFA8B4BE),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '임시저장',
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 불러오기 버튼
              OutlinedButton(
                onPressed: _loadTemp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF41505D).withOpacity(0.4),
                  side: BorderSide(
                    color: const Color(0xFFA8B4BE).withOpacity(0.4),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '불러오기',
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 등록하기 버튼
              ElevatedButton(
                onPressed: _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75D49B),
                  foregroundColor: const Color(0xFF22675F),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '등록하기',
                  style: TextStyle(
                    fontFamily: 'Wanted Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF75D49B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Wanted Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF41505D),
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(String name, String size, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.insert_drive_file,
            color: Color(0xFF41505D),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Wanted Sans',
                fontSize: 14,
                color: Color(0xFF41505D),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            size,
            style: const TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 12,
              color: Color(0xFF8C8C8C),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF8C8C8C),
            ),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
            padding: EdgeInsets.zero,
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
  
} 