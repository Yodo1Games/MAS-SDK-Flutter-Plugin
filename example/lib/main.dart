import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
    _yodo1MasFlutterPlugin.initSdk("JR835c6fza", true, true, false, false);
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
                onPressed: () => loadAd('interstitial'),
                child: const Text('Load Interstitial Ad'),
              ),
              ElevatedButton(
                onPressed: () => showAd('interstitial'),
                child: const Text('Show Interstitial Ad'),
              ),
              ElevatedButton(
                onPressed: () => loadAd('rewarded'),
                child: const Text('Load Rewarded Ad'),
              ),
              ElevatedButton(
                onPressed: () => showAd('rewarded'),
                child: const Text('Show Rewarded Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
