package com.yodo1.yodo1_mas_flutter_plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.yodo1.mas.Yodo1Mas;
import com.yodo1.mas.appopenad.Yodo1MasAppOpenAdListener;
import com.yodo1.mas.error.Yodo1MasError;
import com.yodo1.mas.helper.model.Yodo1MasAdBuildConfig;
import com.yodo1.mas.interstitial.Yodo1MasInterstitialAd;
import com.yodo1.mas.interstitial.Yodo1MasInterstitialAdListener;
import com.yodo1.mas.reward.Yodo1MasRewardAd;
import com.yodo1.mas.reward.Yodo1MasRewardAdListener;
import com.yodo1.mas.appopenad.Yodo1MasAppOpenAd;

import org.json.JSONException;
import org.json.JSONObject;

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
  private static final String METHOD_FLUTTER_INIT_EVENT = "flutter_init_event";
  private static final String METHOD_FLUTTER_AD_EVENT = "flutter_ad_event";
  private static final String AD_TYPE_REWARDED_NAME = "Rewarded";
  private static final String AD_TYPE_INTERSTITIAL_NAME = "Interstitial";
  private static final String AD_TYPE_APP_OPEN_NAME = "AppOpen";

  // Ad Type Codes
  static final int AD_TYPE_REWARD = 1;
  static final int AD_TYPE_INTERSTITIAL = 2;
  static final int AD_TYPE_APP_OPEN = 4;

  // Ad Event Codes
  static final int AD_EVENT_OPENED = 1001;
  static final int AD_EVENT_CLOSED = 1002;
  static final int AD_EVENT_FAILED_TO_OPEN = 1003;
  static final int AD_EVENT_LOADED = 1004;
  static final int AD_EVENT_FAILED_TO_LOAD = 1005;
  static final int AD_EVENT_EARNED = 2001;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    initializeEventListeners();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.d("Yodo1MasFlutterPlugin", "onMethodCall: " + call.method);
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
      Yodo1MasAdBuildConfig config = new Yodo1MasAdBuildConfig.Builder().enableUserPrivacyDialog(privacy).build();
      Yodo1Mas.getInstance().setCCPA(ccpa);
      Yodo1Mas.getInstance().setCOPPA(coppa);
      Yodo1Mas.getInstance().setGDPR(gdpr);
      Yodo1Mas.getInstance().setAdBuildConfig(config);
      Yodo1Mas.getInstance().initMas(activity, appKey, new Yodo1Mas.InitListener() {
        @Override
        public void onMasInitSuccessful() {
          JSONObject initEvent = new JSONObject();
          try {
            initEvent.put("successful", true);
          } catch (JSONException e) {
            e.printStackTrace();
          }
          Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Callback - Init Successful - " + initEvent.toString());
          channel.invokeMethod(METHOD_FLUTTER_INIT_EVENT, initEvent.toString());
          result.success(1);
        }

        @Override
        public void onMasInitFailed(@NonNull Yodo1MasError error) {
          JSONObject initEvent = new JSONObject();
          try {
            initEvent.put("successful", false);
            initEvent.put("error", error.getJsonObject());
          } catch (JSONException e) {
            e.printStackTrace();
          }
          Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Callback - Init Failed - " + initEvent.toString());
          channel.invokeMethod(METHOD_FLUTTER_INIT_EVENT, initEvent.toString());
          result.error("INIT_FAILED", error.getMessage(), null);
        }
      });

    } else {
      result.error("INVALID_ARGUMENTS", "Invalid arguments for native_init_sdk", null);
    }
  }

  private void handleLoadAd(MethodCall call) {
    String type = call.argument("ad_type");
    if (type != null) {
      Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Channel Call - Load Ad - " + type);
      switch (type) {
        case Yodo1MasFlutterPlugin.AD_TYPE_REWARDED_NAME:
          Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Channel Call - Loading Rewarded Ad - " + type);
          activity.runOnUiThread(() -> {
            Yodo1MasRewardAd.getInstance().autoDelayIfLoadFail = true;
            Yodo1MasRewardAd.getInstance().loadAd(activity);
          });
          break;
        case Yodo1MasFlutterPlugin.AD_TYPE_INTERSTITIAL_NAME:
          Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Channel Call - Loading Interstitial Ad - " + type);
          activity.runOnUiThread(() -> {
            Yodo1MasInterstitialAd.getInstance().autoDelayIfLoadFail = true;
            Yodo1MasInterstitialAd.getInstance().loadAd(activity);
          });
          break;
        case Yodo1MasFlutterPlugin.AD_TYPE_APP_OPEN_NAME:
          Log.d("Yodo1MasFlutterPlugin", "Flutter SDK Channel Call - Loading AppOpenAd Ad - " + type);
          activity.runOnUiThread(() -> {
            Yodo1MasAppOpenAd.getInstance().autoDelayIfLoadFail = true;
            Yodo1MasAppOpenAd.getInstance().loadAd(activity);
          });
          break;
        default:
          break;
      }
    }
  }

  private boolean handleIsAdLoaded(MethodCall call) {
    String type = call.argument("ad_type");
    Log.d("Yodo1MasFlutterPlugin", "handleIsAdLoaded call arguments: " + call.arguments);
    if (type != null) {
      switch (type) {
        case Yodo1MasFlutterPlugin.AD_TYPE_REWARDED_NAME:
          return Yodo1MasRewardAd.getInstance().isLoaded();
        case Yodo1MasFlutterPlugin.AD_TYPE_INTERSTITIAL_NAME:
          return Yodo1MasInterstitialAd.getInstance().isLoaded();
        case Yodo1MasFlutterPlugin.AD_TYPE_APP_OPEN_NAME:
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
    Log.d("Yodo1MasFlutterPlugin", "handleIsAdLoaded call arguments: " + call.arguments);
    if (type != null) {
      switch (type) {
        case Yodo1MasFlutterPlugin.AD_TYPE_REWARDED_NAME:
          activity.runOnUiThread(() -> {
            if (placementId != null) {
              Yodo1MasRewardAd.getInstance().showAd(activity, placementId);
            } else {
              Yodo1MasRewardAd.getInstance().showAd(activity);
            }
          });
          break;
        case Yodo1MasFlutterPlugin.AD_TYPE_INTERSTITIAL_NAME:
          activity.runOnUiThread(() -> {
            if (placementId != null) {
              Yodo1MasInterstitialAd.getInstance().showAd(activity, placementId);
            } else {
              Yodo1MasInterstitialAd.getInstance().showAd(activity);
            }
          });
          break;
        case Yodo1MasFlutterPlugin.AD_TYPE_APP_OPEN_NAME:
          activity.runOnUiThread(() -> {
            if (placementId != null) {
              Yodo1MasAppOpenAd.getInstance().showAd(activity, placementId);
            } else {
              Yodo1MasAppOpenAd.getInstance().showAd(activity);
            }
          });
          break;
        default:
          break;
      }
    }
  }

  private void initializeEventListeners() {
    // Initialize Rewarded Ad listeners
    Yodo1MasRewardAd.getInstance().setAdListener(new Yodo1MasRewardAdListener() {
      @Override
      public void onRewardAdLoaded(Yodo1MasRewardAd ad) {
        // Code to be executed when an ad finishes loading.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_LOADED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }


      @Override
      public void onRewardAdFailedToLoad(Yodo1MasRewardAd ad, @NonNull Yodo1MasError error) {
        // Code to be executed when an ad request fails.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_FAILED_TO_LOAD);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }


      @Override
      public void onRewardAdOpened(Yodo1MasRewardAd ad) {
        // Code to be executed when an ad opens an overlay that
        // covers the screen.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_OPENED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }


      @Override
      public void onRewardAdFailedToOpen(Yodo1MasRewardAd ad, @NonNull Yodo1MasError error) {
        // Code to be executed when an ad open fails.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_FAILED_TO_OPEN);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }


      @Override
      public void onRewardAdClosed(Yodo1MasRewardAd ad) {
        // Code to be executed when the user is about to return
        // to the app after tapping on an ad.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_CLOSED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onRewardAdEarned(Yodo1MasRewardAd ad) {
        // Code to be executed when the user is about to return
        // to the app after tapping on an ad.
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_REWARD);
          adEvent.put("code", AD_EVENT_EARNED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }
    });
    // Initialize Interstitial Ad listeners
    Yodo1MasInterstitialAd.getInstance().setAdListener(new Yodo1MasInterstitialAdListener() {
      @Override
      public void onInterstitialAdLoaded(Yodo1MasInterstitialAd ad) {
        JSONObject adEvent = new JSONObject();
        Log.d("Yodo1MasFlutterPlugin", "onInterstitialAdLoaded 1");
        try {
          adEvent.put("type", AD_TYPE_INTERSTITIAL);
          adEvent.put("code", AD_EVENT_LOADED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        Log.d("Yodo1MasFlutterPlugin", "onInterstitialAdLoaded 1" + METHOD_FLUTTER_AD_EVENT + " - " + adEvent.toString());
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onInterstitialAdFailedToLoad(Yodo1MasInterstitialAd ad, @NonNull Yodo1MasError error) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_INTERSTITIAL);
          adEvent.put("code", AD_EVENT_FAILED_TO_LOAD);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onInterstitialAdOpened(Yodo1MasInterstitialAd ad) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_INTERSTITIAL);
          adEvent.put("code", AD_EVENT_OPENED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onInterstitialAdFailedToOpen(Yodo1MasInterstitialAd ad, @NonNull Yodo1MasError error) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_INTERSTITIAL);
          adEvent.put("code", AD_EVENT_FAILED_TO_OPEN);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onInterstitialAdClosed(Yodo1MasInterstitialAd ad) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_INTERSTITIAL);
          adEvent.put("code", AD_EVENT_CLOSED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }
    });
    // Initialize App Open Ads listeners
    Yodo1MasAppOpenAd.getInstance().setAdListener(new Yodo1MasAppOpenAdListener() {
      @Override
      public void onAppOpenAdLoaded(Yodo1MasAppOpenAd ad) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_APP_OPEN);
          adEvent.put("code", AD_EVENT_LOADED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onAppOpenAdFailedToLoad(Yodo1MasAppOpenAd ad, @NonNull Yodo1MasError error) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_APP_OPEN);
          adEvent.put("code", AD_EVENT_FAILED_TO_LOAD);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onAppOpenAdOpened(Yodo1MasAppOpenAd ad) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_APP_OPEN);
          adEvent.put("code", AD_EVENT_OPENED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onAppOpenAdFailedToOpen(Yodo1MasAppOpenAd ad, @NonNull Yodo1MasError error) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_APP_OPEN);
          adEvent.put("code", AD_EVENT_FAILED_TO_OPEN);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }

      @Override
      public void onAppOpenAdClosed(Yodo1MasAppOpenAd ad) {
        JSONObject adEvent = new JSONObject();
        try {
          adEvent.put("type", AD_TYPE_APP_OPEN);
          adEvent.put("code", AD_EVENT_CLOSED);
        } catch (JSONException e) {
          e.printStackTrace();
        }
        channel.invokeMethod(METHOD_FLUTTER_AD_EVENT, adEvent.toString());
      }
    });
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
