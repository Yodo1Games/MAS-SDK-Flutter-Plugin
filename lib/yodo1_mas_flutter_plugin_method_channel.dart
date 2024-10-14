import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'yodo1_mas_flutter_plugin_platform_interface.dart';

/// An implementation of [Yodo1MasFlutterPluginPlatform] that uses method channels.
class MethodChannelYodo1MasFlutterPlugin extends Yodo1MasFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.yodo1.mas/sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) async {
    await methodChannel.invokeMethod('native_init_sdk', {
      'app_key': appKey,
      'privacy': privacy,
      'ccpa': ccpa,
      'coppa': coppa,
      'gdpr': gdpr,
    });
  }

  Future<void> loadAd(String adType) async {
    await methodChannel.invokeMethod('native_load_ad', {
      'ad_type': adType,
    });
  }

  Future<bool> isAdLoaded(String adType) async {
    final isLoaded = await methodChannel.invokeMethod<bool>('native_is_ad_loaded', {
      'ad_type': adType,
    });
    return isLoaded ?? false;
  }

  Future<void> showAd(String adType, {String? placementId}) async {
    await methodChannel.invokeMethod('native_show_ad', {
      'ad_type': adType,
      'placement_id': placementId,
    });
  }


}
