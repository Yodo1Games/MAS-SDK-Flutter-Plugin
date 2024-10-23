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

  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) {
    throw UnimplementedError('initSdk(str, bool, bool, bool, bool) has not been implemented.');
  }
  Future<void> loadAd(String adType) {
    throw UnimplementedError('loadAd(str) has not been implemented.');
  }
  Future<bool> isAdLoaded(String adType) {
    throw UnimplementedError('isAdLoaded(str) has not been implemented');
  }
  Future<void> showAd(String adType, {String? placementId}) {
    throw UnimplementedError('showAd(str, str) has not been implemented');
  }
  void setInitListener(Function(bool successful)? callback) {
    throw UnimplementedError('setInitListener(Function(bool)?) has not been implemented.');
  }

  void setRewardListener(Function(int event, String message)? callback) {
    throw UnimplementedError('setRewardListener(Function(int, String)?) has not been implemented.');
  }

  void setInterstitialListener(Function(int event, String message)? callback) {
    throw UnimplementedError('setInterstitialListener(Function(int, String)?) has not been implemented.');
  }

  void setAppOpenListener(Function(int event, String message)? callback) {
    throw UnimplementedError('setAppOpenListener(Function(int, String)?) has not been implemented.');
  }
}
