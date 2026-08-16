import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdService {
  DeviceIdService();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const AndroidId _androidId = AndroidId();

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      final id = await _androidId.getId();

      if (id == null || id.isEmpty) {
        throw StateError('Could not read Android ID.');
      }

      return id;
    }

    if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      final id = info.identifierForVendor;

      if (id == null || id.isEmpty) {
        throw StateError('Could not read identifierForVendor.');
      }

      return id;
    }

    throw UnsupportedError('Attendance is only supported on Android and iOS.');
  }
}
