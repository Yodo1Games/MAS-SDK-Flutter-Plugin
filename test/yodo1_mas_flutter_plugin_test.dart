import 'package:flutter_test/flutter_test.dart';
import 'package:yodo1_mas_flutter_plugin/yodo1_mas_flutter_plugin.dart';
import 'package:yodo1_mas_flutter_plugin/yodo1_mas_flutter_plugin_platform_interface.dart';
import 'package:yodo1_mas_flutter_plugin/yodo1_mas_flutter_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockYodo1MasFlutterPluginPlatform
    with MockPlatformInterfaceMixin
    implements Yodo1MasFlutterPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final Yodo1MasFlutterPluginPlatform initialPlatform = Yodo1MasFlutterPluginPlatform.instance;

  test('$MethodChannelYodo1MasFlutterPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelYodo1MasFlutterPlugin>());
  });

  test('getPlatformVersion', () async {
    Yodo1MasFlutterPlugin yodo1MasFlutterPlugin = Yodo1MasFlutterPlugin();
    MockYodo1MasFlutterPluginPlatform fakePlatform = MockYodo1MasFlutterPluginPlatform();
    Yodo1MasFlutterPluginPlatform.instance = fakePlatform;

    expect(await yodo1MasFlutterPlugin.getPlatformVersion(), '42');
  });
}
