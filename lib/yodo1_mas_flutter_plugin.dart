import 'yodo1_mas_flutter_plugin_platform_interface.dart';

class Yodo1MasFlutterPlugin {
  
  Future<void> initSdk(String appKey, bool privacy, bool ccpa, bool coppa, bool gdpr) {
    return Yodo1MasFlutterPluginPlatform.instance.initSdk(appKey, privacy, ccpa, coppa, gdpr);
  }

  Future<void> loadAd(String adType) {
    return Yodo1MasFlutterPluginPlatform.instance.loadAd(adType);
  }

  Future<bool> isAdLoaded(String adType) {
    return Yodo1MasFlutterPluginPlatform.instance.isAdLoaded(adType);
  }

  Future<void> showAd(String adType, {String? placementId}) {
    return Yodo1MasFlutterPluginPlatform.instance.showAd(adType, placementId: placementId);
  }

}
