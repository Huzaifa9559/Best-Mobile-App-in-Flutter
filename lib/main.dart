import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/dependency_injection.dart';
import 'presentation/providers/theme_mode_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final placesBox = await Hive.openBox<dynamic>('places_cache');
  final appBox = await Hive.openBox<dynamic>('app_prefs');

  runApp(
    ProviderScope(
      overrides: [
        placesBoxProvider.overrideWithValue(placesBox),
        appBoxProvider.overrideWithValue(appBox),
      ],
      child: const SmartTravelApp(),
    ),
  );
}

class SmartTravelApp extends ConsumerWidget {
  const SmartTravelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
