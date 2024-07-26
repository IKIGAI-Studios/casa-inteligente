import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:casa_inteligente/pages/widgets/nav_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
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
            Text('Sala principal', style: Theme.of(context).textTheme.bodyMedium),
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
                      SvgPicture.asset(
                        'assets/img/sala.svg',
                        height: 150,
                        width: 150,
                      ),
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
