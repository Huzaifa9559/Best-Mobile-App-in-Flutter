import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/place.dart';
import '../providers/places_notifier.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (view) {
          final places = view.items;
          if (places.isEmpty) {
            return const Center(child: Text('Load places from Home first.'));
          }
          final markers = <Marker>{};
          for (final p in places.take(40)) {
            final (lat, lon) = p.coordinates;
            markers.add(
              Marker(
                markerId: MarkerId('p-${p.id}'),
                position: LatLng(lat, lon),
                infoWindow: InfoWindow(title: p.displayTitle),
                onTap: () => context.push('/detail/${p.id}', extra: p),
              ),
            );
          }
          final first = places.first;
          final (fla, flo) = first.coordinates;
          final target = LatLng(fla, flo);

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: target,
              zoom: 3.2,
            ),
            markers: markers,
            onMapCreated: (_) {},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          );
        },
      ),
    );
  }

}
