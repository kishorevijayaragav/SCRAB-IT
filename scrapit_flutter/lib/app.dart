import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/scanner/scan_result_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/buyers/buyers_screen.dart';
import 'screens/pricing/pricing_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';

class ScrapItApp extends StatefulWidget {
  const ScrapItApp({super.key});

  @override
  State<ScrapItApp> createState() => _ScrapItAppState();
}

class _ScrapItAppState extends State<ScrapItApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/home',
      refreshListenable: auth,
      redirect: (context, state) {
        if (!auth.isInitialized) return null;

        final isLoggingIn = state.matchedLocation == '/login';
        if (!auth.isAuthenticated) {
          return isLoggingIn ? null : '/login';
        }

        if (isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/scanner',
                  builder: (context, state) => const ScannerScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/inventory',
                  builder: (context, state) => const InventoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/buyers',
                  builder: (context, state) => const BuyersScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/results',
          builder: (context, state) => const ScanResultScreen(),
        ),
        GoRoute(
          path: '/pricing',
          builder: (context, state) => const PricingScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ScrapIt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
