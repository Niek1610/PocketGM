import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/providers/bluetooth_provider.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';

class BluetoothScreen extends ConsumerStatefulWidget {
  const BluetoothScreen({super.key});

  @override
  ConsumerState<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends ConsumerState<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    // Start scanning when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bluetoothProvider).startScan();
    });
  }

  @override
  void dispose() {
    // Stop scanning when screen closes
    // We might want to keep scanning if we are in the process of connecting?
    // But generally good practice to stop.
    // ref.read(bluetoothProvider).stopScan(); // Can't call ref in dispose easily without storing it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetooth = ref.watch(bluetoothProvider);

    return AppScaffold(
      title: 'Connect PocketGM',
      actions: [
        if (bluetooth.isScanning)
          IconButton(
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(white),
              ),
            ),
            onPressed: () => ref.read(bluetoothProvider).stopScan(),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bluetoothProvider).startScan(),
          ),
      ],
      body: Column(
        children: [
          if (bluetooth.connectedDevice != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.2),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connected to:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              bluetooth.connectedDevice!.platformName.isNotEmpty
                                  ? bluetooth.connectedDevice!.platformName
                                  : bluetooth.connectedDevice!.remoteId
                                        .toString(),
                              style: const TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(bluetoothProvider).disconnect(),
                        child: const Text(
                          'Disconnect',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(bluetoothProvider).sendVibration(500);
                    },
                    icon: const Icon(Icons.vibration),
                    label: const Text('Test Motor (500ms)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: bluetooth.scanResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bluetooth.isScanning
                              ? 'Scanning for devices...'
                              : 'No devices found',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        if (!bluetooth.isScanning)
                          TextButton(
                            onPressed: () =>
                                ref.read(bluetoothProvider).startScan(),
                            child: const Text('Scan Again'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: bluetooth.scanResults.length,
                    itemBuilder: (context, index) {
                      final result = bluetooth.scanResults[index];
                      final device = result.device;
                      final isConnected =
                          bluetooth.connectedDevice?.remoteId ==
                          device.remoteId;

                      return ListTile(
                        leading: const Icon(Icons.bluetooth, color: white),
                        title: Text(
                          device.platformName.isNotEmpty
                              ? device.platformName
                              : 'Unknown Device',
                          style: const TextStyle(color: white),
                        ),
                        subtitle: Text(
                          device.remoteId.toString(),
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: isConnected
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  foregroundColor: white,
                                ),
                                onPressed: () {
                                  ref.read(bluetoothProvider).connect(device);
                                },
                                child: const Text('Connect'),
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
