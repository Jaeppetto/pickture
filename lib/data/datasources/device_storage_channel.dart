import 'package:flutter/services.dart';

class DeviceStorageChannel {
  static const _channel = MethodChannel('com.jaeppetto.pickture/storage');

  Future<Map<String, int>> getStorageInfo() async {
    try {
      final result = await _channel.invokeMapMethod<String, int>(
        'getStorageInfo',
      );
      return result ?? _fallback();
    } on PlatformException {
      return _fallback();
    } on MissingPluginException {
      return _fallback();
    }
  }

  Map<String, int> _fallback() {
    return {'totalBytes': 0, 'freeBytes': 0};
  }
}
