import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/scan_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/material_art_badge.dart';
import '../../widgets/custom_button.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _isSavingToInventory = false;

  Future<void> _addToInventory() async {
    final scan = context.read<ScanProvider>();
    final result = scan.latestResult;
    if (result == null) return;

    setState(() => _isSavingToInventory = true);

    final inv = context.read<InventoryProvider>();
    final ok = await inv.addItem(
      material: result.material,
      quantity: result.quantity,
      pricePerKg: result.pricePerKg,
      image: result.imageUrl,
      confidence: result.confidence,
    );

    if (!mounted) return;
    setState(() => _isSavingToInventory = false);

    if (ok) {
      context.read<HistoryProvider>().loadHistory();
      context.read<NotificationsProvider>().loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.material} added to inventory!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/inventory');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(inv.errorMessage ?? 'Failed to add item to inventory'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _shareResult() {
    final scan = context.read<ScanProvider>();
    final r = scan.latestResult;
    if (r == null) return;

    final text = 'ScrapIt result: ${r.material} — ${r.quantity} kg · ${Formatters.money(r.estimatedValue)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result: $text'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final r = scan.latestResult;

    if (r == null) {
      return Scaffold(
        appBar: const ScrapAppBar(title: 'Scan Result', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No scan result available'),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Go to Scanner',
                onPressed: () => context.go('/scanner'),
                isBlock: false,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: ScrapAppBar(
        title: 'Scan Result',
        subtitle: 'AI detection summary and estimated value',
        showBackButton: true,
        onBack: () => context.go('/scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banners
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greenLine),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Detection Completed!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenDark,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD3E0EE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.info, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'AI Detection — Demo Mode (prototype)',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Valuation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'MATERIAL DETECTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.muted2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      MaterialArtBadge(material: r.material, size: 56),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.material,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${r.confidence}% confidence',
                                style: const TextStyle(
                                  color: AppColors.greenDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _shareResult,
                        icon: const Icon(Icons.share_outlined),
                        color: AppColors.muted,
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero Estimated Value Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.greenSoft,
                          AppColors.greenLight.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.greenLine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Value',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.money(r.estimatedValue),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.greenDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Indicative market estimate — Chennai',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confidence Bar Metric
                  _buildMetricRow('Confidence', '${r.confidence}%'),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: r.confidence / 100,
                      minHeight: 7,
                      backgroundColor: AppColors.line,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Estimated Quantity
                  _buildMetricRow('Estimated Quantity', Formatters.kg(r.quantity)),
                  const Divider(height: 20),

                  // Price per kg
                  _buildMetricRow('Price per kg', '₹${r.pricePerKg.round()} / kg'),
                  const SizedBox(height: 24),

                  // Actions
                  CustomButton(
                    text: 'Add to Inventory',
                    icon: Icons.add_rounded,
                    isLoading: _isSavingToInventory,
                    onPressed: _addToInventory,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'View Buyers',
                          icon: Icons.group_rounded,
                          isSecondary: true,
                          onPressed: () => context.go('/buyers'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Scan Again',
                          icon: Icons.refresh_rounded,
                          isSecondary: true,
                          onPressed: () {
                            scan.resetResult();
                            context.go('/scanner');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Disclaimer
                  const Text(
                    'Prices may vary by location, material quality and current market conditions. The estimate shown is indicative and based on today\'s Chennai market rates.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
