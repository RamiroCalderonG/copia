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

Future<dynamic> getDeviceDetails() async {
  var deviceData = <String, dynamic>{};
  try {
    if (kIsWeb) {
      deviceData = readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          var androidInfo = await deviceInfoPlugin.androidInfo;
          deviceData = readAndroidBuildData(androidInfo);
          break;
        case TargetPlatform.iOS:
          var iosInfo = await deviceInfoPlugin.iosInfo;
          deviceData = readIosDeviceInfo(iosInfo);
          break;
        case TargetPlatform.linux:
          var linuxInfo = await deviceInfoPlugin.linuxInfo;
          deviceData = readLinuxDeviceInfo(linuxInfo);
          break;
        case TargetPlatform.windows:
          var windowsInfo = await deviceInfoPlugin.windowsInfo;
          deviceData = readWindowsDeviceInfo(windowsInfo);
          break;
        case TargetPlatform.macOS:
          var macOsInfo = await deviceInfoPlugin.macOsInfo;
          deviceData = readMacOsDeviceInfo(macOsInfo);
          break;
        case TargetPlatform.fuchsia:
          deviceData = <String, dynamic>{
            'Error:': 'Fuchsia platform isn\'t supported'
          };
          break;
      }

      return deviceData;
      // SharedPreferences devicePrefs = await SharedPreferences.getInstance();
      // devicePrefs.setString('device', currentDeviceData);
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }
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