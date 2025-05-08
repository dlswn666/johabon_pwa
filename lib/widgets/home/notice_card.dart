import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/routes.dart';
import 'package:johabon_pwa/config/theme.dart';
import 'package:johabon_pwa/models/notice_model.dart';
import 'package:intl/intl.dart';

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;

  const NoticeCard({
    Key? key,
    required this.notice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: 공지사항 상세 페이지로 이동
          Navigator.pushNamed(context, AppRoutes.notice);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 및 중요 표시
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notice.isImportant) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '중요',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 공지 내용
              Text(
                notice.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // 하단 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 작성자 정보
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: AppTheme.textTertiaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notice.authorName ?? '관리자',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // 날짜 정보
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppTheme.textTertiaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(notice.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // 첨부파일 여부
                  if (notice.attachmentUrl != null) ...[
                    const Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          size: 16,
                          color: AppTheme.textTertiaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '첨부파일',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 