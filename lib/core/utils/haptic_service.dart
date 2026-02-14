import 'package:flutter/services.dart';

class HapticService {
  HapticService({required this.enabled});

  bool enabled;

  void lightImpact() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }
}
