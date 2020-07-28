import 'package:employeetracking/components/rounded_button.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String email;
  String pwd;
  FirebaseRepository _repository = FirebaseRepository();
  bool spinner = false;

  Animation animation1;
  Animation animation2;
  AnimationController controller;


  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    animation1 = ColorTween(
            begin: UniversalVariables.blackColor, end: UniversalVariables.blackColor.withOpacity(0.85))
        .animate(controller);
    animation2 = ColorTween(
            begin: UniversalVariables.separatorColor, end: UniversalVariables.separatorColor.withOpacity(0.30))
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      primary: true,
      key: scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Stack(children: <Widget>[
                    Stack(children: <Widget>[
                      Image.asset(
                        'images/KCG.jpg',
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ]),
                    Container(
                      color: animation1.value,
                    )
                  ]),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: animation2.value,
                  ),
                )
              ],
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 60,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome back KCGian,',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 30),
                      ),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Log in to continue',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.all(20),
                height: 450,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 15),
                          blurRadius: 15),
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, -10),
                          blurRadius: 10)
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        height: 150.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'STAFF LOGIN',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) =>
                              FocusScope.of(context).nextFocus(),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value.trim();
                          },
                          decoration: kTextFieldDecoration.copyWith(
                              //errorText: ,
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        obscureText: true,
                        onChanged: (value) {
                          pwd = value;
                        },
                        decoration: kTextFieldDecoration.copyWith(
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock)),
                      ),
                    ),
                    RoundedButton(
                      title: 'Log in',
                      buttonColor: Color(0xff639a67),
                      onPressed: () async {
                        setState(() {
                          spinner = true;
                        });
                        try {
                          final resultUser = await _repository.signIn(email,pwd);
                          if (resultUser != null) {
                            Navigator.of(context)
                                .pushReplacementNamed(SideBarLayout.id);
                            _repository.addEmployeeDataToDB(resultUser);
                          }
                          setState(() {
                            spinner = false;
                          });
                        } catch (e) {
                          setState(() {
                            spinner = false;
                          });
                          final snackBar = SnackBar(
                            content: Text('Invalid Email or Password'),
                          );
                          scaffoldKey.currentState.showSnackBar(snackBar);
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
