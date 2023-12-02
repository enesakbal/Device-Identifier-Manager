import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'device_identifier_manager/device_identifier_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log(DeviceIdentifierManager.isInitialized.toString());
  DeviceIdentifierManager.initialize('sample_base_key');

  final id = await DeviceIdentifierManager.instance.getDeviceId();
  log(id);

  log(DeviceIdentifierManager.isInitialized.toString());
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
            }),
      ),
    );
  }
}
