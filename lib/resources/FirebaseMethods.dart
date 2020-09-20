import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/constants.dart';
import 'package:employeetracking/enum/UserState.dart';
import 'package:employeetracking/models/Contact.dart';
import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/models/Message.dart';
import 'package:employeetracking/provider/ImageUploadProvider.dart';
import 'package:employeetracking/utils/Utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Employee employee;
  Firestore firestore = Firestore.instance;
  StorageReference _storageReference;

  Future<FirebaseUser> signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<FirebaseUser> getCurrentUser() async {
    return await _auth.currentUser();
  }

  Future<void> addEmployeeDataToDB(FirebaseUser currentUser) async {
    employee = Employee(uid: currentUser.uid, email: currentUser.email);

    firestore
        .collection(EMPLOYEES_COLLECTION)
        .document(currentUser.email)
        .setData(employee.toMap(employee));
  }

  Future<Employee> getEmployeeDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot = await firestore
        .collection(EMPLOYEES_COLLECTION)
        .document(currentUser.email)
        .get();
    return Employee.frommap(documentSnapshot.data);
  }

  Future<Employee> getEmployeDetailsById(id) async {
    try{
      DocumentSnapshot documentSnapshot = await firestore.collection(EMPLOYEES_COLLECTION).document(id).get();
    return Employee.frommap(documentSnapshot.data);
    }
    catch(e){
      print(e);
      return null;
    }
  }

  Future<void> updateLocation(
      LocationData currentLocation, FirebaseUser user) async {
    employee = Employee(
        lat: currentLocation.latitude.toString(),
        lng: currentLocation.longitude.toString());

    firestore.collection('Employees').document(user.email)
        //.updateData(employee.toMap(employee));
        .updateData({
      LAT: currentLocation.latitude.toString(),
      LNG: currentLocation.longitude.toString()
    });
  }

  Future<List<Map<String, dynamic>>> populateEmployees() async {
    List<DocumentSnapshot> tempList;
    CollectionReference collectionReference =
        firestore.collection(EMPLOYEES_COLLECTION);
    QuerySnapshot querySnapshot = await collectionReference.getDocuments();
    tempList = querySnapshot.documents;
    return tempList.map((DocumentSnapshot documentSnapshot) {
      return documentSnapshot.data;
    }).toList();
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<List<Employee>> fetchAllEmployees(FirebaseUser currentUser) async {
    List<Employee> employeeList = List<Employee>();

    QuerySnapshot querySnapshot =
        await firestore.collection(EMPLOYEES_COLLECTION).getDocuments();
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].data[EMAIL] != currentUser.email) {
        employeeList.add(Employee.frommap(querySnapshot.documents[i].data));
      }
    }
    return employeeList;
  }


  Future<String> getProfilePhotoUrl() async {
    FirebaseUser user = await getCurrentUser();
    return await firestore
        .collection(EMPLOYEES_COLLECTION)
        .document(user.email)
        .get()
        .then((DocumentSnapshot snapshot) {
      return snapshot.data[PROFILEPHOTO];
    });
  }

  void updateNameAndProfilePhotoUrl(String name, String profilePhotoUrl) async {
    FirebaseUser user = await getCurrentUser();
    await firestore.collection(EMPLOYEES_COLLECTION)
      .document(user.email)
      .updateData({
        'name' : name,
        'profilePhoto' : profilePhotoUrl
      });
  }

  void changePassword(String password) async {
    FirebaseUser user = await getCurrentUser();
    user.updatePassword(password);
  }

  Future<String> getProfileName() async {
    FirebaseUser user = await getCurrentUser();
    return await firestore
        .collection(EMPLOYEES_COLLECTION)
        .document(user.email)
        .get()
        .then((DocumentSnapshot snapshot) {
      return snapshot.data[NAME];
    });
  }

  Future<void> addMsgToDB(
      Message message, Employee sender, Employee receiver) async {
    var map = message.toMap();
    
    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(message.senderId)
        .collection(message.receiverId)
        .add(map);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    return await firestore
        .collection(MESSAGES_COLLECTION)
        .document(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  DocumentReference getContactReference({String of, String forContact}) {
    return  firestore
        .collection(EMPLOYEES_COLLECTION)
        .document(of)
        .collection(CONTACTS_COLLECTION)
        .document(forContact);
  }

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot documentSnapshot =
        await getContactReference(of: senderId, forContact: receiverId).get();

    if (!documentSnapshot.exists) {
      Contact receiverContact = Contact(email: receiverId, addedOn: currentTime);
      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactReference(of: senderId, forContact: receiverId)
          .setData(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
      String senderId, String receiverId, currentTime) async {
    DocumentSnapshot documentSnapshot =
        await getContactReference(of: receiverId, forContact: senderId).get();

    if (!documentSnapshot.exists) {
      Contact senderContact = Contact(email: senderId, addedOn: currentTime);
      var senderMap = senderContact.toMap(senderContact);

      await getContactReference(of: receiverId, forContact: senderId)
          .setData(senderMap);
    }
  }

  Future<String> uploadImageToStorage(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('ChatImages')
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask _storageUploadTask = _storageReference.putFile(image);
      String url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void updateProfilePhotoUrl(String url) async {
    FirebaseUser user = await getCurrentUser();
    firestore.collection(EMPLOYEES_COLLECTION)
      .document(user.email)
      .updateData({
        'profilePhoto' : url
      });
  }

  Stream avatarStream(String email) {
    return firestore.collection(EMPLOYEES_COLLECTION)
      .document(email)
      .snapshots();
  }

  Future<void> updateProfilePhoto(File image) async {
    var user = await getCurrentUser();
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('ProfilePhotos')
          .child('${user.email}');
      StorageUploadTask _storageUploadTask = _storageReference.putFile(image);
      String url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      updateProfilePhotoUrl(url);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
        message: 'IMAGE',
        senderId: senderId,
        receiverId: receiverId,
        timestamp: Timestamp.now(),
        type: 'image',
        photourl: url);
    var map = _message.toImageMap();

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    await firestore
        .collection(MESSAGES_COLLECTION)
        .document(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageUploadprovider) async {
    imageUploadprovider.setToLoading();
    String url = await uploadImageToStorage(image);
    setImageMsg(url, receiverId, senderId);
    imageUploadprovider.setToIdle();
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => firestore
      .collection(EMPLOYEES_COLLECTION)
      .document(userId)
      .collection(CONTACTS_COLLECTION)
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween(
          {@required String senderId, @required String receiverId}) =>
      firestore
          .collection(MESSAGES_COLLECTION)
          .document(senderId)
          .collection(receiverId)
          .orderBy('timestamp')
          .snapshots();

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    firestore.collection(EMPLOYEES_COLLECTION).document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      firestore.collection(EMPLOYEES_COLLECTION).document(uid).snapshots();
}
