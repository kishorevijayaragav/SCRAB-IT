import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/notification_model.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/empty_state_view.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'scan':
        return Icons.qr_code_scanner_rounded;
      case 'box':
        return Icons.inventory_2_outlined;
      case 'tag':
        return Icons.local_offer_outlined;
      case 'users':
        return Icons.group_outlined;
      case 'mail':
        return Icons.mail_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationsProvider>();
    final list = notifProv.notifications;

    return Scaffold(
      appBar: ScrapAppBar(
        title: 'Notifications',
        subtitle: notifProv.hasUnread
            ? '${notifProv.unreadCount} unread alert${notifProv.unreadCount == 1 ? '' : 's'}'
            : 'All caught up',
        showBackButton: true,
      ),
      body: Column(
        children: [
          if (list.isNotEmpty && notifProv.hasUnread)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: notifProv.markAllRead,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark all as read'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.greenDark,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),

          Expanded(
            child: notifProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.green))
                : list.isEmpty
                    ? EmptyStateView(
                        title: 'No notifications yet',
                        message: 'Alerts and updates about your scrap will show here.',
                        actionLabel: 'Refresh',
                        onAction: notifProv.loadNotifications,
                      )
                    : RefreshIndicator(
                        onRefresh: notifProv.loadNotifications,
                        color: AppColors.green,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            return _buildNotificationItem(context, list[i]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel n) {
    final isUnread = !n.read;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isUnread) {
            context.read<NotificationsProvider>().markRead(n.id);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? AppColors.greenLight.withValues(alpha: 0.4) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? AppColors.greenLine : AppColors.line,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnread ? AppColors.greenLight : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(n.icon),
                  color: isUnread ? AppColors.greenDark : AppColors.muted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.relativeTime(n.ts),
                          style: const TextStyle(fontSize: 10.5, color: AppColors.muted2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
