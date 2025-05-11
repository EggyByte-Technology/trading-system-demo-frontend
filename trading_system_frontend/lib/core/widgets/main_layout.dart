import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'responsive_layout.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: _BottomNavigationWidget(),
    );
  }
}

class _BottomNavigationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        color: Theme.of(context).colorScheme.surface,
      ),
      child: NavigationBar(
        selectedIndex: _calculateSelectedIndex(currentLocation),
        onDestinationSelected: (int index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Market'),
          NavigationDestination(
            icon: Icon(Icons.candlestick_chart),
            label: 'Trade',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Account',
          ),
          NavigationDestination(icon: Icon(Icons.shield), label: 'Risk'),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String currentLocation) {
    if (currentLocation.startsWith('/trade')) {
      return 1;
    } else if (currentLocation.startsWith('/account')) {
      return 2;
    } else if (currentLocation.startsWith('/risk')) {
      return 3;
    } else if (currentLocation.startsWith('/notifications')) {
      return 4;
    } else {
      return 0; // Default to Market
    }
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/trade/BTC-USDT');
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
}
