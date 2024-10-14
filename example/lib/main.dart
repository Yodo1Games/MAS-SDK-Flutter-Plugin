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
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _yodo1MasFlutterPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
