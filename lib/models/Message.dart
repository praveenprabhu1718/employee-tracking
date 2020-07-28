import 'package:cloud_firestore/cloud_firestore.dart';

class Message{

  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photourl;
  
  Message({this.senderId,this.receiverId,this.timestamp,this.message,this.type});

  Message.imageMessage({this.senderId,this.receiverId,this.timestamp,this.message,this.type,this.photourl});

  Map toMap(){
    var map = Map<String,dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  Map toImageMap(){
    var map = Map<String,dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['photoUrl'] = this.photourl;
    return map;
  }

  Message.fromMap(Map<String,dynamic> map){
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.photourl = map['photoUrl'];
  }

}