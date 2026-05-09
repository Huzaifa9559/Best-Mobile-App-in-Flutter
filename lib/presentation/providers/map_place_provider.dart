import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set this before navigating to /map to auto-focus a specific place.
final focusedMapPlaceIdProvider = StateProvider<int?>((ref) => null);
