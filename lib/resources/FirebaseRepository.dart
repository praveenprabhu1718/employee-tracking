import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/enum/UserState.dart';
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

  void updateNameAndProfilePhotoUrl(String name, String profilePhotoUrl) async => _firebaseMethods.updateNameAndProfilePhotoUrl(name, profilePhotoUrl);

  void changePassword(String password) async => _firebaseMethods.changePassword(password);

  Future<void> addMsgToDB(
          Message message, Employee sender, Employee receiver) async =>
      _firebaseMethods.addMsgToDB(message, sender, receiver);

  Future<Employee> getEmployeeDetails() async =>
      _firebaseMethods.getEmployeeDetails();

  Future<Employee> getEmployeeDetailsById(id) async => _firebaseMethods.getEmployeDetailsById(id);

  Stream<QuerySnapshot> fetchContacts({String userId}) =>
      _firebaseMethods.fetchContacts(userId: userId);

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String senderId, @required String receiverId}) =>
      _firebaseMethods.fetchLastMessageBetween(
          senderId: senderId, receiverId: receiverId);

  void uploadImage(
          {@required File image,
          @required String senderId,
          @required String receiverId,
          @required ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(
          image, receiverId, senderId, imageUploadProvider);

  void setUserState({@required String userId, @required UserState userState}) => _firebaseMethods.setUserState(userId: userId, userState: userState);

  Stream<DocumentSnapshot> getUserStream({@required String uid}) => _firebaseMethods.getUserStream(uid: uid); 
}
