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
    try {
      final fileUrl = attachment['file_url'] as String;
      final originalFileName = attachment['file_name'] as String;
      
      if (kIsWeb) {
        // 웹에서는 브라우저 다운로드 사용
        html.AnchorElement(href: fileUrl)
          ..setAttribute("download", originalFileName)
          ..click();
      } else {
        // 모바일에서는 url_launcher 등을 사용할 수 있음
        // 여기서는 간단히 URL을 열기만 함
        // url_launcher.launch(fileUrl);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 다운로드 실패: $e')),
        );
      }
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