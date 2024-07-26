import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ActionsScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ActionsScreen({Key? key, required this.device}) : super(key: key);

  @override
  ActionsScreenState createState() => ActionsScreenState();
}

class ActionsScreenState extends State<ActionsScreen> {
  List<BluetoothService> _services = [];
  BluetoothCharacteristic? _ledCharacteristic,
      _doorCharacteristic,
      _temperatureCharacteristic;

  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  // Información del ESP32
  final serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  final ledCharacteristicUUID = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  final doorCharacteristicUUID = 'a1b2c3d4-5678-90ab-cdef-1234567890ab';
  final temperatureCharacteristicUUID = 'abcdef12-3456-7890-abcd-ef1234567890';

  bool _ledState = false;
  bool _doorState = false;
  double _temperature = 0.0;
  bool _isDiscoveringServices = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isDiscoveringServices = true;
    });

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        try {
          _services = await widget.device.discoverServices();

          // Buscar el servicio de led
          _ledCharacteristic = _services
              .expand((service) => service.characteristics)
              .firstWhere((characteristic) =>
                  characteristic.uuid.toString() == ledCharacteristicUUID);

          // Buscar el servicio de puerta
          _doorCharacteristic = _services
              .expand((service) => service.characteristics)
              .firstWhere((characteristic) =>
                  characteristic.uuid.toString() == doorCharacteristicUUID);

          // Buscar el servicio de temperatura
          _temperatureCharacteristic = _services
              .expand((service) => service.characteristics)
              .firstWhere((characteristic) =>
                  characteristic.uuid.toString() ==
                  temperatureCharacteristicUUID);

          // Obtener la temperatura
          await getTemperature();
        } catch (e) {
          print("Error discovering services: $e");
        } finally {
          setState(() {
            _isDiscoveringServices = false;
          });
        }
      }
    });
  }

  Future<void> getTemperature() async {
    if (_temperatureCharacteristic != null) {
      try {
        // Habilitar notificaciones
        await _temperatureCharacteristic!.setNotifyValue(true);

        // Suscribirse al stream de valores de la característica
        _temperatureCharacteristic!.lastValueStream.listen((value) {
          String tempString = utf8.decode(value);
          double temp = double.parse(tempString);
          setState(() {
            _temperature = temp;
          });
        });
      } catch (e) {
        print("Error setting up temperature notifications: $e");
      }
    }
  }

  void sendLedCommand(BluetoothCharacteristic characteristic, bool turnOn) {
    if (_ledCharacteristic != null) {
      String command = turnOn ? "on" : "off";
      List<int> bytes = utf8.encode(command);
      _ledCharacteristic!.write(bytes);
      setState(() {
        _ledState = turnOn;
      });
    }
  }

  void sendDoorCommand(BluetoothCharacteristic characteristic, bool action) {
    if (_doorCharacteristic != null) {
      String command = action ? "open" : "close";
      List<int> bytes = utf8.encode(command);
      _ledCharacteristic!.write(bytes);
      setState(() {
        _doorState = action;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: AppBar(
        title: const Text('Controlar dispositivos',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
        centerTitle: true,
      ),
      body: _isDiscoveringServices
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _ledState
                      ? const Icon(Icons.lightbulb,
                          color: Colors.blueAccent, size: 100)
                      : const Icon(Icons.lightbulb_outline,
                          color: Colors.grey, size: 100),
                  const SizedBox(height: 20),
                  Text(_ledState ? 'LED Encendido' : 'LED Apagado',
                      style: const TextStyle(color: Colors.white)),
                  Switch(
                    value: _ledState,
                    onChanged: (value) => onLedChangedHandler(value),
                  ),
                  const SizedBox(height: 40),
                  _doorState
                      ? const Icon(Icons.lock_open,
                          color: Colors.greenAccent, size: 100)
                      : const Icon(Icons.lock_outline,
                          color: Colors.redAccent, size: 100),
                  const SizedBox(height: 20),
                  Text(_doorState ? 'Puerta Abierta' : 'Puerta Cerrada',
                      style: const TextStyle(color: Colors.white)),
                  Switch(
                    value: _doorState,
                    onChanged: (value) => onDoorChangedHandler(value),
                  ),
                  const SizedBox(height: 40),
                  const Icon(Icons.thermostat,
                      color: Colors.orangeAccent, size: 100),
                  const SizedBox(height: 20),
                  Text('Temperatura: $_temperature °C',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  void onLedChangedHandler(bool value) {
    setState(() {
      _ledState = value;

      if (_ledCharacteristic != null) {
        sendLedCommand(_ledCharacteristic!, value);
      }
    });
  }

  void onDoorChangedHandler(bool value) {
    setState(() {
      _doorState = value;

      if (_ledCharacteristic != null) {
        sendDoorCommand(_ledCharacteristic!, value);
      }
    });
  }
}
