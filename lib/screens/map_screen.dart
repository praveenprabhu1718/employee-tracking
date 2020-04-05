import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  GoogleMapController mapController;

  Set<Marker> places;

  final LatLng _center = const LatLng(12.921327, 80.240306);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Completer<GoogleMapController> _controller = Completer();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    places = Set.from([]);
    setState(() {
      populatemarkers();
    });
  }



  populatemarkers(){
    Firestore.instance.collection('Markers').getDocuments().then((docs){
      if(docs.documents.isNotEmpty){
        for (var i =0; i < docs.documents.length ;i++){
          initMarker(docs.documents[i].data,docs.documents[i].documentID);
        }
      }
    });

  }

  initMarker(marker,markerid){
    final MarkerId _markerid = MarkerId(markerid);
    final Marker _marker = Marker(
      markerId: _markerid,
      infoWindow: InfoWindow(
        title: marker['place_name'],
        onTap: (){

        }
      ),
      position: LatLng(
        marker['coordinates'].latitude,
        marker['coordinates'].longitude
      ),
    );
    setState(() {
      places.add(_marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      body: Stack(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            mapType: MapType.satellite,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 18.0,
            ),
            markers: places,
          ),
        ),
      ]),
    );
  }
}
