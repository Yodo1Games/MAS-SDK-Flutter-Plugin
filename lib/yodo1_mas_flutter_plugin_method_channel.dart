import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'dart:convert';

import 'yodo1_mas_flutter_plugin_platform_interface.dart';
import 'constants.dart';

/// An implementation of [Yodo1MasFlutterPluginPlatform] that uses method channels.
class MethodChannelYodo1MasFlutterPlugin extends Yodo1MasFlutterPluginPlatform {
  Function(bool successful)? _initCallback;
  Function(int event, String message)? _rewardCallback;
  Function(int event, String message)? _interstitialCallback;
  Function(int event, String message)? _appOpenCallback;
  Function(int event, String message)? _bannerCallback;
  Function(int event, String message)? _nativeCallback;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(Yodo1MasConstants.channel);

  @override
  Future<void> initSdk(
      String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) async {
    String methodChannelName = methodChannel.name;
    log('Yodo1 Flutter Plugin registering channel name $methodChannelName');
    methodChannel.setMethodCallHandler((call) {
      String method = call.method;
      log('Yodo1 Flutter Plugin method call: $method');
      switch (method) {
        case Yodo1MasConstants.methodFlutterInitEvent:
          {
            bool successful;
            if (defaultTargetPlatform == TargetPlatform.android) {
              Map<String, dynamic> map = json.decode(call.arguments);
              successful = map["successful"];
            } else {
              successful = call.arguments["successful"];
            }
            if (_initCallback != null) {
              _initCallback!(successful);
            }
            return Future<bool>.value(true);
          }
        case Yodo1MasConstants.methodFlutterAdEvent:
          {
            int type, code;
            String message;
            if (defaultTargetPlatform == TargetPlatform.android) {
              Map<String, dynamic> map = json.decode(call.arguments);
              type = map["type"];
              code = map["code"];
              message = map["message"] ?? '';
            } else {
              type = call.arguments["type"];
              code = call.arguments["code"];
              message = call.arguments["message"] ?? '';
            }

            log('Yodo1 Flutter event type: $type');
            log('Yodo1 Flutter event code: $code');
            log('Yodo1 Flutter event message: $message');

            switch (type) {
              case Yodo1MasConstants.adTypeReward:
                if (_rewardCallback != null) {
                  _rewardCallback!(code, message);
                }
                break;
              case Yodo1MasConstants.adTypeInterstitial:
                if (_interstitialCallback != null) {
                  _interstitialCallback!(code, message);
                }
                break;
              case Yodo1MasConstants.adTypeAppOpen:
                if (_appOpenCallback != null) {
                  _appOpenCallback!(code, message);
                }
                break;
              case Yodo1MasConstants.adTypeNative:
                if (_nativeCallback != null) {
                  _nativeCallback!(code, message);
                }
                break;
              case Yodo1MasConstants.adTypeBanner:
                if (_bannerCallback != null) {
                  _bannerCallback!(code, message);
                }
                break;
            }
          }
      }
      return Future<bool>.value(true);
    });

    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeInitSdk, {
      'app_key': appKey,
      'privacy': privacy,
      'ccpa': ccpa,
      'coppa': coppa,
      'gdpr': gdpr,
    });
  }

  @override
  Future<void> loadAd(String adType) async {
    log('Yodo1 Flutter SDK Channel Call - Load Ad - $adType');
    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeLoadAd, {
      'ad_type': adType,
    });
  }

  @override
  Future<bool> isAdLoaded(String adType) async {
    log('Yodo1 Flutter SDK Channel Call - Is Ad Loaded - $adType');
    final isLoaded = await methodChannel
        .invokeMethod<bool>(Yodo1MasConstants.methodNativeIsAdLoaded, {
      'ad_type': adType,
    });
    return isLoaded ?? false;
  }

  @override
  Future<void> showAd(String adType, {String? placementId}) async {
    log('Yodo1 Flutter SDK Channel Call - Show Ad $adType, $placementId');
    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeShowAd, {
      'ad_type': adType,
      'placement_id': placementId,
    });
  }

  @override
  void setInitListener(Function(bool successful)? callback) {
    _initCallback = callback;
  }

  @override
  void setRewardListener(Function(int event, String message)? callback) {
    _rewardCallback = callback;
  }

  @override
  void setInterstitialListener(Function(int event, String message)? callback) {
    _interstitialCallback = callback;
  }

  @override
  void setAppOpenListener(Function(int event, String message)? callback) {
    _appOpenCallback = callback;
  }

  @override
  void setBannerListener(Function(int event, String message)? callback) {
    _bannerCallback = callback;
  }

  @override
  void setNativeListener(Function(int event, String message)? callback) {
    _nativeCallback = callback;
  }

  @override
  Future<void> loadBannerAd({
    required double width,
    required double height,
    double? x,
    double? y,
  }) async {
    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeLoadAd, {
      'ad_type': Yodo1MasFlutterPlugin.adTypeBanner,
      'width': width,
      'height': height,
      'x': x,
      'y': y,
    });
  }
}
