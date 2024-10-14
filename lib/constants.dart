class Yodo1MASConstants {
  static const String CHANNEL = "com.yodo1.mas/sdk";
  static const String METHOD_NATIVE_INIT_SDK = "native_init_sdk";
  static const String METHOD_NATIVE_IS_AD_LOADED = "native_is_ad_loaded";
  static const String METHOD_NATIVE_LOAD_AD = "native_load_ad";
  static const String METHOD_NATIVE_SHOW_AD = "native_show_ad";
  static const String METHOD_FLUTTER_INIT_EVENT = "flutter_init_event";
  static const String METHOD_FLUTTER_AD_EVENT = "flutter_ad_event";

  // Type of event
  static const AD_TYPE_REWARD = 1;
  static const AD_TYPE_INTERSTITIAL = 2;
  static const AD_TYPE_APP_OPEN = 4;

  // Type of code
  static const AD_EVENT_OPENED = 1001;
  static const AD_EVENT_CLOSED = 1002;
  static const AD_EVENT_ERROR = 1003;
  static const AD_EVENT_EARNED = 2001;
}