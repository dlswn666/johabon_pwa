import 'package:flutter/material.dart';
// AppTheme 사용을 위해 추가 (필요시)

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      color: Colors.grey.shade900,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '재개발조합',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '미아동 791-2882일대 신속통합 재개발 정비사업',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 미아동 791-2882일대 신속통합 재개발 정비사업조합. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '주소',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '서울특별시 인수봉로 6길',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '연락처',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '전화: 032-123-4567\n이메일: info@jakhyun.org',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '약관 및 정책',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Wanted Sans',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이용약관', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('개인정보처리방침', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('이메일무단수집거부', style: TextStyle(fontFamily: 'Wanted Sans')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 