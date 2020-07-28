import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/components/AppBar.dart';
import 'package:employeetracking/constants.dart';
import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Events extends StatefulWidget with NavigationStates {
  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  double height;
  double width;

  Widget eventCard(
      {String imageUrl,
      String title,
      String description,
      String venue,
      String date,
      String time}) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: InkWell(
        onTap: null,
        child: Container(
          height: height * 0.50,
          width: width * 0.90,
          decoration:
              kEventsPage.copyWith(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    width: width * 90,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                flex: 6,
              ),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: kEventsPage.copyWith(
                    color: Color(0xff242535),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  ),
                  
                  child:Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          description,
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                              textStyle: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400)),
                        ),
                      ),
                      Flexible(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          placeHolder(placeHolderName: 'Venue', value: venue),
                          placeHolder(placeHolderName: 'Date', value: date),
                          placeHolder(placeHolderName: 'Time', value: time)
                        ],
                      ))
                    ],
                  ),)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row placeHolder({String placeHolderName, String value}) {
    return Row(
      children: <Widget>[
        Text(
          '$placeHolderName: ',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w900,color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(color:Colors.white70),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(title: Text('Upcoming Events',style: GoogleFonts.tenaliRamakrishna(textStyle: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w500)),), actions: null, leading: null, centerTitle: true,),
          body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(context, SideBarLayout.id);
          return true;
        },
        child:Container(
            color: UniversalVariables.blackColor,
            height: height,
            width: width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection(EVENTS_COLLECTION).snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                            child: Text('Loading...'),
                          );
                        }
                        return ListView(
                          primary: false,
                          //shrinkWrap: true,
                          //physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data.documents
                              .map<Widget>((DocumentSnapshot document) {
                            return eventCard(
                                imageUrl: document['ImageUrl'],
                                title: document['Title'],
                                description: document['Description'],
                                venue: document['Venue'],
                                date: document['Date'],
                                time: document['Time']);
                          }).toList(),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      
    );
  }
}
