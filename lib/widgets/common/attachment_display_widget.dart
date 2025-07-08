import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class AttachmentDisplayWidget extends StatefulWidget {
  final String targetTable;
  final String targetId;
  
  const AttachmentDisplayWidget({
    super.key,
    required this.targetTable,
    required this.targetId,
  });

  @override
  State<AttachmentDisplayWidget> createState() => _AttachmentDisplayWidgetState();
}

class _AttachmentDisplayWidgetState extends State<AttachmentDisplayWidget> {
  List<Map<String, dynamic>> _attachments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    try {
      final response = await Supabase.instance.client
          .from('attachments')
          .select('*')
          .eq('target_table', widget.targetTable)
          .eq('target_id', widget.targetId);
      
      setState(() {
        _attachments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('첨부파일 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(Map<String, dynamic> attachment) async {
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
      final signedUrl = await Supabase.instance.client.storage
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

  String _getFileSize(Map<String, dynamic> attachment) {
    final fileSize = attachment['file_size'];
    if (fileSize == null) return '알 수 없음';
    
    final bytes = fileSize as int;
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

  Icon _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'ppt':
      case 'pptx':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.purple);
      case 'txt':
        return const Icon(Icons.text_snippet, color: Colors.grey);
      default:
        return const Icon(Icons.attach_file, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '첨부파일',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF41505D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: _attachments.map((attachment) {
              final fileName = attachment['file_name'] as String;
              final fileSize = _getFileSize(attachment);
              
              return ListTile(
                leading: _getFileIcon(fileName),
                title: Text(
                  fileName,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '크기: $fileSize',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadFile(attachment),
                  tooltip: '다운로드',
                ),
                onTap: () => _downloadFile(attachment),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 