# Device Identifier Manager

A Flutter plugin to get a unique identifier for the device. Supports iOS and Android. 

## Installation
To use package in your own project add the following lines into pubspec.yaml file.

```yaml
unique_and_permanent_device_identifier:
  git:
    url: https://github.com/enesakbal/Device-Identifier-Manager.git
    ref: main
```


### iOS
We can save data permanently on iOS devices using the flutter_secure_storage package. The stored data remains even if it's deleted from the app on the phone. In the flutter_secure_storage package, data is stored in maps like {"key": value}.

The DeviceIdentifierManager class on iOS simply does this: it tries to read existing data using a pre-set key. If data exists, it returns that; if not, it uses the uuid package to create a new UUID. It then saves this UUID in the keychain. This way, we can retrieve the UUID value later.

**Note: It's crucial that the key value is unique to our app. If our key value mixes with keys from other apps, we might face unwanted issues.**

```dart
final currentId = await _secureStorage.read(key: _baseKey) ?? '';
if (currentId.isEmpty) {
  final generatedId = uuid.v4();
  await _secureStorage.write(key: _baseKey, value: generatedId);

  return generatedId;
  }

return currentId;
```
---

### Android
The DeviceIdentifierManager class uses the device_info_plus package on Android devices. By using the device_info_plus package, we can obtain the device ID of the device. DeviceIdentifierManager class generates a unique identifier using the v5 method of the Uuid object, which generates a UUID using the SHA-1 hash of a namespace identifier and a name. The name is a string created by concatenating the baseKey, device's ID, fingerprint, model, host, and whether it's a physical device.

**However, the device ID may not always be in UUID format**. This is where the uuid package comes into play. It is used to convert the device ID to UUID format. By using the same device ID, we consistently obtain the same UUID.
```dart
final info = await _deviceInfoPlugin.androidInfo;

final deviceId = info.id;
final deviceFingerprint = info.fingerprint;
final deviceModel = info.model;
final deviceHost = info.host;
final isPhysicalDevice = info.isPhysicalDevice;

final id = uuid.v5(
  Uuid.NAMESPACE_URL,
  '$deviceId$deviceFingerprint$deviceModel$deviceHost$isPhysicalDevice$_baseKey',
);

return id;
```

---

## Usage

In your main.dart file, initialize the DeviceIdentifierManager class with a base key. This key is used to store the UUID value in the keychain. It's important that this key is unique to your app. If you use a different key than the previous one, you cannot access your previous data.

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import 'device_identifier_manager/device_identifier_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeviceIdentifierManager.initialize('sample_base_key');

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final String deviceId;
  late final String deviceModel;
  late final String deviceName;
  late final String deviceOSVersion;
  late final String deviceAPILevel;

  final ValueNotifier<bool> _isInitialized = ValueNotifier(false);

  @override
  void initState() {
    Future.wait([
      DeviceIdentifierManager.instance.getDeviceId(),
      DeviceIdentifierManager.instance.getDeviceModel(),
      DeviceIdentifierManager.instance.getDeviceName(),
      DeviceIdentifierManager.instance.getDeviceOSVersion(),
      DeviceIdentifierManager.instance.getAPILevel(),
    ]).then((value) {
      setState(() {
        deviceId = value[0];
        deviceModel = value[1];
        deviceName = value[2];
        deviceOSVersion = value[3];
        deviceAPILevel = value[4];
        _isInitialized.value = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: _isInitialized,
          builder: (context, value, child) {
            if (value) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Device ID: $deviceId'),
                    Text('Device Model: $deviceModel'),
                    Text('Device Name: $deviceName'),
                    if (Platform.isAndroid) Text('Device API level: $deviceAPILevel'),
                    Text('Device OS Version: $deviceOSVersion'),
                  ],
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
```

## Support
If encounter any problems in package or add want new features feel free to contact me, open issue or pull request.

## Contact Me
[![LinkedIn](https://img.shields.io/badge/linkedin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/enesakbl/)
[![Medium](https://img.shields.io/badge/Medium-12100E?style=for-the-badge&logo=medium&logoColor=white)](https://medium.com/@enesakbal00)

enesakbal00@gmail.com


created by ea.




