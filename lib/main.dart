import 'package:employeetracking/constants.dart';
import 'package:employeetracking/provider/ImageUploadProvider.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/screens/SearchScreen.dart';
import 'package:employeetracking/screens/login_screen.dart';
import 'package:employeetracking/screens/map_screen.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

FirebaseRepository _repository = FirebaseRepository();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageUploadProvider(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: UniversalVariables.blackColor,
          accentColor: UniversalVariables.separatorColor,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          SearchScreen.id: (context) => SearchScreen(),
          SideBarLayout.id: (context) => SideBarLayout(),
          LoginScreen.id: (context) => LoginScreen(),
          MapScreen.id: (context) => MapScreen()
        },
        home: FutureBuilder(
            future: _repository.getCurrentUser(),
            builder:
                (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
                return SideBarLayout();
              } else {
                return LoginScreen();
              }
            }),
      ),
    );
  }
}
