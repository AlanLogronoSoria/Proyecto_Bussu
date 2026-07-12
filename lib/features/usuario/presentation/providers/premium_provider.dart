import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';

final premiumUpgradeProvider = StateProvider<bool>((ref) => false);

class PremiumNotifier extends StateNotifier<AsyncValue<void>> {
  PremiumNotifier() : super(const AsyncValue.data(null));

  Future<void> upgrade(String planId) async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(seconds: 1));
    state = const AsyncValue.data(null);
  }

  Future<void> cancel() async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = const AsyncValue.data(null);
  }
}

final premiumNotifierProvider =
    StateNotifierProvider<PremiumNotifier, AsyncValue<void>>((ref) {
  return PremiumNotifier();
});
