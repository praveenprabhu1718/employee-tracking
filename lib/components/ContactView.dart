import 'package:employeetracking/components/CachedImage.dart';
import 'package:employeetracking/components/OnlineDotIndicator.dart';
import 'package:employeetracking/models/Contact.dart';
import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/provider/UserProvider.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/screens/ChatScreen.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'CustomTile.dart';
import 'LastMessageContainer.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  ContactView({Key key, this.contact}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Employee>(
        future: _firebaseRepository.getEmployeeDetailsById(contact.email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Employee employee = snapshot.data;
            return ViewLayout(
              contact: employee,
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class ViewLayout extends StatefulWidget {
  final Employee contact;

  ViewLayout({Key key, this.contact}) : super(key: key);

  @override
  _ViewLayoutState createState() => _ViewLayoutState();
}

class _ViewLayoutState extends State<ViewLayout> {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  String senderId = '';
  @override
  void initState() {
    getSenderId();
    super.initState();
  }

  getSenderId() async {
    await FirebaseRepository().getCurrentUser().then((value) {
      setState(() {
        senderId = value.email;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return CustomTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: widget.contact,
            ),
          )),
      mini: false,
      title: Text(
        widget.contact.name,
        style: GoogleFonts.roboto(color: Colors.white, fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: FirebaseRepository().fetchLastMessageBetween(senderId: senderId, receiverId: widget.contact.email),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(children: <Widget>[
          CachedImage(widget.contact.profilePhoto, radius: 80, isRound: true),
          OnlineDotIndicator(uid: widget.contact.email)
        ]),
      ),
    );
  }
}
