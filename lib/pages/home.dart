// import 'package:casa_inteligente/constants/constants.dart';
import 'package:casa_inteligente/locator.dart';
import 'package:casa_inteligente/pages/db/databse_helper.dart';
import 'package:casa_inteligente/pages/sign-in.dart';
import 'package:casa_inteligente/pages/sign-up.dart';
import 'package:casa_inteligente/services/camera.service.dart';
import 'package:casa_inteligente/services/ml_service.dart';
import 'package:casa_inteligente/services/face_detector_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MLService _mlService = locator<MLService>();
  FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  CameraService _cameraService = locator<CameraService>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  _initializeServices() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20, top: 20),
            child: PopupMenuButton<String>(
              child: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'Clear DB':
                    DatabaseHelper _dataBaseHelper = DatabaseHelper.instance;
                    _dataBaseHelper.deleteAll();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Clear DB'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
      body: !loading
          ? SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: [
                          SvgPicture.asset(
                            'assets/img/logo.svg',
                            height: 200,
                            width: 200,
                          ),
                          Text('Casa Inteligente')
                        ],
                      ),
                      Column(
                        children: [


                          
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => SignIn(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.primary,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.secondary,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              width: 250,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar sesión',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.login, color: Theme.of(context).colorScheme.secondary)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => SignUp(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              width: 250,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Registro',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.person_add, color: Colors.white)
                                ],
                              ),
                            ),
                          ),                          
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}