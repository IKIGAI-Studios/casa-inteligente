import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOff extends StatelessWidget {
  const BluetoothOff({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState;

  // Ícono de bluetooth apagado
  Widget buildBluetoothOffIcon(BuildContext context) {
    return const Icon(
      Icons.bluetooth_disabled,
      size: 150.0,
      color: Colors.white54,
    );
  }

  // Texto de la pantalla
  Widget buildTitle(BuildContext context) {
    String? state = adapterState?.toString().split(".").last;
    return Text(
      'El servicio Bluetooth ${state == null ? 'no disponible' : state == 'on' ? 'está encendido' : 'está apagado'}',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  // Botón para encender el bluetooth
  Widget buildTurnOnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('Encender Bluetooth'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        onPressed: () async {
          try {
            if (Platform.isAndroid) {
              await FlutterBluePlus.turnOn();
            }
          } catch (e) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('Error Turning On: ${e}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildBluetoothOffIcon(context),
            buildTitle(context),
            if (Platform.isAndroid) buildTurnOnButton(context),
          ],
        ),
      )
    );
  }
}
