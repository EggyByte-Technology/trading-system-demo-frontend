import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/market/screens/market_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/config/app_config.dart';
import 'services/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app configuration
  AppConfig().initialize(Environment.test);

  runApp(const ProviderScope(child: TradingSystemApp()));
}

class TradingSystemApp extends ConsumerWidget {
  const TradingSystemApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Trading System',
      theme: AppTheme.darkTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
