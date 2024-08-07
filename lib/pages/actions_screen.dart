import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path/path.dart';

class ActionsScreen extends StatefulWidget {
  final BluetoothDevice device;
  final String username;
  final String imagePath;
  final String type = 'sala-principal';


  const ActionsScreen({Key? key, required this.device, required this.username, required this.imagePath}) : super(key: key);  

  //ActionsScreen({Key? key}) : super(key: key);

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

  String _title = 'Sala principal';
  String _assetName = 'assets/img/sala.svg';

  Widget getSvg() {
    return SvgPicture.asset(_assetName, height: 150, width: 150);
  }

  @override
  void initState() {
    print(widget.device);

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
                  characteristic.uuid.toString() == temperatureCharacteristicUUID);

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

  void sendLedCommand(bool turnOn) {
    if (_ledCharacteristic != null) {
      String command = turnOn ? "on" : "off";
      List<int> bytes = utf8.encode(command);
      _ledCharacteristic!.write(bytes);
      print('LED: ' + turnOn.toString());
      setState(() {
        _ledState = turnOn;
      });
    }
  }

  void sendDoorCommand(bool action) {
    if (_doorCharacteristic != null) {
      String command = action ? "open" : "close";
      List<int> bytes = utf8.encode(command);
      _doorCharacteristic!.write(bytes);
      setState(() {
        _doorState = action;
      });
    }
  }

    void changeMainScreen(String route) {
    if (route == 'sala') {
      setState(() {
        _title = 'Sala principal';
        _assetName = 'assets/img/sala.svg';
      });
    } else if (route == 'habitacion1') {
      setState(() {
        _title = 'Habitación 1';
        _assetName = 'assets/img/habitacion.svg';
      });
    } else if (route == 'habitacion2') {
      setState(() {
        _title = 'Habitación 2';
        _assetName = 'assets/img/habitacion.svg';
      });
    }
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('Dispositivos'),
            onTap: () {
              print('Regresando a dispositivos BT...');
            },
          ),
          ListTile(
            leading: Icon(Icons.chair),
            title: Text('Sala principal'),
            onTap: () => {
              changeMainScreen('sala'),
            },
          ),
          ListTile(
            leading: Icon(Icons.bed),
            title: Text('Habitación 1'),
            onTap: () => {
              changeMainScreen('habitacion1'),
            },
          ),
          ListTile(
            leading: Icon(Icons.bed),
            title: Text('Habitación 2'),
            onTap: () => {
              changeMainScreen('habitacion2'),
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  widget.username,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Otra info',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(widget.imagePath)),
                ),
              ),
              margin: EdgeInsets.all(20),
              width: 50,
              height: 50,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text(_title, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 20),
            _isDiscoveringServices
            ? const Center(child: CircularProgressIndicator())
            : Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: [
                      getSvg(),
                      const SizedBox(height: 20),
                      Text('Temperatura: $_temperature °C',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Iluminación', style: Theme.of(context).textTheme.bodyMedium),
                      _ledState
                      ? const Icon(Icons.lightbulb, color: Colors.blueAccent, size: 100)
                      : const Icon(Icons.lightbulb_outline, color: Colors.grey, size: 100),
                      const SizedBox(height: 20),
                    
                      Switch(
                        value: _ledState,
                        onChanged: (value) => onLedChangedHandler(value),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Puerta', style: Theme.of(context).textTheme.bodyMedium),
                      _doorState
                      ? const Icon(Icons.lock_open, color: Colors.greenAccent, size: 100)
                      : const Icon(Icons.lock_outline, color: Colors.redAccent, size: 100),
                      const SizedBox(height: 20),
                      Switch(
                        value: _doorState,
                        onChanged: (value) => onDoorChangedHandler(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onLedChangedHandler(bool value) {
    setState(() {
      _ledState = value;

      if (_ledCharacteristic != null) {
        sendLedCommand(value);
      }
    });
  }

  void onDoorChangedHandler(bool value) {
    setState(() {
      _doorState = value;

      if (_doorCharacteristic != null) {
        sendDoorCommand(value);
      }
    });
  }
}
