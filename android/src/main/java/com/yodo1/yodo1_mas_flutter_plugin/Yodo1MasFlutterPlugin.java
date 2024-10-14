package com.yodo1.yodo1_mas_flutter_plugin;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.yodo1.mas.Yodo1Mas;
import com.yodo1.mas.interstitial.Yodo1MasInterstitialAd;
import com.yodo1.mas.interstitial.Yodo1MasInterstitialAdListener;
import com.yodo1.mas.reward.Yodo1MasRewardAd;
import com.yodo1.mas.reward.Yodo1MasRewardAdListener;
import com.yodo1.mas.appopenad.Yodo1MasAppOpenAd;

/** Yodo1MasFlutterPlugin */
public class Yodo1MasFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity activity;
  private Context context;

  private static final String CHANNEL = "com.yodo1.mas/sdk";
  private static final String METHOD_NATIVE_INIT_SDK = "native_init_sdk";
  private static final String METHOD_NATIVE_IS_AD_LOADED = "native_is_ad_loaded";
  private static final String METHOD_NATIVE_LOAD_AD = "native_load_ad";
  private static final String METHOD_NATIVE_SHOW_AD = "native_show_ad";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case METHOD_NATIVE_INIT_SDK:
        handleInitSdk(call, result);
        break;
      case METHOD_NATIVE_LOAD_AD:
        handleLoadAd(call);
        result.success(null);
        break;
      case METHOD_NATIVE_IS_AD_LOADED:
        boolean isAdLoaded = handleIsAdLoaded(call);
        result.success(isAdLoaded);
        break;
      case METHOD_NATIVE_SHOW_AD:
        handleShowAd(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void handleInitSdk(MethodCall call, Result result) {
    String appKey = call.argument("app_key");
    boolean privacy = call.argument("privacy");
    boolean ccpa = call.argument("ccpa");
    boolean coppa = call.argument("coppa");
    boolean gdpr = call.argument("gdpr");

    if (appKey != null) {
      Yodo1MasAppOpenAd.getInstance().autoDelayIfLoadFail = true;
      Yodo1MasInterstitialAd.getInstance().autoDelayIfLoadFail = true;
      Yodo1MasRewardAd.getInstance().autoDelayIfLoadFail = true;
      initSdk(appKey, privacy, ccpa, coppa, gdpr);
      result.success(1);
    } else {
      result.error("INVALID_ARGUMENTS", "Invalid arguments for native_init_sdk", null);
    }
  }

  private void handleLoadAd(MethodCall call) {
    String type = call.argument("ad_type");
    if (type != null) {
      switch (type) {
        case "Reward":
          Yodo1MasRewardAd.getInstance().loadAd(activity);
          break;
        case "Interstitial":
          Yodo1MasInterstitialAd.getInstance().loadAd(activity);
          break;
        case "AppOpen":
          Yodo1MasAppOpenAd.getInstance().loadAd(activity);
          break;
        default:
          break;
      }
    }
  }

  private boolean handleIsAdLoaded(MethodCall call) {
    String type = call.argument("ad_type");
    if (type != null) {
      switch (type) {
        case "Reward":
          return Yodo1MasRewardAd.getInstance().isLoaded();
        case "Interstitial":
          return Yodo1MasInterstitialAd.getInstance().isLoaded();
        case "AppOpen":
          return Yodo1MasAppOpenAd.getInstance().isLoaded();
        default:
          return false;
      }
    }
    return false;
  }

  private void handleShowAd(MethodCall call) {
    String type = call.argument("ad_type");
    String placementId = call.argument("placement_id");
    if (type != null) {
      switch (type) {
        case "Reward":
          if (placementId != null) {
            Yodo1MasRewardAd.getInstance().showAd(activity, placementId);
          } else {
            Yodo1MasRewardAd.getInstance().showAd(activity);
          }
          break;
        case "Interstitial":
          if (placementId != null) {
            Yodo1MasInterstitialAd.getInstance().showAd(activity, placementId);
          } else {
            Yodo1MasInterstitialAd.getInstance().showAd(activity);
          }
          break;
        case "AppOpen":
          if (placementId != null) {
            Yodo1MasAppOpenAd.getInstance().showAd(activity, placementId);
          } else {
            Yodo1MasAppOpenAd.getInstance().showAd(activity);
          }
          break;
        default:
          break;
      }
    }
  }

  private void initSdk(String appKey, boolean privacy, boolean ccpa, boolean coppa, boolean gdpr) {
    // Initialize SDK with the provided parameters
    // Call the appropriate Yodo1Mas methods to set up the SDK
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
