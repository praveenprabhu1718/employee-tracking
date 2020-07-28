import 'package:employeetracking/navigation_bloc/navigation_bloc.dart';
import 'package:employeetracking/sidebar/sidebar_layout.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, SideBarLayout.id);
        return true;
      },
      child: Center(
        child: Text(
          "My Accounts",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
        ),
      ),
    );
  }
}
