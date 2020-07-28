import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:flutter/material.dart';

class CallHistory extends StatefulWidget with NavigationStates {
  @override
  _CallHistoryState createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, SideBarLayout.id);
        return true;
      },
      child: Container(
        child: Center(child: Text('Call History')),
      ),
    );
  }
}
