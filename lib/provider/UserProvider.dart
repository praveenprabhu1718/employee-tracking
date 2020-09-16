

import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier{
  Employee _employee;

  FirebaseRepository _firebaseRepository = FirebaseRepository();

  Employee get getEmployee => _employee;

  Future<void> refreshUser() async {
    Employee employee = await _firebaseRepository.getEmployeeDetails();
    _employee = employee;
    notifyListeners();
  }
}