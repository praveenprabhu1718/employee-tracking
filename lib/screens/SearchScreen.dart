import 'package:employeetracking/components/CustomTile.dart';
import 'package:employeetracking/models/Employee.dart';
import 'package:employeetracking/resources/FirebaseRepository.dart';
import 'package:employeetracking/utils/Universalvariables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'ChatScreen.dart';

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  FirebaseRepository _repository = FirebaseRepository();

  List<Employee> employeeList;
  String query = '';

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _repository.getCurrentUser().then((FirebaseUser user) {
      _repository.fetchAllEmployees(user).then((List<Employee> list) {
        setState(() {
          employeeList = list;
        });
      });
    });

  }

  searchAppBar(BuildContext context){

    return GradientAppBar(
      gradient: LinearGradient(
        colors: [
          UniversalVariables.gradientColorStart,
          UniversalVariables.gradientColorEnd
        ]
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left:20),
          child: TextField(
            controller: searchController,
            onChanged: (value){
              setState(() {
                query = value;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 35,
              color: Colors.white
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(icon: Icon(Icons.close,color: Colors.white,),
              onPressed: (){
                //searchController.clear();
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) => searchController.clear());
              },
              ),
              hintText: 'Search',
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0x88ffffff)
              )
            ),
          ),
        ),
      ),
    );

  }

  buildSuggestion(String query){
    final List<Employee> suggestionList = query.isEmpty
      ? []
      : employeeList.where((Employee employee) {
        String _employeeName = employee.name;
        String _employeeEmail = employee.email;
        String _query = query.toLowerCase();
        bool matchesEmail = _employeeEmail.contains(_query);
        bool matchesName = _employeeName.contains(_query);
        return (matchesEmail||matchesName);
      }).toList();
      return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: ((context,index){
          Employee searchedEmployee = Employee(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            email: suggestionList[index].email
          );
          return CustomTile(
            mini: false,
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> ChatScreen(
                  receiver: searchedEmployee
                )));
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(searchedEmployee.profilePhoto),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              searchedEmployee.email,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white 
              ),
            ),
            subtitle: Text(
              searchedEmployee.name != null ? searchedEmployee.name : searchedEmployee.email,
              style: TextStyle(
                color: UniversalVariables.greyColor,

              ),
            )
          );
        }),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child: buildSuggestion(query),
      ),
    );
  }
}