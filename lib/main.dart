import 'package:employeetracking/screens/login_screen.dart';
import 'package:employeetracking/screens/map_screen.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main()  {
    runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xff465F40),
        accentColor: Color(0xff639a67),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.id,
      routes: {
        SideBarLayout.id : (context) => SideBarLayout(),
        LoginScreen.id : (context) => LoginScreen(),
        MapScreen.id : (context) => MapScreen()
      },
    );
  }
}

