import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Provide a toggle function
final themeToggleProvider = Provider((ref) => () {
  final current = ref.read(themeModeProvider);
  final newMode = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  ref.read(themeModeProvider.notifier).state = newMode;
});