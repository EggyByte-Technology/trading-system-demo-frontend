// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/theme/app_theme.dart';

// class DashboardScreen extends StatelessWidget {
//   final Widget child;

//   const DashboardScreen({Key? key, required this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: child,
//       bottomNavigationBar: NavigationBar(
//         onDestinationSelected: (int index) {
//           switch (index) {
//             case 0:
//               context.go('/dashboard');
//               break;
//             case 1:
//               context.go('/trading');
//               break;
//             case 2:
//               context.go('/account');
//               break;
//             case 3:
//               context.go('/risk');
//               break;
//             case 4:
//               context.go('/notifications');
//               break;
//           }
//         },
//         selectedIndex: _calculateSelectedIndex(context),
//         destinations: const [
//           NavigationDestination(icon: Icon(Icons.dashboard), label: 'Markets'),
//           NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Trading'),
//           NavigationDestination(
//             icon: Icon(Icons.account_balance_wallet),
//             label: 'Account',
//           ),
//           NavigationDestination(icon: Icon(Icons.warning), label: 'Risk'),
//           NavigationDestination(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//         ],
//       ),
//     );
//   }

//   int _calculateSelectedIndex(BuildContext context) {
//     final String location = GoRouter.of(context);
//     if (location.startsWith('/dashboard')) {
//       return 0;
//     }
//     if (location.startsWith('/trading')) {
//       return 1;
//     }
//     if (location.startsWith('/account')) {
//       return 2;
//     }
//     if (location.startsWith('/risk')) {
//       return 3;
//     }
//     if (location.startsWith('/notifications')) {
//       return 4;
//     }
//     return 0;
//   }
// }
