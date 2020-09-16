import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/components/AppBar.dart';
import 'package:employeetracking/components/ContactView.dart';
import 'package:employeetracking/components/QuietBox.dart';
import 'package:employeetracking/components/UserCircle.dart';
import 'package:employeetracking/models/Contact.dart';
import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';
import 'package:employeetracking/provider/UserProvider.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/screens/SearchScreen.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    CustomAppBar customAppBar(BuildContext context) {
      return CustomAppBar(
        leading: IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
        title: Text('Chats'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, SearchScreen.id);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, SideBarLayout.id);
        return true;
      },
      child: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: customAppBar(context),
        floatingActionButton: NewChatButton(),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {

  FirebaseRepository _firebaseRepository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _firebaseRepository.fetchContacts(userId: userProvider.getEmployee.email),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              var docList = snapshot.data.documents;
              if(docList.isEmpty){
                return QuietBox();
              }
              return ListView.builder(
              itemCount: docList.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(docList[index].data);
                return ContactView(contact: contact,);
              },
            );
            }
            return Center(child: CircularProgressIndicator(),);
            
          }),
    );
  }
}
