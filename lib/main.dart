import 'package:casa_inteligente/locator.dart';
import 'package:casa_inteligente/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:casa_inteligente/constants/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Lexend Deca',
        splashColor: APP_COLORS['dark'],
        colorScheme: ColorScheme.dark(
          primary: APP_COLORS['dark']!,
          secondary: APP_COLORS['light']!,
          tertiary: APP_COLORS['accent']!,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 20.0),
        ),
      ),
      home: MyHomePage(),
    );
  }
}
