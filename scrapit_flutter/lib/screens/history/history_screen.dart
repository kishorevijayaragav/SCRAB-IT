import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/history_item.dart';
import '../../providers/history_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/material_art_badge.dart';
import '../../widgets/empty_state_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final groups = history.groupedItemsForSelectedTab;

    return Scaffold(
      appBar: const ScrapAppBar(
        title: 'History',
        subtitle: 'Your scans, inventory additions and transactions',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Segmented Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Scans', history)),
                  Expanded(child: _buildTab('Inventory', history)),
                  Expanded(child: _buildTab('Transactions', history)),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Content / Empty state
          Expanded(
            child: history.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : groups.isEmpty
                    ? EmptyStateView(
                        title: 'Nothing here yet',
                        message: 'Your ${history.selectedTab.toLowerCase()} will appear here.',
                        actionLabel: 'Refresh',
                        onAction: history.loadHistory,
                      )
                    : RefreshIndicator(
                        onRefresh: history.loadHistory,
                        color: AppColors.green,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: groups.length,
                          itemBuilder: (context, i) {
                            final groupKey = groups.keys.elementAt(i);
                            final items = groups[groupKey]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                                  child: Text(
                                    groupKey,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.line),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: items.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1),
                                    itemBuilder: (context, j) => _buildHistoryItem(items[j]),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String tab, HistoryProvider history) {
    final isSelected = history.selectedTab == tab;
    return GestureDetector(
      onTap: () => history.setSelectedTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            tab,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.greenDark : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem it) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          MaterialArtBadge(material: it.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${it.group} · ${it.time}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.money(it.value),
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              Text(
                Formatters.kg(it.qty),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
