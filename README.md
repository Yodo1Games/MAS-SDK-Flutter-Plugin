# yodo1_mas_flutter_plugin

Official flutter plugin to support the latest Yodo1 MAS SDK. For platform specific configuration, please view the documentation below:

- [Android](https://developers.yodo1.com/docs/sdk/getting_started/configure/android)
- [iOS](https://developers.yodo1.com/docs/sdk/getting_started/configure/ios)

## Features

This plugin supports all new ad types and features supported by [Yodo1 MAS](https://www.yodo1.com/mobile-game-monetization/) SDK, sticking to flutter best practices.

| Ad Type            | Support | Plugin Constant | Example |
|--------------------|---------|-----------------|---------|
| App Open Ads       | ✅      | Yodo1MasFlutterPlugin.adTypeAppOpen | [Link](./example/lib/main.dart#L86) |
| Interstitial Ads   | ✅      | Yodo1MasFlutterPlugin.adTypeInterstitial | [Link](./example/lib/main.dart#L94) |
| Rewarded Ads       | ✅      | Yodo1MasFlutterPlugin.adTypeRewarded | [Link](./example/lib/main.dart#L102) |
| Banner Ads         | 🔨      |                  |         |
| Native Ads         | 🔨      |                  |         |

## Initialization

To initialize the plugin, you need to call the `initSdk` method with your app key and listener methods. Here’s an example of how to do this:

```dart
// Initialize plugin variable
final _yodo1MasFlutterPlugin = Yodo1MasFlutterPlugin();

// Initialize plugin
@override
void initState() {
    super.initState();
    /**
     * Initialize MAS SDK with the parameters
     * appKey - Your appKey from MAS Dashboard
     * privacy (bool) - Whether to use MAS privacy dialog or your own
     * ccpa (bool) - See https://developers.yodo1.com/docs/sdk/getting_started/legal/ccpa
     * coppa (bool) - See https://developers.yodo1.com/docs/sdk/getting_started/legal/coppa
     * gdpr (bool) - See https://developers.yodo1.com/docs/sdk/getting_started/legal/gdpr
     */
    yodo1MasFlutterPlugin.initSdk("<your appKey>", true, true, false, false);
    // You may also listen to flutter initialization statuses
    yodo1MasFlutterPlugin.setInitListener((bool successful) {
        print('Yodo1 Flutter Init status $successful');
    });
}

```

## Loading Ads

To load an ad, use the `loadAd` method with the ad type as a parameter. Here’s an example:

```dart
await yodo1MasFlutterPlugin.loadAd(Yodo1MasFlutterPlugin.adTypeAppOpen);
```

## Checking if Ads are Loaded

You can check if an ad is loaded by using the `isAdLoaded` method. Here’s how you can do it:

```dart
bool isLoaded = await yodo1MasFlutterPlugin.isAdLoaded(Yodo1MasFlutterPlugin.adTypeAppOpen);
```

## Displaying Ads

To show an ad, use the `showAd` method with the ad type as a parameter. Here’s an example:

```dart
await yodo1MasFlutterPlugin.showAd(Yodo1MasFlutterPlugin.adTypeAppOpen);
```

## Adding Listeners

You can add different listeners for various ad types and initialization by using the following methods:

- **Initialization Listener**:
  ```dart
  _yodo1MasFlutterPlugin.setInitListener((bool successful) {
    print('Yodo1 Flutter Init successful $successful');
  });
  ```

- **Interstitial Listener**:
  ```dart
  _yodo1MasFlutterPlugin.setInterstitialListener((int code, String message) {
    print('Yodo1 Flutter Callback Interstitial $code $message');
  });
  ```

- **Reward Listener**:
  ```dart
  _yodo1MasFlutterPlugin.setRewardListener((int code, String message) {
    print('Yodo1 Flutter Callback Rewarded $code $message');
  });
  ```

- **App Open Listener**:
  ```dart
  _yodo1MasFlutterPlugin.setAppOpenListener((int code, String message) {
    print('Yodo1 Flutter Callback AppOpen $code $message');
  });
  ```

Make sure to replace `<your appKey>` with your actual app key for the SDK.

