import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dependency_injection.dart';

final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return ref.watch(connectivityProvider).onConnectivityChanged;
});

final isOnlineProvider = FutureProvider<bool>((ref) async {
  final list = await ref.watch(connectivityProvider).checkConnectivity();
  return list.any((c) => c != ConnectivityResult.none);
});
