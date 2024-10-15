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

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(Yodo1MasConstants.channel);

  @override
  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) async {
    methodChannel.setMethodCallHandler((call) {
      String method = call.method;
      log('Method call: $method');
      switch(call.method) {
        case Yodo1MasConstants.methodFlutterInitEvent: {
          bool successful = call.arguments["successful"];
          log('SDK Init Status: $successful');
          if (_initCallback != null) {
            _initCallback!(successful);
          }
          return Future<bool>.value(true);
        }
        case Yodo1MasConstants.methodFlutterAdEvent: {
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

          log('Flutter event type: $type');
          log('Flutter event code: $code');
          log('Flutter event message: $message');

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
    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeLoadAd, {
      'ad_type': adType,
    });
  }

  @override
  Future<bool> isAdLoaded(String adType) async {
    final isLoaded = await methodChannel.invokeMethod<bool>(Yodo1MasConstants.methodNativeIsAdLoaded, {
      'ad_type': adType,
    });
    return isLoaded ?? false;
  }

  @override
  Future<void> showAd(String adType, {String? placementId}) async {
    await methodChannel.invokeMethod(Yodo1MasConstants.methodNativeShowAd, {
      'ad_type': adType,
      'placement_id': placementId,
    });
  }


  void setRewardListener(Function(int event, String message)? callback) {
    _rewardCallback = callback;
  }

  void setInterstitialListener(Function(int event, String message)? callback) {
    _interstitialCallback = callback;
  }

  void setAppOpenListener(Function(int event, String message)? callback) {
    _appOpenCallback = callback;
  }


}
