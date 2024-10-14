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
  final methodChannel = const MethodChannel(Yodo1MASConstants.CHANNEL);

  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) async {
    methodChannel.setMethodCallHandler((call) {

      switch(call.method) {

        case Yodo1MASConstants.METHOD_FLUTTER_INIT_EVENT: {

          bool successful = call.arguments["successful"];
          if (_initCallback != null) {
            _initCallback!(successful);
          }
          return Future<bool>.value(true);
        }
        case Yodo1MASConstants.METHOD_FLUTTER_AD_EVENT: {
          int type, code;
          String message;
          if (defaultTargetPlatform == TargetPlatform.android)
          {
            Map<String, dynamic> map = json.decode(call.arguments);
             type = map["type"];
             code = map["code"];
             message = map["message"];
          }
          else
            {
               type = call.arguments["type"];
               code = call.arguments["code"];
               message = call.arguments["message"];
            }

          log(type.toString());
          log(code.toString());
          log(message);
        }

      }
      return Future<bool>.value(true);
    });
    await methodChannel.invokeMethod(Yodo1MASConstants.METHOD_NATIVE_INIT_SDK, {
      'app_key': appKey,
      'privacy': privacy,
      'ccpa': ccpa,
      'coppa': coppa,
      'gdpr': gdpr,
    });
  }

  Future<void> loadAd(String adType) async {
    await methodChannel.invokeMethod(Yodo1MASConstants.METHOD_NATIVE_LOAD_AD, {
      'ad_type': adType,
    });
  }

  Future<bool> isAdLoaded(String adType) async {
    final isLoaded = await methodChannel.invokeMethod<bool>(Yodo1MASConstants.METHOD_NATIVE_IS_AD_LOADED, {
      'ad_type': adType,
    });
    return isLoaded ?? false;
  }

  Future<void> showAd(String adType, {String? placementId}) async {
    await methodChannel.invokeMethod(Yodo1MASConstants.METHOD_NATIVE_SHOW_AD, {
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
