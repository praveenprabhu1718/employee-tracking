import 'dart:async';
import 'dart:io';

import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/constants.dart';
import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget with NavigationStates {
  static const String id = 'map_screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription _localSubscription;
  Location _loccationTracker = Location();
  Marker marker;
  Circle circle;

  Set<Marker> places;
  var employees = [];

  final LatLng _center = const LatLng(12.921327, 80.240306);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  GoogleMapController _mapController;

  final _auth = FirebaseAuth.instance;

  LocationData location;

  BitmapDescriptor employeeLocation;

  Location movingLocation;

  FirebaseRepository _repository = FirebaseRepository();

  Future<void> getCurrentLocation() async {
    location = await _loccationTracker.getLocation();
    print(location.latitude);
    updateLocationToFirestore(location);
  }

  void updateLocationToFirestore  (LocationData currentLocation) async {

    var employee = await _repository.getCurrentUser();
    _repository.updateLocation(currentLocation, employee);
  }

  void setCustomMapPin() async {
    employeeLocation = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/customPin.png');
  }

  @override
  void initState() {
    super.initState();
    places = Set.from([]);
    setCustomMapPin();
    setState(() {
      populatemarkers();
      populateEmployeesMarkers();
      populateEmployees();
    });
    getCurrentLocation();
    movingLocation = Location();
    movingLocation.onLocationChanged.listen((event) {
      updateLocationToFirestore(event);
    });
  }

  @override
  void dispose() {
    if (_localSubscription != null) {
      _localSubscription.cancel();
    }
    super.dispose();
  }

  populateEmployees() async {
    employees = [];
    employees = await _repository.populateEmployees();    
  }

  populateEmployeesMarkers() {
    Firestore.instance
        .collection(EMPLOYEES_COLLECTION)
        .getDocuments()
        .then((docs) async {
      if (docs.documents.isNotEmpty) {
        for (var i = 0; i < docs.documents.length; i++) {
          final FirebaseUser user = await _auth.currentUser();
          if (docs.documents[i].data['email'] != user.email) {
            initMarkerForEmployees(
                docs.documents[i].data, docs.documents[i].documentID);
          }
        }
      }
    });
  }

  initMarkerForEmployees(marker, markerid) {
    final MarkerId _markerid = MarkerId(markerid);
    final Marker _marker = Marker(
      icon: employeeLocation,
      markerId: _markerid,
      infoWindow: InfoWindow(title: marker['email'], onTap: () {}),
      position:
          LatLng(double.parse(marker['lat']), double.parse(marker['lng'])),
    );
    setState(() {
      places.add(_marker);
    });
  }

  populatemarkers() {
    Firestore.instance.collection(MARKERS_COLLECTION).getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (var i = 0; i < docs.documents.length; i++) {
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  initMarker(marker, markerid) {
    final MarkerId _markerid = MarkerId(markerid);
    final Marker _marker = Marker(
      markerId: _markerid,
      infoWindow: InfoWindow(title: marker['place_name'], onTap: () {}),
      position: LatLng(
          marker['coordinates'].latitude, marker['coordinates'].longitude),
    );
    setState(() {
      places.add(_marker);
    });
  }

  Widget placesCard(employee) {
    return Padding(
      padding: EdgeInsets.only(left: 2, top: 10, right: 10),
      child: InkWell(
        onTap: () {
          zoomInMarker(employee);
        },
        child: Container(
          decoration: BoxDecoration(
              color: UniversalVariables.blackColor, borderRadius: BorderRadius.circular(15)),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width - 100,
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Expanded(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(employee['profilePhoto']),
                ),
                flex: 2,
              ),
              Expanded(
                child: Center(
                  child: Text(employee['name'],style: TextStyle(color:Colors.white),),
                ),
                flex: 1,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.chat, color: UniversalVariables.greyColor),
                          onPressed: null),
                      IconButton(
                          icon: Icon(
                            Icons.call,
                            color: UniversalVariables.greyColor,
                          ),
                          onPressed: null),
                    ],
                  ),
                ),
                flex: 2,
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  zoomInMarker(employee) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            double.parse(employee['lat']), double.parse(employee['lng'])),
        zoom: 18,
        bearing: 90,
        tilt: 40)));
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: kPrimaryColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: kPrimaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: kPrimaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: kPrimaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              compassEnabled: true,
              mapType: MapType.satellite,
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 18.0,
              ),
              markers: places,
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height - 150,
              left: 0,
              child: Container(
                height: 125,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: false,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(8),
                  children: employees.map((elements) {
                    return placesCard(elements);
                  }).toList(),
                ),
              ))
        ]),
      ),
    );
  }

  void onMapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }
}
