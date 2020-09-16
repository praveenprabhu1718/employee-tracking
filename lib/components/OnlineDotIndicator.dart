import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employeetracking/enum/UserState.dart';
import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/utils/Utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  OnlineDotIndicator({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    getColor(int state) {
      switch (Utils.numToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseRepository.getUserStream(
          uid: uid,
        ),
        builder: (context, snapshot) {
          Employee employee;

          if (snapshot.hasData && snapshot.data.data != null) {
            employee = Employee.frommap(snapshot.data.data);
          }

          return Container(
            height: 10,
            width: 10,
            margin: EdgeInsets.only(right: 5, top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: getColor(employee?.state),
            ),
          );
        },
      ),
    );
  }
}