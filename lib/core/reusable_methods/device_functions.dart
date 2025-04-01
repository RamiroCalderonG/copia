import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/core/utils/device_information.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeCurrentDeviceIsMobile() async {
  var deviceData = <String, bool>{};
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  try {
    if (kIsWeb) {
      devicePrefs.setBool('isMobile', false);
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          devicePrefs.setBool('isMobile', true);
          break;
        case TargetPlatform.iOS:
          devicePrefs.setBool('isMobile', true);
          break;
        case TargetPlatform.linux:
          devicePrefs.setBool('isMobile', false);
          break;
        case TargetPlatform.windows:
          devicePrefs.setBool('isMobile', false);
          break;
        case TargetPlatform.macOS:
          devicePrefs.setBool('isMobile', false);
          break;
        case TargetPlatform.fuchsia:
          devicePrefs.setBool('isMobile', false);
          break;
      }
    }
  } on PlatformException {
    devicePrefs.setBool('isMobile', false);
  }
}

dynamic isCurrentDeviceMobile() async {
  return await getIsMobileFromPrefs();
}

Future<bool> getIsMobileFromPrefs() async {
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  return devicePrefs.getBool('isMobile') ?? false;
}


/* Future<String?> getDeviceMacAddress() async {
  try {
    final info = NetworkInfo();
    // Retrieve the MAC address
    String? macAddress = await info.getWifiBSSID(); 
    final wifiName = await info.getWifiName(); // "FooNetwork"
final wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
final wifiIP = await info.getWifiIP(); // 192.168.1.43
final wifiIPv6 = await info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
final wifiSubmask = await info.getWifiSubmask(); // 255.255.255.0
final wifiBroadcast = await info.getWifiBroadcast(); // 192.168.1.255
final wifiGateway = await info.getWifiGatewayIP(); // BSSID is often the MAC address
    return macAddress;
  } catch (e) {
    print("Error retrieving MAC address: $e");
    return null;
  }
} */