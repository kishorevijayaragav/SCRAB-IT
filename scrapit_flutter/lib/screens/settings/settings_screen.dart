import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/scrap_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of ScrapIt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/login');
    }
  }

  void _showServerConfigDialog() {
    final apiService = context.read<ApiService>();
    final settingsProv = context.read<SettingsProvider>();
    final controller = TextEditingController(text: apiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the ScrapIt backend server URL. For Android Emulator use 10.0.2.2, for physical phone use your PC\'s Wi-Fi IP address (e.g. http://192.168.1.100:3000).',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Server Base URL',
                hintText: 'http://10.0.2.2:3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await settingsProv.setCustomBaseUrl(controller.text.trim());
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server URL set to: ${controller.text.trim()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settingsProv = context.watch<SettingsProvider>();
    final user = auth.currentUser;
    final s = settingsProv.settings;
    final notif = s.notifications;
    final pref = s.preferences;

    return Scaffold(
      appBar: const ScrapAppBar(
        title: 'Profile & Settings',
        subtitle: 'Manage your account and preferences',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.greenLine),
                    ),
                    child: Center(
                      child: Text(
                        user?.initials ?? 'AK',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Aditya Kumar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${user?.role ?? 'Scrap Manager'} · Chennai',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Verified account',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greenDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Business Information Card
            _buildSectionCard(
              title: 'Business Information',
              children: [
                _buildInfoRow('Business name', user?.business ?? 'Kumar Scrap Traders'),
                _buildInfoRow('Phone', user?.phone ?? '+91 98765 43210'),
                _buildInfoRow('Email', user?.email ?? 'admin@scrapit.com'),
                _buildInfoRow('GST / License', user?.gst ?? '33ABCDE1234F1Z5'),
                _buildInfoRow('Address', user?.address ?? '123, Green Street, Chennai'),
              ],
            ),
            const SizedBox(height: 16),

            // Notification Preferences Card
            _buildSectionCard(
              title: 'Notification Preferences',
              children: [
                _buildSwitchRow(
                  title: 'Scan completion alerts',
                  subtitle: 'Notify when AI analysis finishes',
                  value: notif.pushScan,
                  onChanged: (v) => settingsProv.updateNotificationSetting(pushScan: v),
                ),
                _buildSwitchRow(
                  title: 'Price change alerts',
                  subtitle: 'Daily market rate movements',
                  value: notif.priceAlerts,
                  onChanged: (v) => settingsProv.updateNotificationSetting(priceAlerts: v),
                ),
                _buildSwitchRow(
                  title: 'Inventory reminders',
                  subtitle: 'Weekly stock review alerts',
                  value: notif.invReminder,
                  onChanged: (v) => settingsProv.updateNotificationSetting(invReminder: v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Application Preferences Card
            _buildSectionCard(
              title: 'Application Preferences',
              children: [
                _buildDropdownRow(
                  title: 'Language',
                  subtitle: 'Interface language',
                  value: pref.language,
                  items: const ['English', 'Tamil', 'Hindi'],
                  onChanged: (v) {
                    if (v != null) settingsProv.updatePreferences(language: v);
                  },
                ),
                _buildDropdownRow(
                  title: 'Currency',
                  subtitle: 'Price format',
                  value: pref.currency,
                  items: const ['INR (₹)', 'USD (\$)'],
                  onChanged: (v) {
                    if (v != null) settingsProv.updatePreferences(currency: v);
                  },
                ),
                _buildInfoRow('Measurement unit', 'Kilograms (${pref.unit})'),
              ],
            ),
            const SizedBox(height: 16),

            // Server & Network Card
            _buildSectionCard(
              title: 'Backend Server Connection',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API Base URL',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            context.watch<ApiService>().baseUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.greenDark,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _showServerConfigDialog,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Change', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Security & Session Card
            _buildSectionCard(
              title: 'Security & Session',
              children: [
                _buildInfoRow('Session status', 'Active', isSuccess: true),
                _buildInfoRow('Device', 'Android Mobile'),
                _buildInfoRow('Storage', 'Secure Device Token + Express JSON DB'),
                _buildInfoRow('Platform Version', 'ScrapIt Mobile v1.0.0'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSuccess ? AppColors.success : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final validValue = items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: validValue,
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
