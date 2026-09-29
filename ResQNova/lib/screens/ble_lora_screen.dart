import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/ble_service.dart';

class BleLoraScreen extends StatefulWidget {
  const BleLoraScreen({super.key});

  @override
  State<BleLoraScreen> createState() => _BleLoraScreenState();
}

class _BleLoraScreenState extends State<BleLoraScreen> {
  List<ScanResult> devices = [];

  bool isScanning = false;
  String status = 'Bluetooth ready';

  @override
  void initState() {
    super.initState();
    checkBluetooth();
  }

  Future<void> checkBluetooth() async {
    final supported = await BleService.isSupported();

    if (!supported) {
      setState(() {
        status = 'Bluetooth LE is not supported';
      });
      return;
    }

    FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;

      setState(() {
        if (state == BluetoothAdapterState.on) {
          status = 'Bluetooth is ON';
        } else {
          status = 'Bluetooth is OFF';
        }
      });
    });
  }

  Future<void> scanDevices() async {
    try {
      setState(() {
        isScanning = true;
        devices.clear();
        status = 'Scanning for BLE devices...';
      });

      final state = await FlutterBluePlus.adapterState.first;

      if (state != BluetoothAdapterState.on) {
        setState(() {
          isScanning = false;
          status = 'Please turn ON Bluetooth';
        });
        return;
      }

      final results = await BleService.scanForDevices(
        duration: const Duration(seconds: 8),
      );

      if (!mounted) return;

      setState(() {
        devices = results;
        isScanning = false;
        status = '${devices.length} BLE device(s) found';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isScanning = false;
        status = 'BLE error: $e';
      });
    }
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Connecting to ${device.platformName.isEmpty ? "device" : device.platformName}...',
          ),
        ),
      );

      await BleService.connect(device);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BLE device connected successfully'),
        ),
      );

      final services = await BleService.discoverServices(device);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('BLE Services'),
            content: Text(
              'Device: ${device.platformName.isEmpty ? "Unknown device" : device.platformName}\n\n'
              'Services found: ${services.length}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: $e'),
        ),
      );
    }
  }

  String getDeviceName(ScanResult result) {
    final name = result.advertisementData.advName;

    if (name.isNotEmpty) {
      return name;
    }

    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }

    return 'Unknown BLE Device';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE + LoRa Network'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bluetooth Low Energy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(status),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isScanning ? null : scanDevices,
                    icon: Icon(
                      isScanning
                          ? Icons.bluetooth_searching
                          : Icons.bluetooth,
                    ),
                    label: Text(
                      isScanning
                          ? 'SCANNING...'
                          : 'SCAN BLE DEVICES',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: devices.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_disabled,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No BLE devices found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap "SCAN BLE DEVICES" to search',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final result = devices[index];
                      final device = result.device;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.bluetooth,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            getDeviceName(result),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${device.remoteId.str}\n'
                            'Signal: ${result.rssi} dBm',
                          ),
                          isThreeLine: true,
                          trailing: ElevatedButton(
                            onPressed: () => connectDevice(device),
                            child: const Text('CONNECT'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}