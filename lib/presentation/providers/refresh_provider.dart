import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// A simple counter that we increment when we want to force a refresh.
final refreshTriggerProvider = StateProvider<int>((ref) => 0);

/// A helper function to trigger a refresh.
void triggerRefresh(WidgetRef ref) {
  ref.read(refreshTriggerProvider.notifier).state++;
}