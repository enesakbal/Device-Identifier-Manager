import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

part 'iphone_device_models.dart';

/// A class that manages the device identifier, model, name, OS version, and API level.
///
/// This class provides methods to retrieve the unique device identifier, device model,
/// device name, device OS version, and API level. It uses the `device_info_plus` package
/// to get the device information and the `flutter_secure_storage` package to securely
/// store the device identifier.
///
/// To use this class, you need to call the `initialize` method with a base key before
/// accessing any of the device information methods. The base key is used as the key
/// to store the device identifier in the secure storage.
///
/// Example usage:
/// ```dart
/// DeviceIdentifierManager.initialize('my_base_key');
/// String deviceId = await DeviceIdentifierManager.instance.getDeviceId();
/// String deviceModel = await DeviceIdentifierManager.instance.getDeviceModel();
/// String deviceName = await DeviceIdentifierManager.instance.getDeviceName();
/// String deviceOSVersion = await DeviceIdentifierManager.instance.getDeviceOSVersion();
/// String apiLevel = await DeviceIdentifierManager.instance.getAPILevel();
/// ```

class DeviceIdentifierManager {
  final FlutterSecureStorage _secureStorage;
  final DeviceInfoPlugin _deviceInfoPlugin;

  static DeviceIdentifierManager? _instance;

  static late String _baseKey;

  static bool isInitialized = false;

  DeviceIdentifierManager._(this._deviceInfoPlugin, this._secureStorage);

  /// Initializes the DeviceIdentifierManager with the provided [baseKey].
  /// Throws an exception if the DeviceIdentifierManager is already initialized.
  ///
  /// The [baseKey] is used as a base for generating unique and permanent device identifiers.
  ///
  /// Example usage:
  /// ```dart
  /// DeviceIdentifierManager.initialize('myBaseKey');
  /// ```
  static void initialize(String baseKey) {
    if (isInitialized) throw Exception('DeviceIdentifierManager is already initialized');

    _baseKey = baseKey;
    _instance ??= DeviceIdentifierManager._(
      DeviceInfoPlugin(),
      const FlutterSecureStorage(),
    );

    isInitialized = true;
  }

  static DeviceIdentifierManager get instance =>
      _instance ??= DeviceIdentifierManager._(DeviceInfoPlugin(), const FlutterSecureStorage());

  /// Retrieves the unique device identifier.
  ///
  /// Throws an exception if the [DeviceIdentifierManager] is not initialized.
  ///
  /// Returns the device identifier as a [String].
  ///
  /// If the platform is iOS, it checks if the current device identifier is empty.
  /// If it is empty, it generates a new identifier using the [Uuid] library,
  /// stores it in the secure storage, and returns the generated identifier.
  /// If it is not empty, it returns the current identifier.
  ///
  /// If the platform is Android, it retrieves the device ID using the [_deviceInfoPlugin]
  /// and generates a new identifier using the [Uuid] library with the device ID as the input.
  ///
  /// Throws an exception if the platform is unsupported.
  Future<String> getDeviceId() async {
    if (!isInitialized) throw Exception('DeviceIdentifierManager is not initialized');
    const uuid = Uuid();

    if (Platform.isIOS) {
      final currentId = await _secureStorage.read(key: _baseKey) ?? '';

      if (currentId.isEmpty) {
        final generatedId = uuid.v4();
        await _secureStorage.write(key: _baseKey, value: generatedId);
        return generatedId;
      }

      return currentId;
    } else if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      final deviceId = info.id;

      final id = uuid.v5(Uuid.NAMESPACE_URL, deviceId);

      return id;
    }

    throw Exception('Unsupported platform');
  }

  /// Retrieves the device model of the current device.
  ///
  /// This method uses the `device_info` plugin to get the device information.
  /// If the platform is Android, it retrieves the model from the Android device info.
  /// If the platform is iOS, it retrieves the model from the iOS device info.
  /// If the platform is neither Android nor iOS, it throws an exception.
  ///
  /// Returns the device model as a [String].
  Future<String> getDeviceModel() async {
    if (!isInitialized) throw Exception('DeviceIdentifierManager is not initialized');

    late final String deviceModel;

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      deviceModel = info.model;
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;

      deviceModel = _devices[info.utsname.machine] ?? 'unknown';
    } else {
      throw Exception('Unsupported platform');
    }
    return deviceModel;
  }

  /// Retrieves the device name.
  ///
  /// This method returns the name of the device on which the app is running.
  /// If the platform is Android, it retrieves the model name from the Android device information.
  /// If the platform is iOS, it retrieves the node name from the iOS device information.
  /// Throws an exception if the platform is unsupported.
  ///
  /// Returns the device name as a [String].
  Future<String> getDeviceName() async {
    if (!isInitialized) throw Exception('DeviceIdentifierManager is not initialized');

    late final String deviceName;

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      deviceName = info.model;
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;

      deviceName = info.utsname.nodename;
    } else {
      throw Exception('Unsupported platform');
    }
    return deviceName;
  }

  /// Retrieves the device's operating system version.
  ///
  /// Returns a [Future] that completes with a [String] representing the device's operating system version.
  /// Throws an [Exception] if the platform is not supported.
  Future<String> getDeviceOSVersion() async {
    if (!isInitialized) throw Exception('DeviceIdentifierManager is not initialized');

    late final String deviceOSVersion;

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      deviceOSVersion = 'Android ${info.version.release}';
    } else if (Platform.isIOS) {
      final info = await _deviceInfoPlugin.iosInfo;

      deviceOSVersion = 'IOS ${info.systemVersion}';
    } else {
      throw Exception('Unsupported platform');
    }
    return deviceOSVersion;
  }

  /// Retrieves the API level of the device.
  ///
  /// If the platform is Android, it uses the `_deviceInfoPlugin` to get the Android device information
  /// and returns the SDK version as a string. Otherwise, it returns an empty string.
  ///
  /// Returns:
  /// - The SDK version as a string if the platform is Android.
  /// - An empty string if the platform is not Android.
  Future<String> getAPILevel() async {
    if (!isInitialized) throw Exception('DeviceIdentifierManager is not initialized');

    if (Platform.isAndroid) {
      final info = await _deviceInfoPlugin.androidInfo;
      return info.version.sdkInt.toString();
    }

    return '';
  }
}
