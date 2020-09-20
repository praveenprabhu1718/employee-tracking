import 'dart:io';

import 'package:employeetracking/components/AppBar.dart';
import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:employeetracking/utils/Utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget with NavigationStates {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String email = '';
  String name = '';
  String profilePhotoUrl = '';
  FirebaseRepository _repository = FirebaseRepository();

  @override
  void initState() {
    super.initState();
    getEmailAndProfileName();
  }

  Future<void> getEmailAndProfileName() async {
    email = await _repository.getCurrentUser().then((value) => value.email);
    profilePhotoUrl = await _repository.getProfilePhotoUrl();
    name = await _repository.getProfileName();
  }

  pickImage({@required ImageSource imageSource}) async {
    File selectedImage = await Utils.pickImage(imageSource: imageSource);
    FirebaseRepository().updateProfilePhoto(selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, SideBarLayout.id);
        return true;
      },
          child: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: CustomAppBar(
          title: Text(
            'Account',
            style: GoogleFonts.tenaliRamakrishna(
                textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w500)),
          ),
          actions: null,
          leading: null,
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.only(left: 16, top: 25, right: 16),
          child: FutureBuilder(
              future: getEmailAndProfileName(),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Center(
                      child: Stack(
                        children: [
                          StreamBuilder(
                              stream: FirebaseRepository().avatarStream(email),
                              builder: (context, snapshot) {
                                if (snapshot.hasData)
                                  return Container(
                                    width: 175,
                                    height: 175,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 4,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: Offset(0, 10))
                                        ],
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              snapshot.data['profilePhoto'],
                                            ))),
                                  );
                                else
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                              }),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  pickImage(imageSource: ImageSource.gallery);
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: UniversalVariables.lightBlueColor,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    buildTextField("Full Name", name),
                    buildTextField("E-mail", email),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          auth.sendPasswordResetEmail(email: email);
                          Fluttertoast.showToast(
                              msg: 'Sent password reset link to $email',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: UniversalVariables.blackColor,
                              textColor: UniversalVariables.greyColor);
                        },
                        child: Container(
                          height: 45,
                          width: 130,
                          decoration: BoxDecoration(
                              color: UniversalVariables.lightBlueColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                              child: Text(
                            'Password Reset',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          )),
                        ),
                      ),
                    )
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String placeholder) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              placeholder,
              style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 1,
              color: UniversalVariables.separatorColor,
            )
          ],
        ));
  }
}

// TextField(
//         obscureText: isPasswordTextField ? showPassword : false,
//         decoration: InputDecoration(
//             suffixIcon: isPasswordTextField
//                 ? IconButton(
//                     onPressed: () {
//                       setState(() {
//                         showPassword = !showPassword;
//                       });
//                     },
//                     icon: Icon(
//                       Icons.remove_red_eye,
//                       color: Colors.grey,
//                     ),
//                   )
//                 : null,
//             contentPadding: EdgeInsets.only(bottom: 3),
//             labelText: labelText,
//             labelStyle: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold
//             ),
//             floatingLabelBehavior: FloatingLabelBehavior.always,
//             hintText: placeholder,
//             hintStyle: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.white54,
//             )),
//       ),

// Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   OutlineButton(
//                     padding: EdgeInsets.symmetric(horizontal: 50),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     onPressed: () {},
//                     child: Text("CANCEL",
//                         style: TextStyle(
//                             fontSize: 14,
//                             letterSpacing: 2.2,
//                             color: Colors.black)),
//                   ),
//                   RaisedButton(
//                     onPressed: () {},
//                     color: Colors.green,
//                     padding: EdgeInsets.symmetric(horizontal: 50),
//                     elevation: 2,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20)),
//                     child: Text(
//                       "SAVE",
//                       style: TextStyle(
//                           fontSize: 14,
//                           letterSpacing: 2.2,
//                           color: Colors.white),
//                     ),
//                   )
//                 ],
//               )
