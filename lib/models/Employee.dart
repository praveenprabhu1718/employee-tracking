class Employee{
  String uid;
  String email;
  String name;
  String status;
  int state;
  String profilePhoto;
  String password;
  String lat;
  String lng;

  Employee({
    this.uid,
    this.email,
    this.name,
    this.status,
    this.state,
    this.profilePhoto,
    this.lat,
    this.lng
  });

  Map toMap(Employee user){
    var data = Map<String,dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['status'] = user.status;
    data['state'] = user.state;
    data['profilePhoto'] = user.profilePhoto;
    data['lat'] = user.lat;
    data['lng'] = user.lng;
  }

  Employee.frommap(Map<String,dynamic> mapData){
    this.uid = mapData['uid'];
    this.email = mapData['email'];
    this.name = mapData['name'];
    this.state = mapData['status'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profilePhoto'];
    this.lat = mapData['lat'];
    this.lng = mapData['lng'];
  }

}