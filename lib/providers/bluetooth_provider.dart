import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/legacy.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;

  BluetoothProvider() {
    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    // Listen to scanning state
    FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      notifyListeners();
    });
  }

  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothConnectionState get connectionState => _connectionState;

  Future<void> startScan() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    await stopScan();

    try {
      await device.connect();
      _connectedDevice = device;
      notifyListeners();

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((
        connectionState,
      ) {
        _connectionState = connectionState;
        notifyListeners();
        if (connectionState == BluetoothConnectionState.disconnected) {}
      });
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _connectionState = BluetoothConnectionState.disconnected;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

final bluetoothProvider = ChangeNotifierProvider<BluetoothProvider>((ref) {
  return BluetoothProvider();
});
