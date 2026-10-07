import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'custom_button.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.greenLine),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo-mark.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (_, __, ___) => Icon(
                    icon ?? Icons.inbox_rounded,
                    size: 36,
                    color: AppColors.greenDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                text: actionLabel!,
                onPressed: onAction,
                isBlock: false,
                icon: Icons.qr_code_scanner_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
