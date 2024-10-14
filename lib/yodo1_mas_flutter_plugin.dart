
import 'yodo1_mas_flutter_plugin_platform_interface.dart';

class Yodo1MasFlutterPlugin {
  Future<String?> getPlatformVersion() {
    return Yodo1MasFlutterPluginPlatform.instance.getPlatformVersion();
  }
}
