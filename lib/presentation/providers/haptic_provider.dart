import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';
import 'package:pickture/core/utils/haptic_service.dart';

part 'haptic_provider.g.dart';

@Riverpod(keepAlive: true)
class HapticNotifier extends _$HapticNotifier {
  static const _enabledKey = 'haptic_enabled';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<void> toggle() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state;
    await prefs.setBool(_enabledKey, newValue);
    state = newValue;
  }
}

@riverpod
HapticService hapticService(HapticServiceRef ref) {
  final enabled = ref.watch(hapticNotifierProvider);
  return HapticService(enabled: enabled);
}
