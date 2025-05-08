import 'package:flutter/material.dart';
import 'package:johabon_pwa/config/theme.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double? width;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 50,
    this.width,
    this.icon,
    this.borderRadius = 12,
    this.padding,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton();
      case ButtonType.secondary:
        return _buildSecondaryButton();
      case ButtonType.outline:
        return _buildOutlineButton();
      case ButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.secondaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildOutlineButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppTheme.primaryColor,
          side: BorderSide(
            color: backgroundColor ?? AppTheme.primaryColor,
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildTextButton() {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppTheme.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildButtonContent(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildButtonContent(Color defaultIconColor) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: type == ButtonType.primary || type == ButtonType.secondary
                ? Colors.white
                : defaultIconColor,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: type == ButtonType.primary || type == ButtonType.secondary
                  ? Colors.white
                  : defaultIconColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
} 