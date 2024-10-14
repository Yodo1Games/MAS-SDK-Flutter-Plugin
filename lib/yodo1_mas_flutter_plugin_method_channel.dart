import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'yodo1_mas_flutter_plugin_platform_interface.dart';

/// An implementation of [Yodo1MasFlutterPluginPlatform] that uses method channels.
class MethodChannelYodo1MasFlutterPlugin extends Yodo1MasFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('yodo1_mas_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
