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
