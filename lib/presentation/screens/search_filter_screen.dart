import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../providers/place_list_filter.dart';
import '../providers/places_notifier.dart';
import '../providers/search_filter_providers.dart';

class SearchFilterScreen extends ConsumerWidget {
  const SearchFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(searchSortProvider);
    final filter = ref.watch(placeListFilterProvider);
    final region = ref.watch(regionFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final albums = ref.watch(placesProvider).maybeWhen(
          data: (v) {
            final ids = v.items.map((p) => p.albumId).toSet().toList();
            ids.sort();
            return ids;
          },
          orElse: () => <int>[],
        );

    final activeCount = _activeFilterCount(sort, filter, region);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Search & Filters'),
            if (activeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeCount active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (activeCount > 0)
            TextButton(
              onPressed: () {
                ref.read(searchSortProvider.notifier).state =
                    PlaceSortMode.recommended;
                ref.read(placeListFilterProvider.notifier).state =
                    PlaceListFilter.all;
                ref.read(regionFilterProvider.notifier).state = null;
              },
              child: const Text('Reset all'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // ── Sort ──────────────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.sort_rounded,
            label: 'Sort By',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SegmentedSort(
            current: sort,
            onChanged: (v) =>
                ref.read(searchSortProvider.notifier).state = v,
          ),
          const SizedBox(height: 24),

          // ── Filter ────────────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.filter_list_rounded,
            label: 'Show',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterOption(
                label: 'All Places',
                icon: Icons.travel_explore,
                selected: filter == PlaceListFilter.all,
                onTap: () => ref
                    .read(placeListFilterProvider.notifier)
                    .state = PlaceListFilter.all,
              ),
              _FilterOption(
                label: 'Favorites',
                icon: Icons.favorite_rounded,
                selected: filter == PlaceListFilter.favorites,
                onTap: () => ref
                    .read(placeListFilterProvider.notifier)
                    .state = PlaceListFilter.favorites,
              ),
              _FilterOption(
                label: 'Recent',
                icon: Icons.history_rounded,
                selected: filter == PlaceListFilter.recent,
                onTap: () => ref
                    .read(placeListFilterProvider.notifier)
                    .state = PlaceListFilter.recent,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Region ────────────────────────────────────────────────────
          _SectionHeader(
            icon: Icons.public_rounded,
            label: 'Region (Album)',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _RegionSelector(
            albums: albums,
            selected: region,
            onChanged: (v) =>
                ref.read(regionFilterProvider.notifier).state = v,
          ),
          const SizedBox(height: 32),

          // ── Apply ─────────────────────────────────────────────────────
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => context.pop(),
            child: Text(
              activeCount > 0
                  ? 'Apply $activeCount Filter${activeCount > 1 ? "s" : ""}'
                  : 'Apply Filters',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  int _activeFilterCount(
      PlaceSortMode sort, PlaceListFilter filter, int? region) {
    int count = 0;
    if (sort != PlaceSortMode.recommended) count++;
    if (filter != PlaceListFilter.all) count++;
    if (region != null) count++;
    return count;
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryPurple),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}

// ─── Sort segment ─────────────────────────────────────────────────────────────

class _SegmentedSort extends StatelessWidget {
  const _SegmentedSort({
    required this.current,
    required this.onChanged,
  });

  final PlaceSortMode current;
  final ValueChanged<PlaceSortMode> onChanged;

  static const _options = [
    (PlaceSortMode.recommended, Icons.recommend_rounded, 'Recommended'),
    (PlaceSortMode.nameAZ, Icons.sort_by_alpha, 'A – Z'),
    (PlaceSortMode.recentIds, Icons.new_releases_outlined, 'Newest'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: _options.map((opt) {
        final (mode, icon, label) = opt;
        final selected = current == mode;
        return Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 3),
            child: _SortChip(
              icon: icon,
              label: label,
              selected: selected,
              onTap: () => onChanged(mode),
              theme: theme,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : theme.hintColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter option pill ───────────────────────────────────────────────────────

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : theme.hintColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Region selector ──────────────────────────────────────────────────────────

class _RegionSelector extends StatelessWidget {
  const _RegionSelector({
    required this.albums,
    required this.selected,
    required this.onChanged,
  });

  final List<int> albums;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (albums.isEmpty) {
      return Text(
        'Load places first to filter by region.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _RegionChip(
          label: 'All',
          selected: selected == null,
          onTap: () => onChanged(null),
        ),
        ...albums.map(
          (a) => _RegionChip(
            label: 'Album $a',
            selected: selected == a,
            onTap: () => onChanged(selected == a ? null : a),
          ),
        ),
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  const _RegionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.primaryPurple : theme.hintColor,
          ),
        ),
      ),
    );
  }
}
