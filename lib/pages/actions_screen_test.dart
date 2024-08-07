import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionsScreenTest extends StatefulWidget {
  const ActionsScreenTest({Key? key, required this.username, required this.imagePath}) : super(key: key);

  final String username;
  final String imagePath;

  @override
  ActionsScreenTestState createState() => ActionsScreenTestState();
}

class ActionsScreenTestState extends State<ActionsScreenTest> {

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
    super.initState();

    print('Current context: $context');
  }

  Future<void> getTemperature() async {
    setState(() {
      _temperature = 25.0;
    });
    print('temperature');
  }

  void sendLedCommand(bool turnOn) {
    setState(() {
      _ledState = turnOn;
    });
    print('LED: '+ turnOn.toString());
  }

  void sendDoorCommand(bool action) {
    setState(() {
      _doorState = action;
    });
    print('Door: '+ action.toString());
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
              Navigator.pop(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.bed),
            title: Text('Habitación 1'),
            onTap: () => {
              changeMainScreen('habitacion1'),
              Navigator.pop(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.bed),
            title: Text('Habitación 2'),
            onTap: () => {
              changeMainScreen('habitacion2'),
              Navigator.pop(context),
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {Navigator.pop(context);},
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
                  'Usuario',
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
      sendLedCommand(value);
    });
  }

  void onDoorChangedHandler(bool value) {
    setState(() {
      _doorState = value;
      sendDoorCommand(value);
    });
  }
}
