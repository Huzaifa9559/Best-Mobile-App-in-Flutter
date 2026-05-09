import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/place.dart';
import '../providers/map_place_provider.dart';
import '../providers/places_notifier.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Place? _selectedPlace;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFocusedPlace());
  }

  void _applyFocusedPlace() {
    final focusedId = ref.read(focusedMapPlaceIdProvider);
    if (focusedId == null) return;

    final places = ref.read(placesProvider).valueOrNull?.items ?? [];
    final target = places.cast<Place?>().firstWhere(
          (p) => p?.id == focusedId,
          orElse: () => null,
        );
    if (target != null) {
      final (lat, lon) = target.coordinates;
      setState(() => _selectedPlace = target);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _mapController.move(LatLng(lat, lon), 5.0);
      });
    }
    // Clear so it doesn't re-trigger on subsequent visits
    ref.read(focusedMapPlaceIdProvider.notifier).state = null;
  }

  List<Place> get _filteredPlaces {
    final all = ref.read(placesProvider).valueOrNull?.items ?? [];
    if (_searchQuery.isEmpty) return all;
    return all
        .where((p) => p.displayTitle
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search places on map…',
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              )
            : const Text('Explore Map'),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _showSearch ? Icons.close : Icons.search,
                key: ValueKey(_showSearch),
              ),
            ),
            tooltip: _showSearch ? 'Close search' : 'Search places',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          if (_selectedPlace != null)
            TextButton.icon(
              onPressed: () => context.push(
                '/detail/${_selectedPlace!.id}',
                extra: _selectedPlace,
              ),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Details'),
            ),
        ],
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(placesProvider),
        ),
        data: (view) {
          final allPlaces = view.items;
          if (allPlaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined,
                      size: 56, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  const Text('Load places from Home first.'),
                ],
              ),
            );
          }

          final places = _searchQuery.isEmpty
              ? allPlaces
              : allPlaces
                  .where((p) => p.displayTitle
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .toList();

          final markers = places.map((p) {
            final (lat, lon) = p.coordinates;
            final isSelected = _selectedPlace?.id == p.id;
            return Marker(
              point: LatLng(lat, lon),
              width: isSelected ? 52 : 38,
              height: isSelected ? 52 : 38,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedPlace = p);
                  _mapController.move(LatLng(lat, lon), 5.5);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryPurple,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple
                            .withValues(alpha: isSelected ? 0.5 : 0.2),
                        blurRadius: isSelected ? 10 : 4,
                        spreadRadius: isSelected ? 2 : 0,
                      )
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.place : Icons.place_outlined,
                    size: isSelected ? 28 : 20,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryPurple,
                  ),
                ),
              ),
            );
          }).toList();

          final first = places.isNotEmpty ? places.first : allPlaces.first;
          final (fLat, fLon) = first.coordinates;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(fLat, fLon),
                  initialZoom: 3.0,
                  onTap: (_, __) => setState(() => _selectedPlace = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.smart_travel_companion',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Place count badge
              Positioned(
                top: 12,
                left: 12,
                child: _CountBadge(
                  total: allPlaces.length,
                  filtered: places.length,
                  isFiltered: _searchQuery.isNotEmpty,
                  isDark: isDark,
                ),
              ),

              // Zoom controls
              Positioned(
                right: 12,
                top: 12,
                child: _ZoomControls(
                  onZoomIn: () {
                    final current = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, current + 1);
                  },
                  onZoomOut: () {
                    final current = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, current - 1);
                  },
                  onResetView: () {
                    final (lat, lon) = allPlaces.first.coordinates;
                    _mapController.move(LatLng(lat, lon), 3.0);
                    setState(() => _selectedPlace = null);
                  },
                ),
              ),

              // Selected place info card
              if (_selectedPlace != null)
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: _PlaceInfoCard(
                    place: _selectedPlace!,
                    onViewDetail: () => context.push(
                      '/detail/${_selectedPlace!.id}',
                      extra: _selectedPlace,
                    ),
                    onDismiss: () =>
                        setState(() => _selectedPlace = null),
                  ),
                ),

              // OSM attribution
              Positioned(
                bottom: _selectedPlace != null ? 134 : 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 9, color: Colors.black87),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.total,
    required this.filtered,
    required this.isFiltered,
    required this.isDark,
  });

  final int total;
  final int filtered;
  final bool isFiltered;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on,
              size: 14, color: AppColors.primaryPurple),
          const SizedBox(width: 4),
          Text(
            isFiltered
                ? '$filtered / $total places'
                : '$total places',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? Colors.black.withValues(alpha: 0.75)
        : Colors.white.withValues(alpha: 0.95);
    final fg = isDark ? Colors.white : AppColors.darkNavy;

    return Column(
      children: [
        _zoomBtn(Icons.add, onZoomIn, bg, fg),
        const SizedBox(height: 2),
        _zoomBtn(Icons.remove, onZoomOut, bg, fg),
        const SizedBox(height: 8),
        _zoomBtn(Icons.my_location, onResetView, bg, AppColors.primaryPurple,
            tooltip: 'Reset view'),
      ],
    );
  }

  Widget _zoomBtn(
    IconData icon,
    VoidCallback onTap,
    Color bg,
    Color fg, {
    String? tooltip,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}

class _PlaceInfoCard extends StatelessWidget {
  const _PlaceInfoCard({
    required this.place,
    required this.onViewDetail,
    required this.onDismiss,
  });

  final Place place;
  final VoidCallback onViewDetail;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutBack,
      transitionBuilder: (child, animation) => SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.4), end: Offset.zero)
                .animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Material(
        key: ValueKey(place.id),
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  place.thumbnailUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.displayTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.explore_outlined,
                            size: 13,
                            color: theme.colorScheme.outline),
                        const SizedBox(width: 3),
                        Text(
                          place.regionLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded,
                            size: 13, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          ((place.id % 15 + 35) / 10)
                              .toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    onPressed: onViewDetail,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('View',
                        style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(Icons.close,
                        size: 18, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load places',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
