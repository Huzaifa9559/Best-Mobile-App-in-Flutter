import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dependency_injection.dart';

const _kThemeKey = 'themeMode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = ref.watch(appBoxProvider);
    final stored = box.get(_kThemeKey) as String?;
    return stored == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  void setMode(ThemeMode mode) {
    state = mode;
    ref
        .read(appBoxProvider)
        .put(_kThemeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
