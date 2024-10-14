import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'yodo1_mas_flutter_plugin_method_channel.dart';

abstract class Yodo1MasFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a Yodo1MasFlutterPluginPlatform.
  Yodo1MasFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static Yodo1MasFlutterPluginPlatform _instance = MethodChannelYodo1MasFlutterPlugin();

  /// The default instance of [Yodo1MasFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelYodo1MasFlutterPlugin].
  static Yodo1MasFlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Yodo1MasFlutterPluginPlatform] when
  /// they register themselves.
  static set instance(Yodo1MasFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr);
  Future<void> loadAd(String adType);
  Future<bool> isAdLoaded(String adType);
  Future<void> showAd(String adType, {String? placementId});
}
