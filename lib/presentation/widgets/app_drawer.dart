import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../providers/theme_mode_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 24,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple,
                  Color(0xFF554EE8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aarav Mehta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'aarav.mehta@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _tile(context, Icons.home_outlined, 'Home', () {
                  Navigator.pop(context);
                  context.go('/home');
                }),
                _tile(context, Icons.map_outlined, 'Map', () {
                  Navigator.pop(context);
                  context.go('/map');
                }),
                _tile(context, Icons.favorite_border, 'Favorites', () {
                  Navigator.pop(context);
                  context.go('/favorites');
                }),
                _tile(context, Icons.download_outlined, 'Downloaded', () {
                  Navigator.pop(context);
                  context.push('/downloaded');
                }),
                _tile(context, Icons.settings_outlined, 'Settings', () {
                  Navigator.pop(context);
                  context.push('/settings');
                }),
                _tile(context, Icons.help_outline, 'Help & Support', () {
                  Navigator.pop(context);
                  context.push('/help');
                }),
                _tile(context, Icons.info_outline, 'About Us', () {
                  Navigator.pop(context);
                  context.push('/about');
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: 200.ms,
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey(isDark),
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch.adaptive(
                  value: isDark,
                  activeColor: AppColors.primaryPurple,
                  onChanged: (v) {
                    ref.read(themeModeProvider.notifier).state =
                        v ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(title),
      onTap: onTap,
    );
  }
}
