import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ims_xpress/const/Constants.dart';
import 'package:ims_xpress/views/ActivitySplash.dart';

void main() {
  Map<int, Color> color = {
    50: Color.fromRGBO(255, 73, 67, .1),
    100: Color.fromRGBO(255, 73, 67, .2),
    200: Color.fromRGBO(255, 73, 67, .3),
    300: Color.fromRGBO(255, 73, 67, .4),
    400: Color.fromRGBO(255, 73, 67, .5),
    500: Color.fromRGBO(255, 73, 67, .6),
    600: Color.fromRGBO(255, 73, 67, .7),
    700: Color.fromRGBO(255, 73, 67, .8),
    800: Color.fromRGBO(255, 73, 67, .9),
    900: Color.fromRGBO(255, 73, 67, 1),
  };

  MaterialColor colorCustom = MaterialColor(0xFFFF5C57, color);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: colorCustom,
          appBarTheme: AppBarTheme(
            color: Constants.redLight,
          ),
        ),
        home: ActivitySplash(),
      ),
    );
  });
}
