import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/place.dart';
import 'place_card.dart';

typedef PlaceTap = void Function(Place place);

/// Animated list with append support for pagination and identity-based resets.
class AnimatedPlacesList extends StatefulWidget {
  const AnimatedPlacesList({
    required this.listIdentity,
    required this.places,
    required this.onPlaceTap,
    required this.onNearEnd,
    super.key,
  });

  /// Changes when filters/search/sort/full refresh should rebuild the list.
  final String listIdentity;

  final List<Place> places;
  final PlaceTap onPlaceTap;
  final VoidCallback onNearEnd;

  @override
  State<AnimatedPlacesList> createState() => _AnimatedPlacesListState();
}

class _AnimatedPlacesListState extends State<AnimatedPlacesList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Place> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void didUpdateWidget(covariant AnimatedPlacesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listIdentity != widget.listIdentity) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
      return;
    }
    _appendIfNeeded(oldWidget.places, widget.places);
  }

  void _bootstrap() {
    for (var idx = _items.length - 1; idx >= 0; idx--) {
      final removed = _items.removeAt(idx);
      _listKey.currentState?.removeItem(
        idx,
        (context, animation) => _removedTile(removed, animation),
        duration: Duration.zero,
      );
    }
    for (var i = 0; i < widget.places.length; i++) {
      _items.add(widget.places[i]);
      _listKey.currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 280),
      );
    }
  }

  void _appendIfNeeded(List<Place> previous, List<Place> next) {
    if (next.length > previous.length &&
        listEquals(next.sublist(0, previous.length), previous)) {
      for (var i = previous.length; i < next.length; i++) {
        _items.insert(i, next[i]);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 280),
        );
      }
    }
  }

  Widget _removedTile(Place place, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final place = _items[index];
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlaceCard(
              place: place,
              heroTag: 'place-${place.id}',
              onTap: () => widget.onPlaceTap(place),
            ),
          ),
        ),
      ),
    );
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final metrics = notification.metrics;
    if (metrics.pixels >= metrics.maxScrollExtent - 320) {
      widget.onNearEnd();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        initialItemCount: _items.length,
        itemBuilder: _buildItem,
      ),
    );
  }
}
