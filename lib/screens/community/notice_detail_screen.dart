import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;

class NoticeDetailScreen extends StatefulWidget {
  final String noticeId;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
  });

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _noticeData;
  List<Map<String, dynamic>> _attachments = [];
  bool _canEditOrDelete = false; // 권한 상태 변수
  String _plainTextContent = ''; // 일반 텍스트로 변환된 내용을 저장
  bool _isModified = false; // 수정되었는지 여부를 추적
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchNoticeDetails();
  }

  Future<void> _fetchNoticeDetails() async {
    try {
      // 1. Fetch post data
      final postResponse = await _supabase
          .from('posts')
          .select()
          .eq('id', widget.noticeId)
          .single();

      // 2. Fetch attachments
      final attachmentResponse = await _supabase
          .from('attachments')
          .select()
          .eq('target_table', 'posts')
          .eq('target_id', widget.noticeId);

      _checkPermissions(postResponse);

      setState(() {
        _noticeData = postResponse;
        _attachments = List<Map<String, dynamic>>.from(attachmentResponse);

        if (_noticeData != null && _noticeData!['content'] != null) {
          _plainTextContent = _deltaToPlainText(_noticeData!['content']);
        } else {
          _plainTextContent = '내용이 없습니다.';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notice details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항을 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _deltaToPlainText(String deltaJson) {
    try {
      final List<dynamic> delta = jsonDecode(deltaJson);
      final buffer = StringBuffer();
      for (var op in delta) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert']);
        }
      }
      return buffer.toString().replaceAll('\\n', '\n'); // 줄바꿈 처리
    } catch (e) {
      // 파싱 실패 시 원본 텍스트 반환 (HTML 등 비-델타 형식일 경우)
      return deltaJson;
    }
  }

  void _checkPermissions(Map<String, dynamic> postData) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      setState(() => _canEditOrDelete = false);
      return;
    }

    final postAuthor = postData['created_by'];
    final userType = currentUser.userType;
    final userName = currentUser.name;

    final isAdmin = userType == 'admin' || userType == 'systemadmin';
    final isAuthor = postAuthor == userName;

    setState(() {
      _canEditOrDelete = isAdmin || isAuthor;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 수정되었는지 여부를 전달
        Navigator.of(context).pop(_isModified);
        return false; // 기본 뒤로가기 동작 방지
      },
      child: ContentLayoutTemplate(
        title: '공지사항',
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_noticeData == null) {
      return const Center(child: Text('공지사항을 불러올 수 없습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _noticeData!['title'],
            style: const TextStyle(
              fontFamily: 'Wanted Sans',
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Meta info (Author, Date)
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _noticeData!['created_by'],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _noticeData!['created_at'].toString().substring(0, 10),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 24),

          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _plainTextContent,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
          
          // Attachments
          if (_attachments.isNotEmpty)
            _buildAttachmentsSection(),
          
          const Divider(),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    final attachments = _attachments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '첨부파일',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final attachment = attachments[index];
            return ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(attachment['file_name']),
              onTap: () => _downloadFileWithSignedUrl(attachment),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Signed URL을 사용하여 파일을 다운로드하는 메서드
  Future<void> _downloadFileWithSignedUrl(Map<String, dynamic> attachment) async {
    final url = attachment['file_url'] as String?;
    final fileName = attachment['file_name'] as String?;

    if (url == null || fileName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일 정보가 올바르지 않습니다.')),
        );
      }
      return;
    }

    try {
      // 로딩 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('파일을 준비 중입니다...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Storage 경로 추출
      final storagePath = _extractStoragePathFromUrl(url);
      print('[다운로드] 원본 URL: $url');
      print('[다운로드] 추출된 Storage 경로: $storagePath');

      if (storagePath.isEmpty) {
        throw Exception('파일 경로를 찾을 수 없습니다.');
      }

      // Signed URL 생성 (1시간 유효)
      final signedUrl = await _supabase.storage
          .from('post-upload')
          .createSignedUrl(storagePath, 3600); // 1시간 = 3600초

      print('[다운로드] Signed URL 생성 완료: $signedUrl');

      // 다운로드용 URL 생성 (파일명 지정)
      final downloadUrl = '$signedUrl${signedUrl.contains('?') ? '&' : '?'}download=$fileName';
      print('[다운로드] 최종 다운로드 URL: $downloadUrl');

      // 웹에서 다운로드 실행
      if (kIsWeb) {
        html.window.open(downloadUrl, '_blank');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$fileName 다운로드를 시작합니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 모바일 환경 (추후 구현 가능)
        throw UnsupportedError('모바일 다운로드는 아직 지원되지 않습니다.');
      }

    } catch (e) {
      print('[다운로드] 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 다운로드 실패: ${_getErrorMessage(e)}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Storage URL에서 실제 파일 경로를 추출하는 메서드
  String _extractStoragePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // URL 형태: https://project.supabase.co/storage/v1/object/public/post-upload/path/to/file
      final bucketIndex = pathSegments.indexOf('post-upload');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      
      // 다른 형태의 URL 처리
      if (pathSegments.contains('object')) {
        final objectIndex = pathSegments.indexOf('object');
        // object/public/bucket-name/path 또는 object/authenticated/bucket-name/path
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

  /// 사용자 친화적인 오류 메시지 생성
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('bucket not found')) {
      return '파일 저장소를 찾을 수 없습니다.';
    } else if (errorStr.contains('object not found') || errorStr.contains('not found')) {
      return '파일을 찾을 수 없습니다.';
    } else if (errorStr.contains('unauthorized') || errorStr.contains('permission')) {
      return '파일에 접근할 권한이 없습니다.';
    } else if (errorStr.contains('network') || errorStr.contains('connection')) {
      return '네트워크 연결을 확인해주세요.';
    } else if (errorStr.contains('timeout')) {
      return '요청 시간이 초과되었습니다.';
    } else {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  void _navigateToEdit() {
    final unionProvider = Provider.of<UnionProvider>(context, listen: false);
    final slug = unionProvider.currentUnion?.homepage;
    
    if (slug != null) {
      final editRoute = AppRoutes.getFullRoute(slug, AppRoutes.noticeEdit);
      Navigator.of(context).pushNamed(
        editRoute,
        arguments: widget.noticeId,
      ).then((result) {
        // 수정 후 돌아왔을 때 데이터 새로고침
        _fetchNoticeDetails();
        
        // 수정이 완료되었다면 수정 상태를 true로 설정
        if (result == true) {
          _isModified = true;
        }
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말로 이 공지사항을 삭제하시겠습니까?\n삭제된 내용은 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteNotice();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNotice() async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('삭제 중...'),
            ],
          ),
        ),
      );

      // 1. 첨부파일들 먼저 삭제
      final attachmentResponse = await Supabase.instance.client
          .from('attachments')
          .select()
          .eq('target_table', 'posts')
          .eq('target_id', widget.noticeId);

      final attachments = List<Map<String, dynamic>>.from(attachmentResponse);
      
      // Storage에서 첨부파일들 삭제
      for (final attachment in attachments) {
        try {
          final fileUrl = attachment['file_url'] as String;
          final storagePath = _extractStoragePathFromUrl(fileUrl);
          
          if (storagePath.isNotEmpty) {
            await Supabase.instance.client.storage
                .from('post-upload')
                .remove([storagePath]);
          }
        } catch (e) {
          print('[삭제] 첨부파일 삭제 실패: ${attachment['file_name']} - $e');
        }
      }

      // 2. DB에서 첨부파일 레코드들 삭제
      await Supabase.instance.client
          .from('attachments')
          .delete()
          .eq('target_table', 'posts')
          .eq('target_id', widget.noticeId);

      // 3. 게시글 삭제
      await Supabase.instance.client
          .from('posts')
          .delete()
          .eq('id', widget.noticeId);

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공지사항이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 목록으로 돌아가면서 삭제되었음을 알림 (true 반환)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('[삭제] 실패: $e');
      
      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(_isModified),
          child: const Text('목록'),
        ),
        if (_canEditOrDelete) // 권한에 따라 버튼 표시
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _navigateToEdit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('수정'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showDeleteConfirmDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
      ],
    );
  }
} 