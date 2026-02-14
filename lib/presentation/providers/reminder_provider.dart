import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:pickture/application/providers/app_providers.dart';

part 'reminder_provider.g.dart';

@Riverpod(keepAlive: true)
class ReminderNotifier extends _$ReminderNotifier {
  static const _enabledKey = 'reminder_enabled';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> toggle({required String title, required String body}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final notificationService = ref.read(notificationServiceProvider);

    final newValue = !state;
    await prefs.setBool(_enabledKey, newValue);

    if (newValue) {
      await notificationService.requestPermission();
      await notificationService.scheduleWeeklyReminder(
        title: title,
        body: body,
      );
    } else {
      await notificationService.cancelReminder();
    }

    state = newValue;
  }
}
