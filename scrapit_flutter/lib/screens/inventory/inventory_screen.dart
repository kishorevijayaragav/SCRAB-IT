import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/inventory_item.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/material_art_badge.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_inventory_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEditSheet([InventoryItem? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditInventorySheet(
        item: item,
        onSave: ({required material, required quantity, required pricePerKg}) async {
          final inv = context.read<InventoryProvider>();
          bool ok;
          if (item != null) {
            ok = await inv.updateItem(
              item.id,
              material: material,
              quantity: quantity,
              pricePerKg: pricePerKg,
            );
          } else {
            ok = await inv.addItem(
              material: material,
              quantity: quantity,
              pricePerKg: pricePerKg,
            );
          }
          if (ok) {
            context.read<HistoryProvider>().loadHistory();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(item != null ? 'Item updated' : 'Item added to inventory'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          return ok;
        },
      ),
    );
  }

  Future<void> _confirmDelete(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to remove ${item.material} from your inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final inv = context.read<InventoryProvider>();
      final ok = await inv.deleteItem(item.id);
      if (ok) {
        context.read<HistoryProvider>().loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted'),
            backgroundColor: AppColors.ink2,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = context.watch<InventoryProvider>();
    final items = inv.filteredItems;

    return Scaffold(
      appBar: const ScrapAppBar(
        title: 'My Inventory',
        subtitle: 'Search, filter and manage stock',
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: inv.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Search in inventory...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    inv.setSearchQuery('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _openAddEditSheet(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Horizontal category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildChip('All', inv),
                      _buildChip('Metal', inv),
                      _buildChip('Plastic', inv),
                      _buildChip('Paper', inv),
                      _buildChip('E-Waste', inv),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items List / Empty State
          Expanded(
            child: inv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : items.isEmpty
                    ? EmptyStateView(
                        title: 'No scrap in inventory yet',
                        message: 'Scan or add your first item to start managing stock.',
                        actionLabel: 'Start Scanning',
                        onAction: () => context.go('/scanner'),
                      )
                    : RefreshIndicator(
                        onRefresh: inv.loadInventory,
                        color: AppColors.green,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            return _buildInventoryCard(items[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String category, InventoryProvider inv) {
    final isSelected = inv.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) => inv.setCategory(category),
        selectedColor: AppColors.greenLight,
        backgroundColor: Colors.white,
        checkmarkColor: AppColors.greenDark,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.greenDark : AppColors.muted,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.greenLine : AppColors.line,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MaterialArtBadge(material: item.material, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.material,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Formatters.kg(item.quantity)} · ₹${item.pricePerKg.round()} / kg',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.date} · ${item.category}',
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
                Formatters.money(item.estimatedValue),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.greenDark,
                ),
              ),
              const Text(
                'estimated',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _openAddEditSheet(item),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.info,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _confirmDelete(item),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
