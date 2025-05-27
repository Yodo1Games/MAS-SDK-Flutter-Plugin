import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yodo1_mas_flutter_plugin/constants.dart';
import 'package:yodo1_mas_flutter_plugin/yodo1_mas_flutter_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _yodo1MasFlutterPlugin = Yodo1MasFlutterPlugin();

  @override
  void initState() {
    super.initState();
    initMASSdk();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initMASSdk() async {
    _yodo1MasFlutterPlugin.setInitListener((bool successful) {
      print('Yodo1 Flutter Init successful $successful');
    });

    _yodo1MasFlutterPlugin.setInterstitialListener((int code, String message) {
      bool value = code == Yodo1MasConstants.adEventOpened;
      print('Comparison value $value');
      if (code == Yodo1MasConstants.adEventOpened) {
        print('Yodo1 Flutter Interstitial Opened $code $message');
      }
      print('Yodo1 Flutter Callback Interstitial $code $message');
    });

    _yodo1MasFlutterPlugin.setRewardListener((int code, String message) {
      if (code == Yodo1MasConstants.adEventOpened) {
        print('Yodo1 Flutter Rewarded Opened $code $message');
      }
      print('Yodo1 Flutter Callback Rewarded $code $message');
    });

    _yodo1MasFlutterPlugin.setAppOpenListener((int code, String message) {
      if (code == Yodo1MasConstants.adEventOpened) {
        print('Yodo1 Flutter AppOpen Opened $code $message');
      }
      print('Yodo1 Flutter Callback AppOpen $code $message');
    });

    // Initialize the SDK
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      _yodo1MasFlutterPlugin.initSdk("ESYQW9ZMA8", true, true, false, false);
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      _yodo1MasFlutterPlugin.initSdk(
          "V2CG7NR8Bo", true, true, false, false);
    }
  }

  Future<void> loadAd(String adType) async {
    try {
      await _yodo1MasFlutterPlugin.loadAd(adType);
      print('$adType ad loaded successfully.');
    } catch (e) {
      print('Failed to load $adType ad: $e');
    }
  }

  Future<void> showAd(String adType) async {
    bool isLoaded = await _yodo1MasFlutterPlugin.isAdLoaded(adType);
    print('Loaded $isLoaded $adType');
    if (!isLoaded) {
      print('Ad type $adType is not loaded');
    }
    try {
      await _yodo1MasFlutterPlugin.showAd(adType);
      print('$adType ad shown successfully.');
    } catch (e) {
      print('Failed to show $adType ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Yodo1 Flutter Plugin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () => loadAd(Yodo1MasFlutterPlugin.adTypeAppOpen),
                child: const Text('Load AppOpen Ad'),
              ),
              ElevatedButton(
                onPressed: () => showAd(Yodo1MasFlutterPlugin.adTypeAppOpen),
                child: const Text('Show AppOpen Ad'),
              ),
              ElevatedButton(
                onPressed: () =>
                    loadAd(Yodo1MasFlutterPlugin.adTypeInterstitial),
                child: const Text('Load Interstitial Ad'),
              ),
              ElevatedButton(
                onPressed: () =>
                    showAd(Yodo1MasFlutterPlugin.adTypeInterstitial),
                child: const Text('Show Interstitial Ad'),
              ),
              ElevatedButton(
                onPressed: () => loadAd(Yodo1MasFlutterPlugin.adTypeRewarded),
                child: const Text('Load Rewarded Ad'),
              ),
              ElevatedButton(
                onPressed: () => showAd(Yodo1MasFlutterPlugin.adTypeRewarded),
                child: const Text('Show Rewarded Ad'),
              ),
              ElevatedButton(
                onPressed: () => _yodo1MasFlutterPlugin.loadBannerAd(
                  width: 320,
                  height: 50,
                  x: 0, // Optional for iOS
                  y: 0, // Optional for iOS
                ),
                child: const Text('Load Banner Ad'),
              ),
              ElevatedButton(
                onPressed: () => showAd(Yodo1MasFlutterPlugin.adTypeBanner),
                child: const Text('Show Banner Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
