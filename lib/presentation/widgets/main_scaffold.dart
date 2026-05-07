import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

/// Hosts bottom navigation + center action matching the design reference.
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/map')) return 1;
    if (loc.startsWith('/favorites')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final index = _indexFromLocation(loc);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('search'),
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                selected: index == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
              const SizedBox(width: 56),
              _NavItem(
                icon: Icons.favorite_border,
                label: 'Saved',
                selected: index == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: index == 3,
                onTap: () => navigationShell.goBranch(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryPurple : Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
