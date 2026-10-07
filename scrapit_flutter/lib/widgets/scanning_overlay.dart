import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../providers/scan_provider.dart';

class ScanningOverlay extends StatelessWidget {
  final ScanStep currentStep;
  final double progress;
  final String fileName;

  const ScanningOverlay({
    super.key,
    required this.currentStep,
    required this.progress,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Spinner Ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Analyzing scrap…',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.line,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 20),
              // Steps Checklist
              _buildStepItem(ScanStep.scanningImage, 'Scanning image'),
              _buildStepItem(ScanStep.identifyingMaterial, 'Identifying material'),
              _buildStepItem(ScanStep.estimatingQuantity, 'Estimating quantity'),
              _buildStepItem(ScanStep.checkingMarketPrice, 'Checking market price'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(ScanStep step, String title) {
    final isDone = currentStep.index > step.index;
    final isCurrent = currentStep == step;

    Color iconBg;
    Color iconColor;
    Widget iconWidget;

    if (isDone) {
      iconBg = AppColors.greenLight;
      iconColor = AppColors.green;
      iconWidget = Icon(Icons.check_rounded, size: 14, color: iconColor);
    } else if (isCurrent) {
      iconBg = AppColors.green;
      iconColor = Colors.white;
      iconWidget = const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else {
      iconBg = AppColors.line;
      iconColor = AppColors.muted2;
      iconWidget = Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: iconColor,
          shape: BoxShape.circle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w700 : (isDone ? FontWeight.w600 : FontWeight.w500),
              color: isCurrent
                  ? AppColors.ink
                  : (isDone ? AppColors.ink2 : AppColors.muted2),
            ),
          ),
        ],
      ),
    );
  }
}
