import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final currentTabProvider = StateProvider<int>((ref) => 0);
