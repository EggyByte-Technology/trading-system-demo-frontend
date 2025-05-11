import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import '../../modules/auth/screens/login_screen.dart';
import '../../modules/auth/screens/register_screen.dart';

// Account screens
import '../../modules/account/screens/account_screen.dart';
import '../../modules/account/screens/wallet_screen.dart';

// Market screens
import '../../modules/market/screens/market_screen.dart';
import '../../modules/market/screens/market_detail_screen.dart';

// Trading screens
import '../../modules/trading/screens/trading_screen.dart';

// Risk screens
import '../../modules/risk/screens/risk_screen.dart';

// Notification screens
import '../../modules/notification/screens/notification_screen.dart';

// Auth provider
import '../../modules/auth/providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoginRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If not logged in and not on login/register page, redirect to login
      if (!isLoggedIn && !isLoginRoute) return '/login';

      // If logged in and on login/register page, redirect to dashboard
      if (isLoggedIn && isLoginRoute) return '/dashboard';

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app scaffold with tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _getSelectedIndex(
                GoRouterState.of(context).matchedLocation,
              ),
              onTap: (index) => _onItemTapped(index, context),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Markets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz),
                  label: 'Trading',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Account',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warning),
                  label: 'Risk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
              ],
            ),
          );
        },
        routes: [
          // Dashboard/Market route
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const MarketScreen(),
            routes: [
              GoRoute(
                path: 'symbol/:symbolId',
                builder: (context, state) => MarketDetailScreen(
                  symbol: state.pathParameters['symbolId'] ?? '',
                ),
              ),
            ],
          ),

          // Trading route
          GoRoute(
            path: '/trading',
            builder: (context, state) => const TradingScreen(),
          ),

          // Account route
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountScreen(),
            routes: [
              GoRoute(
                path: 'wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),

          // Risk route
          GoRoute(
            path: '/risk',
            builder: (context, state) => const RiskScreen(),
          ),

          // Notification route
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
        ],
      ),
    ],
  );
});

int _getSelectedIndex(String location) {
  if (location.startsWith('/dashboard')) return 0;
  if (location.startsWith('/trading')) return 1;
  if (location.startsWith('/account')) return 2;
  if (location.startsWith('/risk')) return 3;
  if (location.startsWith('/notifications')) return 4;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;
    case 1:
      context.go('/trading');
      break;
    case 2:
      context.go('/account');
      break;
    case 3:
      context.go('/risk');
      break;
    case 4:
      context.go('/notifications');
      break;
  }
}
