import 'dart:async';
import 'package:flutter/material.dart';
import 'usb_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  UsbService _usbService = UsbService();
  String _status = "Idle";

  @override
  void initState() {
    super.initState();
    _usbService.initPortsListener(_updatePorts);
  }

  void _updatePorts(List<Widget> ports) {
    setState(() {
      _usbService.ports = ports;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usbService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Door Monitor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text(
                _usbService.ports.isNotEmpty
                    ? "Available Serial Ports"
                    : "No serial devices available",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ..._usbService.ports,
              const SizedBox(height: 10),
              Text('Status: $_status'),
              Text(
                  "Connected Device: ${_usbService.device?.productName ?? 'None'}"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: _usbService.doorStatus.entries.map((entry) {
                    return Card(
                      color: entry.value == "Open"
                          ? Colors.green[100]
                          : Colors.red[50],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.value == "Open"
                                  ? Icons.door_front_door
                                  : Icons.door_back_door,
                              color: entry.value == "Open"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            Text(entry.key.toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            Text('Status: ${entry.value}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
