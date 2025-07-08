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
import 'package:provider/provider.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:johabon_pwa/widgets/common/attachment_field.dart';

class NoticeWriteScreen extends StatefulWidget {
  const NoticeWriteScreen({super.key});

  @override
  State<NoticeWriteScreen> createState() => _NoticeWriteScreenState();
}

class _NoticeWriteScreenState extends State<NoticeWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final HtmlEditorController _contentController = HtmlEditorController();
  
  // 상태 변수
  bool _isNotice = false;
  bool _isPinned = false;
  bool _isPrivate = false;
  List<PlatformFile> _pickedFiles = [];
  List<Map<String, dynamic>> _droppedFiles = [];
  // 삭제 예약된 기존 첨부파일 리스트
  List<Map<String, dynamic>> _attachmentsToDelete = [];

  // --- 추가: 카테고리 옵션 및 선택값 상태 ---
  List<DropdownOption> _subcategoryOptions = [];
  dynamic _selectedSubcategory;
  Map<String, dynamic> _formValues = {};
  bool _isLoadingCategories = true;

  // --- 추가: QuillEditorField cleanup 핸들러 ---
  late Future<void> Function({String? content}) cleanupEditorImages;
  final uuid = Uuid();

  bool _isEdit = false;
  Map<String, dynamic>? _initialData;
  List<Map<String, dynamic>> _initialAttachments = [];
  bool _didInitFromArgs = false;

  @override
  void initState() {
    super.initState();
    _fetchSubcategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _isEdit = args['isEdit'] == true;
        _initialData = args['initialData'] as Map<String, dynamic>?;
        // _initialAttachments는 DB에서 조회로 대체
        if (_isEdit && _initialData != null) {
          // 제목, 내용, 카테고리 등 폼 값 세팅
          _formValues['title'] = _initialData!['title'] ?? '';
          _formValues['content'] = _initialData!['content'] ?? '';
          _formValues['subcategory'] = _initialData!['subcategory_id'] ?? '';
          _titleController.text = _initialData!['title'] ?? '';
          _contentController.setText(_initialData!['content'] ?? '');
          // 첨부파일 목록 DB에서 조회
          final postId = _initialData!['id'];
          if (postId != null) {
            _fetchAttachments(postId);
          }
        }
      }
      _didInitFromArgs = true;
    }
  }

  Future<void> _fetchSubcategories() async {
    try {
      print('[NoticeWriteScreen] 카테고리 로딩 시작');
      
      // 먼저 'notice' 카테고리의 ID를 찾기
      final categoryResponse = await Supabase.instance.client
          .from('post_categories')
          .select('id')
          .eq('key', 'notice')
          .single();
      
      if (categoryResponse != null && categoryResponse['id'] != null) {
        final categoryId = categoryResponse['id'];
        
        // 해당 카테고리의 서브카테고리들 가져오기
        final response = await Supabase.instance.client
            .from('post_subcategories')
            .select('id, name')
            .eq('category_id', categoryId);
        
        print('[NoticeWriteScreen] 카테고리 응답: $response');
        
        if (response != null && response is List && response.isNotEmpty) {
          setState(() {
            _subcategoryOptions = response
                .map((e) => DropdownOption(label: e['name'], value: e['id']))
                .toList();
            _isLoadingCategories = false;
          });
          print('[NoticeWriteScreen] 카테고리 옵션 설정 완료: ${_subcategoryOptions.length}개');
        } else {
          print('[NoticeWriteScreen] 서브카테고리 데이터가 없습니다.');
          _setDefaultCategories();
        }
      } else {
        print('[NoticeWriteScreen] notice 카테고리가 없습니다.');
        _setDefaultCategories();
      }
    } catch (e) {
      print('[NoticeWriteScreen] 카테고리 로딩 실패: $e');
      _setDefaultCategories();
      
      // 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카테고리 로딩 실패: 기본 옵션으로 설정됩니다')),
        );
      }
    }
  }

  void _setDefaultCategories() {
    setState(() {
      _subcategoryOptions = [
        DropdownOption(label: '일반 공지', value: 'default'),
        DropdownOption(label: '긴급 공지', value: 'urgent'),
        DropdownOption(label: '안내사항', value: 'info'),
      ];
      _isLoadingCategories = false;
    });
  }

  // 첨부파일 목록을 DB에서 조회하는 함수
  Future<void> _fetchAttachments(String postId) async {
    try {
      final response = await Supabase.instance.client
          .from('attachments')
          .select('*')
          .eq('target_table', 'posts')
          .eq('target_id', postId)
          .order('uploaded_at');
      if (response != null && response is List) {
        setState(() {
          _initialAttachments = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('첨부파일 목록 조회 오류: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }



  // 게시글 저장
  Future<void> _savePost() async {
    // 폼 데이터 가져오기
    final title = _formValues['title']?.toString() ?? '';
    final subcategoryId = _formValues['subcategory'];
    final isAlimTalk = _formValues['isAlimTalk'] ?? false;
    final content = _formValues['content']?.toString() ?? '';
    
    // 유효성 검사
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

    if (subcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }

    // 로딩 시작
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      // 현재 사용자 및 조합 정보 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final unionProvider = Provider.of<UnionProvider>(context, listen: false);
      
      if (authProvider.currentUser == null) {
        throw Exception('로그인 정보가 없습니다.');
      }
      
      if (unionProvider.currentUnion == null) {
        throw Exception('조합 정보가 없습니다.');
      }

      // 'notice' 카테고리 ID 찾기
      final categoryResponse = await Supabase.instance.client
          .from('post_categories')
          .select('id')
          .eq('key', 'notice')
          .single();
      
      if (categoryResponse == null || categoryResponse['id'] == null) {
        throw Exception('공지사항 카테고리를 찾을 수 없습니다.');
      }
      
      final categoryId = categoryResponse['id'];

      // 게시글 데이터 준비
      final postData = {
        'union_id': unionProvider.currentUnion!.id,
        'title': title,
        'content': content,
        'category_id': categoryId,
        'subcategory_id': subcategoryId,
        'popup': false, // 팝업 표시 여부
        'created_by': authProvider.currentUser!.name ?? 'Unknown', // 사용자 이름 (text 타입)
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 게시글 저장
      final response = await Supabase.instance.client
          .from('posts')
          .insert(postData)
          .select()
          .single();

      final postId = response['id'];
      
      // 첨부파일 처리 (새로 추가된 파일만 업로드)
      await _handleAttachments(postId);

      // 글 저장 후: 에디터 이미지 cleanup (content 내에 없는 이미지는 삭제)
      if (cleanupEditorImages != null) {
        await cleanupEditorImages(content: content);
      }

      // 로딩 종료
      Navigator.of(context).pop();

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 저장되었습니다')),
      );
      
      // 게시글 목록으로 이동 (저장 성공 결과 전달)
      Navigator.pop(context, true);
      
    } catch (e) {
      // 로딩 종료
      Navigator.of(context).pop();
      
      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 저장 중 오류가 발생했습니다: ${e.toString()}')),
      );
      
      print('게시글 저장 오류: $e');
    }
  }



  // 첨부파일 처리
  Future<void> _handleAttachments(String postId) async {
    print('[첨부파일] 처리 시작 - postId: $postId');
    print('[첨부파일] _pickedFiles 수: ${_pickedFiles.length}');
    print('[첨부파일] _droppedFiles 수: ${_droppedFiles.length}');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
    
    // FilePicker로 선택된 파일들 업로드
    for (final file in _pickedFiles) {
      try {
        print('[첨부파일] 파일 처리 시작: ${file.name}');
        
        if (file.bytes != null) {
          print('[첨부파일] 파일 바이트 존재: ${file.bytes!.length} bytes');
          
          final originalFileName = file.name;
          final fileExtension = originalFileName.contains('.') 
              ? originalFileName.substring(originalFileName.lastIndexOf('.'))
              : '';
          final attachmentId = uuid.v4(); // DB ID와 파일명에 동일한 UUID 사용
          final uniqueFileName = '$attachmentId$fileExtension';
          final storagePath = 'posts/$postId/$uniqueFileName';
          
          print('[첨부파일] 원본 파일명: $originalFileName');
          print('[첨부파일] 고유 ID: $attachmentId');
          print('[첨부파일] 고유 파일명: $uniqueFileName');
          print('[첨부파일] 스토리지 경로: $storagePath');
          
          // Storage에 업로드
          await Supabase.instance.client.storage
              .from('post-upload')
              .uploadBinary(storagePath, file.bytes!);
          
          print('[첨부파일] 스토리지 업로드 완료');
          
          // 공개 URL 생성
          final publicUrl = Supabase.instance.client.storage
              .from('post-upload')
              .getPublicUrl(storagePath);
          
          print('[첨부파일] 공개 URL: $publicUrl');
          
          // attachments 테이블에 정보 저장 (파일명과 동일한 UUID 사용)
          final attachmentData = {
            'id': attachmentId, // 파일명과 동일한 UUID 사용
            'union_id': unionProvider.currentUnion!.id,
            'target_table': 'posts',
            'target_id': postId,
            'file_url': publicUrl,
            'file_name': originalFileName,
            'file_type': fileExtension.isNotEmpty ? fileExtension.substring(1) : null,
            'file_size': file.bytes!.length,
            'uploaded_by': authProvider.currentUser!.id,
            'uploaded_at': DateTime.now().toIso8601String(),
          };
          
          print('[첨부파일] 첨부파일 데이터: $attachmentData');
          
          await Supabase.instance.client.from('attachments').insert(attachmentData);
          
          print('[첨부파일] DB 삽입 완료: ${file.name}');
        } else {
          print('[첨부파일] 파일 바이트가 null: ${file.name}');
        }
      } catch (e) {
        print('[첨부파일] 업로드 오류: ${file.name} - $e');
        // 개별 파일 실패는 전체 저장을 중단하지 않음
      }
    }
    
    // 드래그&드롭된 파일들 업로드
    for (final fileInfo in _droppedFiles) {
      try {
        print('[첨부파일] 드래그앤드롭 파일 처리 시작: ${fileInfo['name']}');
        
        final fileName = fileInfo['name'] as String;
        final attachmentId = uuid.v4(); // DB ID와 파일명에 동일한 UUID 사용
        final storagePath = 'posts/$postId/$attachmentId.${fileName.split('.').last}';
        
        print('[첨부파일] 드래그앤드롭 스토리지 경로: $storagePath');
        
        // 드래그앤드롭 파일은 현재 구조상 처리가 복잡하므로 일단 스킵
        // TODO: 드래그앤드롭 파일 처리 구현 필요
        print('[첨부파일] 드래그앤드롭 파일은 현재 지원되지 않습니다: ${fileName}');
        
      } catch (e) {
        print('[첨부파일] 드래그앤드롭 파일 업로드 오류: ${fileInfo['name']} - $e');
        // 개별 파일 실패는 전체 저장을 중단하지 않음
      }
    }
    // 첨부파일 목록 갱신
    await _fetchAttachments(postId);
  }

  // 임시저장
  Future<void> _saveTemp() async {
    // 폼 데이터 가져오기
    final title = _formValues['title']?.toString() ?? '';
    final content = _formValues['content']?.toString() ?? '';
    
    // 글 임시저장 전: 에디터 이미지 cleanup (content 내에 없는 이미지는 삭제)
    if (cleanupEditorImages != null) {
      await cleanupEditorImages(content: content);
    }

    // TODO: 임시저장 기능 구현 (나중에 drafts 테이블에 저장)
    print('임시저장 - 제목: $title');
    print('임시저장 - 내용: $content');
    print('임시저장 - 카테고리: ${_formValues['subcategory']}');
    print('임시저장 - 알림톡: ${_formValues['isAlimTalk']}');
    
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

  // 첨부파일 삭제 함수 (이제 UI에서만 제거, 실제 삭제는 수정 버튼에서)
  Future<void> _deleteAttachment(Map<String, dynamic> attachment) async {
    // UI에서만 제거, 실제 삭제는 수정 버튼에서 처리
    setState(() {
      _initialAttachments.removeWhere((a) => a['id'] == attachment['id']);
      // 중복 추가 방지
      if (!_attachmentsToDelete.any((a) => a['id'] == attachment['id'])) {
        _attachmentsToDelete.add(attachment);
      }
    });
    // 안내 메시지(선택)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수정 시 첨부파일이 삭제됩니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final pageTitle = _isEdit ? '글 수정하기' : '글 작성하기';
    final actionButtonText = _isEdit ? '수정하기' : '등록하기';
    
    // 디버깅: 카테고리 옵션 상태 확인
    print('[NoticeWriteScreen] Build 시점 - 카테고리 옵션 수: ${_subcategoryOptions.length}');
    print('[NoticeWriteScreen] Build 시점 - 카테고리 옵션: ${_subcategoryOptions}');
    
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
      title: pageTitle,
      leftSidebarContent: leftSidebar,
      rightSidebarContent: rightSidebar,
      body: _buildWriteForm(context, actionButtonText),
    );
  }

  Widget _buildWriteForm(BuildContext context, String actionButtonText) {
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
          // 글 작성/수정 제목
          Text(
            _isEdit ? '글 수정하기' : '글 작성하기',
            style: const TextStyle(
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
              print('[NoticeWriteScreen] 폼 값 변경: $key = $value');
              setState(() {
                _formValues[key] = value;
                if (key == 'subcategory') {
                  _selectedSubcategory = value;
                  print('[NoticeWriteScreen] 카테고리 선택됨: $value');
                } else if (key == 'attachFile' && value is List) {
                  // 첨부파일 처리
                  _pickedFiles.clear();
                  _droppedFiles.clear();
                  for (final file in value) {
                    if (file is PlatformFile) {
                      _pickedFiles.add(file);
                    } else if (file is Map<String, dynamic>) {
                      _droppedFiles.add(file);
                    }
                  }
                  print('[첨부파일] _pickedFiles 업데이트: ${_pickedFiles.length}개');
                  print('[첨부파일] _droppedFiles 업데이트: ${_droppedFiles.length}개');
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
                    hintText: _isLoadingCategories ? '카테고리 로딩 중...' : '카테고리를 선택하세요',
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
                    customWidget: AttachmentField(
                      initialAttachments: _initialAttachments,
                      onDeleteAttachment: _deleteAttachment,
                      onChanged: (value) {
                        // 기존 onChanged 로직과 동일하게 처리
                        setState(() {
                          _pickedFiles.clear();
                          _droppedFiles.clear();
                          for (final file in value) {
                            if (file is PlatformFile) {
                              _pickedFiles.add(file);
                            } else if (file is Map<String, dynamic>) {
                              _droppedFiles.add(file);
                            }
                          }
                          print('[첨부파일] _pickedFiles 업데이트: ${_pickedFiles.length}개');
                          print('[첨부파일] _droppedFiles 업데이트: ${_droppedFiles.length}개');
                        });
                      },
                    ),
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
          // 첨부파일 목록 UI를 첨부파일 입력란 바로 아래에 직접 배치
          const SizedBox(height: 32),
          // 버튼 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 임시저장 버튼 (글쓰기 모드에서만)
              if (!_isEdit)
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
              if (!_isEdit) const SizedBox(width: 12),
              // 불러오기 버튼 (글쓰기 모드에서만)
              if (!_isEdit)
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
              if (!_isEdit) const SizedBox(width: 12),
              // 등록/수정 버튼
              ElevatedButton(
                onPressed: _isEdit ? _updatePost : _savePost,
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
                child: Text(
                  actionButtonText,
                  style: const TextStyle(
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

  // 수정 모드일 때 호출될 게시글 업데이트 함수 (구현)
  Future<void> _updatePost() async {
    // 폼 데이터 가져오기
    final title = _formValues['title']?.toString() ?? '';
    final subcategoryId = _formValues['subcategory'];
    final isAlimTalk = _formValues['isAlimTalk'] ?? false;
    final content = _formValues['content']?.toString() ?? '';

    // 유효성 검사
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
    if (subcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }

    // 로딩 시작
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      // 현재 사용자 및 조합 정보 가져오기
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final unionProvider = Provider.of<UnionProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        throw Exception('로그인 정보가 없습니다.');
      }
      if (unionProvider.currentUnion == null) {
        throw Exception('조합 정보가 없습니다.');
      }

      // 수정할 게시글의 ID
      final postId = _initialData?['id'];
      if (postId == null) {
        throw Exception('수정할 게시글 정보를 찾을 수 없습니다.');
      }

      // 'notice' 카테고리 ID 찾기
      final categoryResponse = await Supabase.instance.client
          .from('post_categories')
          .select('id')
          .eq('key', 'notice')
          .single();
      if (categoryResponse == null || categoryResponse['id'] == null) {
        throw Exception('공지사항 카테고리를 찾을 수 없습니다.');
      }
      final categoryId = categoryResponse['id'];

      // 게시글 데이터 준비 (union_id, created_by 등은 변경하지 않음)
      final postData = {
        'title': title,
        'content': content,
        'category_id': categoryId,
        'subcategory_id': subcategoryId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 게시글 업데이트
      await Supabase.instance.client
          .from('posts')
          .update(postData)
          .eq('id', postId);

      // 첨부파일 추가(새로 첨부된 파일만 업로드)
      await _handleAttachments(postId);

      // 에디터 이미지 cleanup (content 내에 없는 이미지는 삭제)
      if (cleanupEditorImages != null) {
        await cleanupEditorImages(content: content);
      }

      // 1. 삭제 예약된 기존 첨부파일 실제 삭제
      for (final attachment in _attachmentsToDelete) {
        try {
          final fileUrl = attachment['file_url'] as String?;
          final id = attachment['id'] as String?;
          if (fileUrl == null || id == null) continue;
          // Storage 경로 추출
          final uri = Uri.parse(fileUrl);
          final segments = uri.pathSegments;
          final storageIndex = segments.indexOf('post-upload');
          if (storageIndex == -1) throw Exception('Storage 경로 파싱 실패');
          final storagePath = segments.sublist(storageIndex + 1).join('/');
          // Storage에서 파일 삭제
          await Supabase.instance.client.storage
            .from('post-upload')
            .remove([storagePath]);
          // attachments 테이블에서 row 삭제
          await Supabase.instance.client
            .from('attachments')
            .delete()
            .eq('id', id);
        } catch (e) {
          print('첨부파일 실제 삭제 오류: $e');
        }
      }
      _attachmentsToDelete.clear();

      // 로딩 종료
      Navigator.of(context).pop();

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 수정되었습니다')),
      );
      // 게시글 목록으로 이동 (수정 성공 결과 전달)
      Navigator.pop(context, true);
    } catch (e) {
      // 로딩 종료
      Navigator.of(context).pop();
      // 에러 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 수정 중 오류가 발생했습니다: ${e.toString()}')),
      );
      print('게시글 수정 오류: $e');
    }
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


  
} 