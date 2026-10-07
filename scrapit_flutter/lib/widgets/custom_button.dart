import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isSecondary;
  final bool isDanger;
  final bool isBlock;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
    this.isDanger = false,
    this.isBlock = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisSize: isBlock ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
          ),
        ],
      ],
    );

    final resolvedPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    if (isSecondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: resolvedPadding,
          foregroundColor: isDanger ? AppColors.danger : AppColors.ink,
          side: BorderSide(
            color: isDanger ? AppColors.danger.withValues(alpha: 0.5) : AppColors.line,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: resolvedPadding,
        backgroundColor: isDanger ? AppColors.danger : AppColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: child,
    );
  }
}
