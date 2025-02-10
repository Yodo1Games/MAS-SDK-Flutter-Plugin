class Yodo1MasConstants {
  static const String channel = "com.yodo1.mas/sdk";
  static const String methodNativeInitSdk = "native_init_sdk";
  static const String methodNativeIsAdLoaded = "native_is_ad_loaded";
  static const String methodNativeLoadAd = "native_load_ad";
  static const String methodNativeShowAd = "native_show_ad";
  static const String methodFlutterInitEvent = "flutter_init_event";
  static const String methodFlutterAdEvent = "flutter_ad_event";

  // Type of event
  static const int adTypeReward = 1;
  static const int adTypeInterstitial = 2;
  static const int adTypeAppOpen = 3;
  static const int adTypeBanner = 4;
  static const int adTypeNative = 5;


  // Type of code
  static const int adEventOpened = 1001;
  static const int adEventClosed = 1002;
  static const int adEventFailedToOpen = 1003;
  static const int adEventLoaded = 1004;
  static const int adEventFailedToLoad = 1005;
  static const int adEventEarned = 2001;
}
