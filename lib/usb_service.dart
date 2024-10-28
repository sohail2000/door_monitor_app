import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbService {
  UsbPort? _port;
  List<Widget> ports = [];
  Map<String, String> doorStatus = {
    'door1': 'Unknown',
    'door2': 'Unknown',
    'door3': 'Unknown',
    'door4': 'Unknown'
  };

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  UsbDevice? _device;

  // Getter for the _device field
  UsbDevice? get device => _device;

  Future<bool> connectTo(UsbDevice? device) async {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction!.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port!.close();
      _port = null;
    }

    if (device == null) {
      _device = null;
      return true;
    }

    _port = await device.create();
    if (await (_port!.open()) != true) {
      return false;
    }
    _device = device;

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port!.inputStream as Stream<Uint8List>, Uint8List.fromList([13, 10]));

    _subscription = _transaction!.stream.listen((String line) {
      parseDoorStatus(line);
    });

    return true;
  }

  void parseDoorStatus(String data) {
    final regex = RegExp(r'(door\d):(open|closed)', caseSensitive: false);
    final matches = regex.allMatches(data);

    for (final match in matches) {
      doorStatus[match.group(1)!] = match.group(2)!.capitalize();
    }
  }

  Future<void> initPortsListener(Function(List<Widget>) updatePorts) async {
    UsbSerial.usbEventStream!.listen((UsbEvent event) {
      getPorts(updatePorts);
    });
    await getPorts(updatePorts);
  }

  Future<void> getPorts(Function(List<Widget>) updatePorts) async {
    ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (!devices.contains(_device)) {
      connectTo(null);
    }

    for (var device in devices) {
      ports.add(
        ListTile(
          leading: const Icon(Icons.usb),
          title: Text(device.productName!),
          subtitle: Text(device.manufacturerName!),
          trailing: ElevatedButton(
            child: Text(_device == device ? "Disconnect" : "Connect"),
            onPressed: () {
              connectTo(_device == device ? null : device).then((res) {
                getPorts(updatePorts);
              });
            },
          ),
        ),
      );
    }

    updatePorts(ports);
  }

  void dispose() {
    connectTo(null);
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
