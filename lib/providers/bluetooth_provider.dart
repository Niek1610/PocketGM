import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/legacy.dart';

// ESP32 BLE Service and Characteristic UUIDs
const String ESP32_SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String BUTTON_CHARACTERISTIC_UUID =
    "beb5483e-36e1-4688-b7f5-ea07361b26a8";
const String MOTOR_CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

enum ButtonEvent { none, button1, button2 }

class BluetoothProvider extends ChangeNotifier {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  BluetoothCharacteristic? _buttonCharacteristic;
  BluetoothCharacteristic? _motorCharacteristic;
  StreamSubscription? _buttonSubscription;

  final _buttonEventController = StreamController<ButtonEvent>.broadcast();
  Stream<ButtonEvent> get buttonEvents => _buttonEventController.stream;

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
      ) async {
        _connectionState = connectionState;
        notifyListeners();
        if (connectionState == BluetoothConnectionState.disconnected) {
          _buttonCharacteristic = null;
          _motorCharacteristic = null;
          _buttonSubscription?.cancel();
        } else if (connectionState == BluetoothConnectionState.connected) {
          await _discoverServices();
        }
      });

      // Discover services immediately after connection
      await _discoverServices();
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    try {
      print('Discovering services...');
      List<BluetoothService> services = await _connectedDevice!
          .discoverServices();

      print('Found ${services.length} services');
      for (BluetoothService service in services) {
        print('Service: ${service.uuid}');
        if (service.uuid.toString().toLowerCase() ==
            ESP32_SERVICE_UUID.toLowerCase()) {
          print('Found ESP32 service!');
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            String charUuid = characteristic.uuid.toString().toLowerCase();
            print('Characteristic: $charUuid');

            if (charUuid == BUTTON_CHARACTERISTIC_UUID.toLowerCase()) {
              _buttonCharacteristic = characteristic;
              print('Button characteristic found!');
              await _subscribeToButtonNotifications();
            } else if (charUuid == MOTOR_CHARACTERISTIC_UUID.toLowerCase()) {
              _motorCharacteristic = characteristic;
              print('Motor characteristic found!');
            }
          }
        }
      }
      print('Motor characteristic available: ${_motorCharacteristic != null}');
      notifyListeners();
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  Future<void> _subscribeToButtonNotifications() async {
    if (_buttonCharacteristic == null) return;

    try {
      await _buttonCharacteristic!.setNotifyValue(true);
      _buttonSubscription?.cancel();
      _buttonSubscription = _buttonCharacteristic!.onValueReceived.listen((
        value,
      ) {
        if (value.isNotEmpty) {
          int buttonValue = value[0];
          if (buttonValue == 1) {
            _buttonEventController.add(ButtonEvent.button1);
          } else if (buttonValue == 2) {
            _buttonEventController.add(ButtonEvent.button2);
          }
        }
      });
    } catch (e) {
      print('Error subscribing to button notifications: $e');
    }
  }

  /// Send vibration command to ESP32
  /// [duration] in milliseconds
  Future<void> sendVibration(int duration) async {
    print('sendVibration called with duration: $duration');
    print('Motor characteristic: $_motorCharacteristic');
    print('isConnectedToEsp32: $isConnectedToEsp32');

    if (_motorCharacteristic == null) {
      print('Motor characteristic not available');
      return;
    }

    try {
      // Send duration as 2 bytes (little endian)
      final bytes = Uint8List(2);
      bytes[0] = duration & 0xFF;
      bytes[1] = (duration >> 8) & 0xFF;
      print('Sending bytes: $bytes');
      await _motorCharacteristic!.write(bytes, withoutResponse: true);
      print('Vibration command sent successfully');
    } catch (e) {
      print('Error sending vibration: $e');
    }
  }

  /// Send vibration pattern to ESP32
  /// Pattern format (same as Android Vibration library):
  /// [vibrate_ms, pause_ms, vibrate_ms, pause_ms, ...]
  /// Even indices = vibrate duration, Odd indices = pause duration
  Future<void> sendVibrationPattern(List<int> pattern) async {
    for (int i = 0; i < pattern.length; i++) {
      int duration = pattern[i];
      if (duration <= 0) continue;

      if (i % 2 == 0) {
        // Even index = vibrate
        await sendVibration(duration);
        await Future.delayed(Duration(milliseconds: duration));
        // Explicitly stop motor after vibration
        await sendVibration(0);
      } else {
        // Odd index = pause (motor is already off)
        await Future.delayed(Duration(milliseconds: duration));
      }
    }
  }

  bool get isConnectedToEsp32 =>
      _connectionState == BluetoothConnectionState.connected &&
      _buttonCharacteristic != null &&
      _motorCharacteristic != null;

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      _buttonSubscription?.cancel();
      _buttonCharacteristic = null;
      _motorCharacteristic = null;
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
    _buttonSubscription?.cancel();
    _buttonEventController.close();
    super.dispose();
  }
}

final bluetoothProvider = ChangeNotifierProvider<BluetoothProvider>((ref) {
  return BluetoothProvider();
});
