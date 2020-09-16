import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:flutter/material.dart';


const String MESSAGES_COLLECTION = 'Messages';
const String TIMESTAMP = 'timestamp';
const String EMPLOYEES_COLLECTION = 'Employees';
const String LAT = 'lat';
const String LNG = 'lng';
const String EMAIL = 'email';
const String PROFILEPHOTO = 'profilePhoto';
const String NAME = 'name'; 
const String EVENTS_COLLECTION = 'Events';
const String MARKERS_COLLECTION = 'Markers';
const String CONTACTS_COLLECTION = 'Contacts';
const String MESSAGE_TYPE_IMAGE = 'image';

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter your email',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

var kOrangeOppacity = Colors.deepOrange.withOpacity(0.80);

Color kPrimaryColor = UniversalVariables.blackColor;

BoxDecoration kEventsPage = BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    color: UniversalVariables.blackColor,
   );
//  boxShadow: [
//       BoxShadow(
//           color: UniversalVariables.separatorColor,
//           offset: Offset(0, 20),
//           blurRadius: 15),
//       BoxShadow(
//           color: UniversalVariables.blackColor,
//           offset: Offset(0, -10),
//           blurRadius: 10)
//     ]