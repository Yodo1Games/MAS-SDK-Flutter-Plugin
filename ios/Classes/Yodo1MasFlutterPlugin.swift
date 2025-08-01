import Flutter
import UIKit
import Yodo1MasCore
import YYModel

public class Yodo1MasFlutterPlugin: NSObject, FlutterPlugin, Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate {
    
    private var controller: UIViewController?
    private weak var channel: FlutterMethodChannel?
    
    private static let CHANNEL = "com.yodo1.mas/sdk"
    private let METHOD_NATIVE_INIT_SDK = "native_init_sdk"
    private let METHOD_NATIVE_IS_AD_LOADED = "native_is_ad_loaded"
    private let METHOD_NATIVE_LOAD_AD = "native_load_ad"
    private let METHOD_NATIVE_SHOW_AD = "native_show_ad"
    private let METHOD_FLUTTER_INIT_EVENT = "flutter_init_event"
    private let METHOD_FLUTTER_AD_EVENT = "flutter_ad_event"
    private let AD_TYPE_REWARDED_NAME = "Rewarded"
    private let AD_TYPE_INTERSTITIAL_NAME = "Interstitial"
    private let AD_TYPE_APP_OPEN_NAME = "AppOpen"
    private let AD_TYPE_BANNER_NAME = "Banner"
    private let AD_TYPE_NATIVE_NAME = "Native"

    // Ad Type Codes
    private let AD_TYPE_REWARDED = 1
    private let AD_TYPE_INTERSTITIAL = 2
    private let AD_TYPE_APP_OPEN = 3
    private let AD_TYPE_BANNER = 4
    private let AD_TYPE_NATIVE = 5

    // Event Type Codes
    private let AD_EVENT_OPENED = 1001
    private let AD_EVENT_CLOSED = 1002
    private let AD_EVENT_FAILED_TO_OPEN = 1003
    private let AD_EVENT_LOADED = 1004
    private let AD_EVENT_FAILED_TO_LOAD = 1005
    private let AD_EVENT_EARNED = 2001

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Yodo1MasFlutterPlugin.CHANNEL, binaryMessenger: registrar.messenger())
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
        initSdk(appKey: appKey, privacy: privacy, ccpa: ccpa, coppa: coppa, gdpr: gdpr)
        result(1)
    }

    private func handleLoadAd(call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let type = args["ad_type"] as? String else {
            return
        }
        switch type {
        case self.AD_TYPE_REWARDED_NAME:
            Yodo1MasRewardAd.sharedInstance().adDelegate = self
            Yodo1MasRewardAd.sharedInstance().autoDelayIfLoadFail = true
            Yodo1MasRewardAd.sharedInstance().load()
        case self.AD_TYPE_INTERSTITIAL_NAME:
            Yodo1MasInterstitialAd.sharedInstance().adDelegate = self
            Yodo1MasInterstitialAd.sharedInstance().autoDelayIfLoadFail = true
            Yodo1MasInterstitialAd.sharedInstance().load()
        case self.AD_TYPE_APP_OPEN_NAME:
            Yodo1MasInterstitialAd.sharedInstance().adDelegate = self
            Yodo1MasAppOpenAd.sharedInstance().autoDelayIfLoadFail = true
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
        case self.AD_TYPE_REWARDED_NAME:
            return Yodo1MasRewardAd.sharedInstance().isLoaded()
        case self.AD_TYPE_INTERSTITIAL_NAME:
            return Yodo1MasInterstitialAd.sharedInstance().isLoaded()
        case self.AD_TYPE_APP_OPEN_NAME:
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
        case self.AD_TYPE_REWARDED_NAME:
            if let placementId = placementId {
                Yodo1MasRewardAd.sharedInstance().show(withPlacement: placementId)
            } else {
                Yodo1MasRewardAd.sharedInstance().show()
            }
        case self.AD_TYPE_INTERSTITIAL_NAME:
            if let placementId = placementId {
                Yodo1MasInterstitialAd.sharedInstance().show(withPlacement: placementId)
            } else {
                Yodo1MasInterstitialAd.sharedInstance().show()
            }
        case self.AD_TYPE_APP_OPEN_NAME:
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
            self.channel?.invokeMethod(self.METHOD_FLUTTER_INIT_EVENT, arguments: ["successful": false, "error": error.getJsonObject()])
        })
    }
    
    

}

extension Yodo1MasFlutterPlugin: Yodo1MasRewardDelegate {
    public func onRewardAdLoaded(_ ad: Yodo1MasRewardAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_LOADED])
    }

    public func onRewardAdFailed(toLoad ad: Yodo1MasRewardAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_FAILED_TO_LOAD])
    }

    public func onRewardAdOpened(_ ad: Yodo1MasRewardAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_OPENED])
    }

    public func onRewardAdFailed(toOpen ad: Yodo1MasRewardAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_FAILED_TO_OPEN])
    }

    public func onRewardAdClosed(_ ad: Yodo1MasRewardAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_CLOSED])
    }

    public func onRewardAdEarned(_ ad: Yodo1MasRewardAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_REWARDED, "code": AD_EVENT_EARNED])
    }
}

extension Yodo1MasFlutterPlugin: Yodo1MasInterstitialDelegate {
    public func onInterstitialAdLoaded(_ ad: Yodo1MasInterstitialAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_INTERSTITIAL, "code": AD_EVENT_LOADED])
    }

    public func onInterstitialAdFailed(toLoad ad: Yodo1MasInterstitialAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_INTERSTITIAL, "code": AD_EVENT_FAILED_TO_LOAD])
    }

    public func onInterstitialAdOpened(_ ad: Yodo1MasInterstitialAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_INTERSTITIAL, "code": AD_EVENT_OPENED])
    }

    public func onInterstitialAdFailed(toOpen ad: Yodo1MasInterstitialAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_INTERSTITIAL, "code": AD_EVENT_FAILED_TO_LOAD])
    }

    public func onInterstitialAdClosed(_ ad: Yodo1MasInterstitialAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_INTERSTITIAL, "code": AD_EVENT_CLOSED])
    }
}

extension Yodo1MasFlutterPlugin: Yodo1MasAppOpenAdDelegate {
    public func onAppOpenAdLoaded(_ ad: Yodo1MasAppOpenAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_APP_OPEN, "code": AD_EVENT_LOADED])
    }

    public func onAppOpenAdFailed(toLoad ad: Yodo1MasAppOpenAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_APP_OPEN, "code": AD_EVENT_FAILED_TO_LOAD])
    }

    public func onAppOpenAdOpened(_ ad: Yodo1MasAppOpenAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_APP_OPEN, "code": AD_EVENT_OPENED])
    }

    public func onAppOpenAdFailed(toOpen ad: Yodo1MasAppOpenAd, withError error: Yodo1MasError) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_APP_OPEN, "code": AD_EVENT_FAILED_TO_OPEN])
    }
    

    public func onAppOpenAdClosed(_ ad: Yodo1MasAppOpenAd) {
        channel?.invokeMethod(METHOD_FLUTTER_AD_EVENT, arguments: ["type": AD_TYPE_APP_OPEN, "code": AD_EVENT_CLOSED])
    }
}
