import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:oxschool/constants/User.dart';

// DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
Map<String, dynamic> deviceData = <String, dynamic>{};

Map<String, dynamic> readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported32BitAbis': build.supported32BitAbis,
    'supported64BitAbis': build.supported64BitAbis,
    'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    'systemFeatures': build.systemFeatures,
    // 'displaySizeInches':
    //     ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
    // 'displayWidthPixels': build.displayMetrics.widthPx,
    // 'displayWidthInches': build.displayMetrics.widthInches,
    // 'displayHeightPixels': build.displayMetrics.heightPx,
    // 'displayHeightInches': build.displayMetrics.heightInches,
    // 'displayXDpi': build.displayMetrics.xDpi,
    // 'displayYDpi': build.displayMetrics.yDpi,
    'serialNumber': build.serialNumber,
  };
}

Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}

Map<String, dynamic> readWebBrowserInfo(WebBrowserInfo data) {
  return <String, dynamic>{
    'browserName': describeEnum(data.browserName),
    'appCodeName': data.appCodeName,
    'appName': data.appName,
    'appVersion': data.appVersion,
    'deviceMemory': data.deviceMemory,
    'language': data.language,
    'languages': data.languages,
    'platform': data.platform,
    'product': data.product,
    'productSub': data.productSub,
    'userAgent': data.userAgent,
    'vendor': data.vendor,
    'vendorSub': data.vendorSub,
    'hardwareConcurrency': data.hardwareConcurrency,
    'maxTouchPoints': data.maxTouchPoints,
  };
}

Map<String, dynamic> readMacOsDeviceInfo(MacOsDeviceInfo data) {
  return <String, dynamic>{
    'computerName': data.computerName,
    'hostName': data.hostName,
    'arch': data.arch,
    'model': data.model,
    'kernelVersion': data.kernelVersion,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'patchVersion': data.patchVersion,
    'osRelease': data.osRelease,
    'activeCPUs': data.activeCPUs,
    'memorySize': data.memorySize,
    'cpuFrequency': data.cpuFrequency,
    'systemGUID': data.systemGUID,
  };
}

Map<String, dynamic> readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    'userName': data.userName,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'buildNumber': data.buildNumber,
    'platformId': data.platformId,
    'csdVersion': data.csdVersion,
    'servicePackMajor': data.servicePackMajor,
    'servicePackMinor': data.servicePackMinor,
    'suitMask': data.suitMask,
    'productType': data.productType,
    'reserved': data.reserved,
    'buildLab': data.buildLab,
    'buildLabEx': data.buildLabEx,
    'digitalProductId': data.digitalProductId,
    'displayVersion': data.displayVersion,
    'editionId': data.editionId,
    'installDate': data.installDate,
    'productId': data.productId,
    'productName': data.productName,
    'registeredOwner': data.registeredOwner,
    'releaseId': data.releaseId,
    'deviceId': data.deviceId,
  };
}

String _getAppBarTitle() => kIsWeb
    ? 'Web Browser info'
    : switch (defaultTargetPlatform) {
        TargetPlatform.android => 'Android Device Info',
        TargetPlatform.iOS => 'iOS Device Info',
        TargetPlatform.linux => 'Linux Device Info',
        TargetPlatform.windows => 'Windows Device Info',
        TargetPlatform.macOS => 'MacOS Device Info',
        TargetPlatform.fuchsia => 'Fuchsia Device Info',
      };

Future getDeviceIP() async {
  var interface;
  String responseData = '';
  String ipFromDevice;
  var addr;
  for (interface in await NetworkInterface.list()) {
    for (addr in interface.addresses) {
      if (responseData.length <= 0) {
        responseData = 'ip:' +
            addr.address.toString() +
            ' | ' +
            'host:' +
            addr.host.toString() +
            ' | ' +
            'isLoopback:' +
            addr.isLoopback.toString() +
            ' | ' +
            'rawAddress:' +
            addr.rawAddress.toString() +
            ' | ' +
            'ipType: ' +
            addr.type.name.toString() +
            ' | ' +
            'isLinkLocal:' +
            addr.isLinkLocal.toString();
      }
    }
  }
  // Convert the result to a Dart object or Map
  Map<String, dynamic> requestBody = {
    'ip': addr.address.toString(),
    'host': addr.host.toString(),
    'isLoopback': addr.isLoopback.toString(),
    'rawAddress': addr.rawAddress.toString(),
    'ipType': addr.type.name.toString(),
    'isLinkLocal': addr.isLinkLocal.toString()
    // Add more fields as needed
  };

  // Convert the Dart object to JSON
  ipFromDevice = jsonEncode(requestBody);
  deviceIp = ipFromDevice;

  return ipFromDevice;
}

//  Future<void> _initNetworkInfo() async {
//     String? wifiName,
//         wifiBSSID,
//         wifiIPv4,
//         wifiIPv6,
//         wifiGatewayIP,
//         wifiBroadcast,
//         wifiSubmask;

//     try {
//       if (!kIsWeb && Platform.isIOS) {
//         // ignore: deprecated_member_use
//         var status = await networkInfo.getLocationServiceAuthorization();
//         if (status == LocationAuthorizationStatus.notDetermined) {
//           // ignore: deprecated_member_use
//           status = await networkInfo.requestLocationServiceAuthorization();
//         }
//         if (status == LocationAuthorizationStatus.authorizedAlways ||
//             status == LocationAuthorizationStatus.authorizedWhenInUse) {
//           wifiName = await networkInfo.getWifiName();
//         } else {
//           wifiName = await networkInfo.getWifiName();
//         }
//       } else {
//         wifiName = await networkInfo.getWifiName();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi Name', error: e);
//       wifiName = 'Failed to get Wifi Name';
//     }

//     try {
//       if (!kIsWeb && Platform.isIOS) {
//         // ignore: deprecated_member_use
//         var status = await networkInfo.getLocationServiceAuthorization();
//         if (status == LocationAuthorizationStatus.notDetermined) {
//           // ignore: deprecated_member_use
//           status = await networkInfo.requestLocationServiceAuthorization();
//         }
//         if (status == LocationAuthorizationStatus.authorizedAlways ||
//             status == LocationAuthorizationStatus.authorizedWhenInUse) {
//           wifiBSSID = await networkInfo.getWifiBSSID();
//         } else {
//           wifiBSSID = await networkInfo.getWifiBSSID();
//         }
//       } else {
//         wifiBSSID = await networkInfo.getWifiBSSID();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi BSSID', error: e);
//       wifiBSSID = 'Failed to get Wifi BSSID';
//     }

//     try {
//       wifiIPv4 = await networkInfo.getWifiIP();
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi IPv4', error: e);
//       wifiIPv4 = 'Failed to get Wifi IPv4';
//     }

//     try {
//       if (!Platform.isWindows) {
//         wifiIPv6 = await networkInfo.getWifiIPv6();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi IPv6', error: e);
//       wifiIPv6 = 'Failed to get Wifi IPv6';
//     }

//     try {
//       if (!Platform.isWindows) {
//         wifiSubmask = await networkInfo.getWifiSubmask();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi submask address', error: e);
//       wifiSubmask = 'Failed to get Wifi submask address';
//     }

//     try {
//       if (!Platform.isWindows) {
//         wifiBroadcast = await networkInfo.getWifiBroadcast();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi broadcast', error: e);
//       wifiBroadcast = 'Failed to get Wifi broadcast';
//     }

//     try {
//       if (!Platform.isWindows) {
//         wifiGatewayIP = await networkInfo.getWifiGatewayIP();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi gateway address', error: e);
//       wifiGatewayIP = 'Failed to get Wifi gateway address';
//     }


//   }

