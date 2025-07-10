import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:johabon_pwa/providers/auth_provider.dart';
import 'package:johabon_pwa/providers/union_provider.dart';
import 'package:johabon_pwa/widgets/layout/content_layout_template.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:johabon_pwa/services/notice_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:johabon_pwa/widgets/common/ad_banner_widget.dart';
import 'package:johabon_pwa/utils/responsive_layout.dart';

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
  final NoticeService _noticeService = NoticeService();

  @override
  void initState() {
    super.initState();
    _fetchNoticeDetails();
  }

  Future<void> _fetchNoticeDetails() async {
    try {
      final result = await _noticeService.getNoticeDetails(widget.noticeId);
      _checkPermissions(result['noticeData']);

      setState(() {
        _noticeData = result['noticeData'];
        _attachments = result['attachments'];

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
      return buffer.toString().replaceAll('\n', '\n'); // 줄바꿈 처리
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
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // 좌측 광고 배너
    final leftSidebar = Column(
      children: [
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
    final rightSidebar = Column(
      children: [
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_isModified);
        return false;
      },
      child: ContentLayoutTemplate(
        title: '공지사항',
        leftSidebarContent: isDesktop ? leftSidebar : null,
        rightSidebarContent: isDesktop ? rightSidebar : null,
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
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey),
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
          if (_attachments.isNotEmpty) _buildAttachmentsSection(),

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
  Future<void> _downloadFileWithSignedUrl(
      Map<String, dynamic> attachment) async {
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

      // 웹에서 다운로드 실행
      if (kIsWeb) {
        html.window.open(url, '_blank');

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

  /// 사용자 친화적인 오류 메시지 생성
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('bucket not found')) {
      return '파일 저장소를 찾을 수 없습니다.';
    } else if (errorStr.contains('object not found') ||
        errorStr.contains('not found')) {
      return '파일을 찾을 수 없습니다.';
    } else if (errorStr.contains('unauthorized') ||
        errorStr.contains('permission')) {
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

    if (slug != null && _noticeData != null) {
      final editRoute = AppRoutes.getFullRoute(slug, AppRoutes.noticeWrite);
      Navigator.of(context)
          .pushNamed(
        editRoute,
        arguments: {
          'isEdit': true,
          'initialData': _noticeData,
          'attachments': _attachments,
        },
      )
          .then((result) {
        // 수정 후 돌아왔을 때 데이터 새로고침
        _fetchNoticeDetails();
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

      await _noticeService.deleteNotice(widget.noticeId);

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