import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static StreamSubscription<List<ScanResult>>? _scanSubscription;

  /// Check whether Bluetooth is supported.
  static Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }

  /// Check current Bluetooth state.
  static Stream<BluetoothAdapterState> get adapterState {
    return FlutterBluePlus.adapterState;
  }

  /// Scan for nearby BLE devices.
  static Future<List<ScanResult>> scanForDevices({
    Duration duration = const Duration(seconds: 8),
  }) async {
    final List<ScanResult> devices = [];

    await stopScan();

    final completer = Completer<List<ScanResult>>();

    _scanSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        devices.clear();

        final Map<String, ScanResult> uniqueDevices = {};

        for (final result in results) {
          final id = result.device.remoteId.str;
          uniqueDevices[id] = result;
        }

        devices.addAll(uniqueDevices.values);
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );

    FlutterBluePlus.cancelWhenScanComplete(_scanSubscription!);

    await FlutterBluePlus.startScan(
      timeout: duration,
    );

    await FlutterBluePlus.isScanning
        .where((value) => value == false)
        .first;

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    if (!completer.isCompleted) {
      completer.complete(devices);
    }

    return completer.future;
  }

  /// Connect to a BLE device.
  static Future<void> connect(BluetoothDevice device) async {
    await device.connect(
      timeout: const Duration(seconds: 10),
      autoConnect: false,
    );
  }

  /// Disconnect from a BLE device.
  static Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }

  /// Discover BLE services.
  static Future<List<BluetoothService>> discoverServices(
    BluetoothDevice device,
  ) async {
    return await device.discoverServices();
  }

  /// Stop scanning.
  static Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}

    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }
}