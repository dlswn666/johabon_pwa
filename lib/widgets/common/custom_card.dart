import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final double? elevation;
  final double borderRadius;
  final bool hasBorder;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.backgroundColor,
    this.elevation,
    this.borderRadius = 16,
    this.hasBorder = false,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: hasBorder
              ? Border.all(
                  color: borderColor ?? AppTheme.dividerColor,
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(elevation != null ? 0.1 : 0.05),
              blurRadius: elevation ?? 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
} 