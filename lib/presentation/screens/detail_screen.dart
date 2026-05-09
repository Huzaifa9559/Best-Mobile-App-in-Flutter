import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/weather.dart';
import '../providers/favorites_notifier.dart';
import '../providers/map_place_provider.dart';
import '../providers/weather_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({required this.place, super.key});

  final Place place;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final weatherAsync = ref.watch(weatherForPlaceProvider(place));
    final favAsync = ref.watch(favoritesProvider);
    final favs = favAsync.valueOrNull ?? {};
    final isFav = favs.contains(place.id);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.coral : Colors.white,
                    ),
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(place.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'place-${place.id}',
                    child: CachedNetworkImage(
                      imageUrl: place.url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade900),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.displayTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Region: ${place.albumId} · ${place.regionLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A stunning destination to explore. This copy is generated for the demo and pairs with live weather for the coordinates derived from this card.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: weatherAsync.when(
                          data: (w) => _WeatherCard(
                            key: const ValueKey('loaded'),
                            weather: w,
                          ),
                          loading: () => const _WeatherSkeleton(
                            key: ValueKey('loading'),
                          ),
                          error: (e, _) => _WeatherError(
                            key: const ValueKey('error'),
                            message: e.toString(),
                            onRetry: () => ref.invalidate(
                              weatherForPlaceProvider(place),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _aboutExpanded = !_aboutExpanded),
                        child: Row(
                          children: [
                            Text(
                              'About the place',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            AnimatedRotation(
                              turns: _aboutExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 220),
                              child: const Icon(Icons.keyboard_arrow_down_rounded),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _aboutExpanded
                            ? Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Builder(
                                  builder: (context) {
                                    final (lat, lon) = place.coordinates;
                                    return Text(
                                      '${place.title}. '
                                      'Coordinates (${lat.toStringAsFixed(2)}, '
                                      '${lon.toStringAsFixed(2)}) are synthetic for this demo.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    );
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(focusedMapPlaceIdProvider.notifier)
                                .state = place.id;
                            context.go('/map');
                          },
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('View on Map'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherSkeleton extends StatelessWidget {
  const _WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      height: 140,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _WeatherError extends StatelessWidget {
  const _WeatherError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weather unavailable', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(message),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.weather, super.key});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final apparent =
        weather.apparentTemperatureC ?? weather.temperatureC;
    final humidity = weather.humidityPct ?? 48;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E1064),
            AppColors.primaryPurple,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Weather',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                weather.isDay == 1 ? Icons.wb_sunny_outlined : Icons.nights_stay,
                color: Colors.amberAccent,
                size: 36,
              ),
              const SizedBox(width: 12),
              Text(
                '${weather.temperatureC.round()}°C',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weather.conditionLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _miniStat(
                context,
                Icons.air,
                'Wind',
                '${weather.windspeedKmh.round()} km/h',
              ),
              _miniStat(
                context,
                Icons.water_drop_outlined,
                'Humidity',
                '${humidity.round()}%',
              ),
              _miniStat(
                context,
                Icons.thermostat,
                'Feels like',
                '${apparent.round()}°C',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
