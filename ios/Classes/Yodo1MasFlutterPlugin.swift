import Flutter
import UIKit
import Yodo1MasCore
import YYModel

public class Yodo1MasFlutterPlugin: NSObject, FlutterPlugin, Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate {
    
    private var controller: UIViewController?
    private weak var channel: FlutterMethodChannel?
    
    private let CHANNEL = "com.yodo1.mas/sdk"
    private let METHOD_NATIVE_INIT_SDK = "native_init_sdk"
    private let METHOD_NATIVE_IS_AD_LOADED = "native_is_ad_loaded"
    private let METHOD_NATIVE_LOAD_AD = "native_load_ad"
    private let METHOD_NATIVE_SHOW_AD = "native_show_ad"
    private let METHOD_FLUTTER_INIT_EVENT = "flutter_init_event"
    private let METHOD_FLUTTER_AD_EVENT = "flutter_ad_event"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.yodo1.mas/sdk", binaryMessenger: registrar.messenger())
        let instance = Yodo1MasFlutterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case METHOD_NATIVE_INIT_SDK:
            handleInitSdk(call: call, result: result)
        case METHOD_NATIVE_LOAD_AD:
            handleLoadAd(call: call)
            result(nil)
        case METHOD_NATIVE_IS_AD_LOADED:
            let isAdLoaded = handleIsAdLoaded(call: call)
            result(isAdLoaded)
        case METHOD_NATIVE_SHOW_AD:
            handleShowAd(call: call)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInitSdk(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appKey = args["app_key"] as? String,
              let privacy = args["privacy"] as? Bool,
              let ccpa = args["ccpa"] as? Bool,
              let coppa = args["coppa"] as? Bool,
              let gdpr = args["gdpr"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for native_init_sdk", details: nil))
            return
        }

        Yodo1MasAppOpenAd.sharedInstance().autoDelayIfLoadFail = true
        Yodo1MasInterstitialAd.sharedInstance().autoDelayIfLoadFail = true
        Yodo1MasRewardAd.sharedInstance().autoDelayIfLoadFail = true
        initSdk(appKey: appKey, privacy: privacy, ccpa: ccpa, coppa: coppa, gdpr: gdpr)
        result(1)
    }

    private func handleLoadAd(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let type = args["ad_type"] as? String else {
            return
        }
        switch type {
        case "Reward":
            Yodo1MasRewardAd.sharedInstance().load()
        case "Interstitial":
            Yodo1MasInterstitialAd.sharedInstance().load()
        case "AppOpen":
            Yodo1MasAppOpenAd.sharedInstance().load()
        default:
            break
        }
    }

    private func handleIsAdLoaded(call: FlutterMethodCall) -> Bool {
        guard let args = call.arguments as? [String: Any],
              let type = args["ad_type"] as? String else {
            return false
        }
        switch type {
        case "Reward":
            return Yodo1MasRewardAd.sharedInstance().isLoaded()
        case "Interstitial":
            return Yodo1MasInterstitialAd.sharedInstance().isLoaded()
        case "AppOpen":
            return Yodo1MasAppOpenAd.sharedInstance().isLoaded()
        default:
            return false
        }
    }

    private func handleShowAd(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let type = args["ad_type"] as? String,
              let placementId = args["placement_id"] as? String? else {
            return
        }
        switch type {
        case "Reward":
            if let placementId = placementId {
                Yodo1MasRewardAd.sharedInstance().show(withPlacement: placementId)
            } else {
                Yodo1MasRewardAd.sharedInstance().show()
            }
        case "Interstitial":
            if let placementId = placementId {
                Yodo1MasInterstitialAd.sharedInstance().show(withPlacement: placementId)
            } else {
                Yodo1MasInterstitialAd.sharedInstance().show()
            }
        case "AppOpen":
            if let placementId = placementId {
                Yodo1MasAppOpenAd.sharedInstance().show(withPlacement: placementId)
            } else {
                Yodo1MasAppOpenAd.sharedInstance().show()
            }
        default:
            break
        }
    }

    private func initSdk(appKey: String, privacy: Bool, ccpa: Bool, coppa: Bool, gdpr: Bool) {
        let config = Yodo1MasAdBuildConfig.instance()
        config.enableUserPrivacyDialog = privacy
        Yodo1Mas.sharedInstance().isCCPADoNotSell = ccpa
        Yodo1Mas.sharedInstance().isCOPPAAgeRestricted = coppa
        Yodo1Mas.sharedInstance().isGDPRUserConsent = gdpr
        Yodo1Mas.sharedInstance().setAdBuildConfig(config)
        
        Yodo1Mas.sharedInstance().initMas(withAppKey: appKey, successful: {
            self.channel?.invokeMethod(self.METHOD_FLUTTER_INIT_EVENT, arguments: ["successful": true])
        }, fail: { error in
            self.channel?.invokeMethod(self.METHOD_FLUTTER_INIT_EVENT, arguments: ["successful": false, "error": error?.getJsonObject()])
        })
    }

    // Delegate methods
    public func onAdOpened(_ event: Yodo1MasAdEvent) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: event.getJsonObject())
    }

    public func onAdClosed(_ event: Yodo1MasAdEvent) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: event.getJsonObject())
    }

    public func onAdError(_ event: Yodo1MasAdEvent, error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: event.getJsonObject())
    }

    public func onAdRewardEarned(_ event: Yodo1MasAdEvent) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: event.getJsonObject())
    }
}