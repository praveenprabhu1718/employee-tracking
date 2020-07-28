import 'dart:io';

import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/models/Message.dart';
import 'package:employeetracking/provider/ImageUploadProvider.dart';
import 'package:employeetracking/resources/FirebaseMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<FirebaseUser> signIn(String email, String password) =>
      _firebaseMethods.signIn(email, password);

  Future<void> addEmployeeDataToDB(FirebaseUser user) async =>
      _firebaseMethods.addEmployeeDataToDB(user);

  Future<void> updateLocation(
          LocationData currentLocation, FirebaseUser user) async =>
      _firebaseMethods.updateLocation(currentLocation, user);

  Future<List<Map<String, dynamic>>> populateEmployees() async =>
      _firebaseMethods.populateEmployees();

  Future<void> signOut() async => _firebaseMethods.signOut();

  Future<List<Employee>> fetchAllEmployees(FirebaseUser user) async =>
      _firebaseMethods.fetchAllEmployees(user);

  Future<String> getProfilePhotoUrl() async =>
      _firebaseMethods.getProfilePhotoUrl();

  Future<String> getProfileName() async => _firebaseMethods.getProfileName();

  Future<void> addMsgToDB(
          Message message, Employee sender, Employee receiver) async =>
      _firebaseMethods.addMsgToDB(message, sender, receiver);

  void uploadImage(
          {@required File image,
          @required String senderId,
          @required String receiverId,
          @required ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(image, receiverId, senderId, imageUploadProvider);
}
