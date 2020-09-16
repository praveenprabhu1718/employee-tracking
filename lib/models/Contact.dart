import 'package:cloud_firestore/cloud_firestore.dart';

class Contact{

  String uid;
  String email;
  Timestamp addedOn;

  Contact({
    this.uid,
    this.addedOn,
    this.email
  });

  Map toMap(Contact contact){
    var data = Map<String,dynamic>();
    data['contact_id'] = this.uid;
    data['added_on'] = this.addedOn;
    data['email'] = this.email;
    return data;
  }

  Contact.fromMap(Map<String,dynamic> map){
    this.uid  = map['contact_id'];
    this.addedOn = map['added_on'];
    this.email = map['email'];
  }

}