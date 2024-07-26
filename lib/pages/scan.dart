import 'dart:async';

import 'package:casa_inteligente/pages/actions_screen.dart';
import 'package:casa_inteligente/pages/actions_screen_test.dart';
import 'package:casa_inteligente/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:casa_inteligente/utils/extra.dart';

import 'package:casa_inteligente/pages/widgets/scan_result_tile.dart';
import 'package:casa_inteligente/pages/widgets/system_device_tile.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key, required this.username, required this.imagePath}) : super(key: key);

  final String username;
  final String imagePath;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Error Turning On: ${e}'),
          );
        },
      );
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('System Devices Error: ${e}'),
          );
        },
      );
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Start Scan Error: ${e}'),
          );
        },
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Stop Scan Error: ${e}'),
          );
        },
      );
    }
  }

  void onTestConnectPressed(context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (BuildContext context) => ActionsScreenTest()
    //   )
    // );

    MaterialPageRoute route = MaterialPageRoute(
      builder: (BuildContext context) => ActionsScreenTest(username: widget.username, imagePath: widget.imagePath,)
    );
    Navigator.push(context, route);
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Connect Error: ${e}'),
          );
        },
      );
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => ActionsScreen(device: device, username: widget.username, imagePath: widget.imagePath,), settings: const RouteSettings(name: '/ActionsScreen'));
    Navigator.of(context).push(route);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {

    if (FlutterBluePlus.isScanningNow) {
      return TextButton(
        onPressed: onStopPressed,
        child: const Icon(Icons.stop),
        style: Theme.of(context).textButtonTheme.style,
      );
    } else {
      return TextButton(
        onPressed: onScanPressed,
        child: const Text("SCAN"),
      );
    }
  }

    Widget buildTestButton(BuildContext context) {
    return TextButton(
      onPressed: () => onTestConnectPressed(context),
      child: const Text("TEST"),
    );
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ActionsScreen(device: d, username: widget.username, imagePath: widget.imagePath),
                settings: const RouteSettings(name: '/ActionsScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Buscar dispositivos', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(width: 10),
              buildScanButton(context),
              buildTestButton(context),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              children: <Widget>[
                ..._buildScanResultTiles(context),
              ],
            ),
          )
        ],
      )
    );
  }
}
