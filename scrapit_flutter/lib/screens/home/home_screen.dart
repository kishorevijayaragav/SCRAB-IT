import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/pricing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/pricing_provider.dart';
import '../../providers/buyers_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/material_art_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    context.read<HistoryProvider>().loadHistory();
    context.read<InventoryProvider>().loadInventory();
    context.read<PricingProvider>().loadPricing();
    context.read<BuyersProvider>().loadBuyers();
    context.read<NotificationsProvider>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final history = context.watch<HistoryProvider>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'User';

    return Scaffold(
      appBar: ScrapAppBar(
        title: 'Home',
        subtitle: 'Welcome back, $firstName',
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              _buildHeroCard(),
              const SizedBox(height: 24),

              // Quick Access Grid
              _buildSectionTitle(
                title: 'Quick Access',
                subtitle: 'Your most-used tools at a glance.',
              ),
              const SizedBox(height: 12),
              _buildQuickAccessGrid(),
              const SizedBox(height: 24),

              // Live Pricing Section
              _buildLivePricingSection(),
              const SizedBox(height: 24),

              // Recent Activity Strip
              if (history.recentActivity.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(
                      title: 'Recent Activity',
                      subtitle: 'Your latest scans and movements.',
                    ),
                    TextButton(
                      onPressed: () => context.push('/history'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.greenDark,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Row(
                        children: [
                          Text('View All', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Icon(Icons.chevron_right_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildRecentActivityList(history),
                const SizedBox(height: 24),
              ],

              // Why Choose ScrapIt
              _buildSectionTitle(
                title: 'Why Choose Scrapit?',
                subtitle: 'Built around a simple scan-to-value workflow.',
              ),
              const SizedBox(height: 12),
              _buildWhyCard(),
              const SizedBox(height: 24),

              // Scrap Categories
              _buildSectionTitle(
                title: 'Scrap Categories',
                subtitle: 'Materials supported by the AI scanner.',
              ),
              const SizedBox(height: 12),
              _buildCategoriesRow(),
              const SizedBox(height: 24),

              // About ScrapIt Stats
              _buildSectionTitle(
                title: 'About Scrapit',
                subtitle: 'A modern platform for scrap identification and management.',
              ),
              const SizedBox(height: 12),
              _buildAboutCard(),
              const SizedBox(height: 24),

              // CTA Strip
              _buildCtaBanner(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLivePricingSection() {
    final pricingProv = context.watch<PricingProvider>();
    final items = pricingProv.pricing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          title: 'Live Pricing',
          subtitle: 'Market scrap prices · Chennai',
        ),
        const SizedBox(height: 12),

        // Countdown Banner
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3821), Color(0xFF168A42)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICES UPDATE IN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pricingProv.formattedCountdown,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Price List Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, size: 16, color: AppColors.green),
                  SizedBox(width: 6),
                  Text(
                    'Chennai market estimates',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const Text(
                'Indicative rates per kilogram.',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),

              if (pricingProv.isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppColors.green)),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Pricing unavailable.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) => _buildPriceRow(items[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(PricingModel p) {
    final isUp = p.isUp;
    final trendColor = isUp ? AppColors.success : AppColors.danger;
    final trendArrow = isUp ? '↑' : '↓';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MaterialArtBadge(material: p.material, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.material,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'Updated today',
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${p.pricePerKg.round()} / kg',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$trendArrow ${p.changePercent.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F3821), Color(0xFF168A42)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SCRAPIT',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI-Powered Scrap Management',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan · Identify · Manage · Sell',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Image.asset(
                  'assets/images/logo-mark.png',
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.recycling_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => context.go('/scanner'),
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: const Text('Start Scanning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.greenDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid() {
    final tools = [
      (
        'AI Scanner',
        'Identify scrap',
        Icons.qr_code_scanner_rounded,
        AppColors.greenSoft,
        AppColors.green,
        () => context.go('/scanner'),
      ),
      (
        'Inventory',
        'Manage stock',
        Icons.inventory_2_rounded,
        const Color(0xFFF2F5FA),
        AppColors.info,
        () => context.go('/inventory'),
      ),
      (
        'Buyers',
        'Connect',
        Icons.group_rounded,
        const Color(0xFFFBF4E9),
        AppColors.warning,
        () => context.go('/buyers'),
      ),
      (
        'History',
        'Past activity',
        Icons.history_rounded,
        const Color(0xFFF5F4FA),
        const Color(0xFF6B58A6),
        () => context.push('/history'),
      ),
      (
        'Contact',
        'Support',
        Icons.headset_mic_rounded,
        const Color(0xFFFAEEF2),
        const Color(0xFFB33E64),
        () => context.push('/contact'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: tools.length,
      itemBuilder: (context, i) {
        final (title, subtitle, icon, bg, fg, onTap) = tools[i];
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: fg, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityList(HistoryProvider history) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.recentActivity.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = history.recentActivity[i];
          final label = item.type == 'scan'
              ? 'AI Scan'
              : (item.type == 'transaction' ? 'Transaction' : 'Inventory');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                MaterialArtBadge(material: item.name, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        '$label · ${item.time}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.money(item.value),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenDark,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhyCard() {
    final points = [
      'AI Based Scrap Detection',
      'Accurate Value Estimation',
      'Manage Inventory Easily',
      'Connect With Verified Buyers',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: points.map((p) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  p,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    const cats = [
      ('Aluminium', Color(0xFF8F9AA2)),
      ('Copper', Color(0xFFD99A63)),
      ('Iron', Color(0xFF5A6772)),
      ('Brass', Color(0xFFC2A34C)),
      ('Plastic', Color(0xFF3892D3)),
      ('Paper', Color(0xFF8D8374)),
      ('E-Waste', Color(0xFF3B855B)),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (name, color) = cats[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scrapit helps scrap shop owners, collectors, recyclers and buyers identify materials from a single photo, estimate their market value instantly, keep inventory organised and connect with verified buyers.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatTile('24+', 'Materials'),
              Container(width: 1, height: 32, color: AppColors.line),
              _buildStatTile('94%', 'Accuracy'),
              Container(width: 1, height: 32, color: AppColors.line),
              _buildStatTile('6s', 'Avg. scan'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String stat, String label) {
    return Column(
      children: [
        Text(
          stat,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.greenDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCtaBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greenLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to value scrap?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Capture or pick an image to analyze instantly.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.greenDeep.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go('/scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Scan Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
