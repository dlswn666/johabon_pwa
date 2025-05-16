import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';

class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;

  const MobileHeader({
    super.key,
    required this.scaffoldKey,
    this.title = '미아동 791-2882일대 신속통합 재개발 정비사업',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: SafeArea(
        bottom: false, // SafeArea의 bottom 영역은 사용하지 않음
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                  fontFamily: 'Wanted Sans',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.textPrimaryColor),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 