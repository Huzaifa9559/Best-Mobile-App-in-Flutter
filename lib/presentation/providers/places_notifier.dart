import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/place.dart';
import 'dependency_injection.dart';

class PlacesViewState extends Equatable {
  const PlacesViewState({
    required this.items,
    required this.nextStart,
    required this.hasMore,
    required this.loadingMore,
    required this.epoch,
  });

  final List<Place> items;
  final int nextStart;
  final bool hasMore;
  final bool loadingMore;

  /// Bumps on full refresh so list widgets can reset (`AnimatedList`).
  final int epoch;

  static const int pageSize = 20;

  PlacesViewState copyWith({
    List<Place>? items,
    int? nextStart,
    bool? hasMore,
    bool? loadingMore,
    int? epoch,
  }) {
    return PlacesViewState(
      items: items ?? this.items,
      nextStart: nextStart ?? this.nextStart,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      epoch: epoch ?? this.epoch,
    );
  }

  @override
  List<Object?> get props => [items, nextStart, hasMore, loadingMore, epoch];
}

class PlacesNotifier extends AsyncNotifier<PlacesViewState> {
  @override
  Future<PlacesViewState> build() async {
    final getPlaces = ref.read(getPlacesUseCaseProvider);
    final batch = await getPlaces(
      start: 0,
      limit: PlacesViewState.pageSize,
    );
    return PlacesViewState(
      items: batch,
      nextStart: batch.length,
      hasMore: batch.length == PlacesViewState.pageSize,
      loadingMore: false,
      epoch: 0,
    );
  }

  Future<void> refresh() async {
    final prevEpoch = state.valueOrNull?.epoch ?? -1;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final getPlaces = ref.read(getPlacesUseCaseProvider);
      final batch = await getPlaces(
        start: 0,
        limit: PlacesViewState.pageSize,
        forceRefresh: true,
      );
      return PlacesViewState(
        items: batch,
        nextStart: batch.length,
        hasMore: batch.length == PlacesViewState.pageSize,
        loadingMore: false,
        epoch: prevEpoch + 1,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final getPlaces = ref.read(getPlacesUseCaseProvider);
      final more = await getPlaces(
        start: current.nextStart,
        limit: PlacesViewState.pageSize,
      );
      final merged = [...current.items, ...more];
      state = AsyncData(
        PlacesViewState(
          items: merged,
          nextStart: current.nextStart + more.length,
          hasMore: more.length == PlacesViewState.pageSize,
          loadingMore: false,
          epoch: current.epoch,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

final placesProvider =
    AsyncNotifierProvider<PlacesNotifier, PlacesViewState>(PlacesNotifier.new);
