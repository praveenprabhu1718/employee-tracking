import 'package:bloc/bloc.dart';
import 'package:employeetracking/screens/account_screen.dart';
import 'package:employeetracking/screens/map_screen.dart';

enum NavigationEvents {
  HomePageClickedEvent,
  MyAccountClickedEvent,
  MyOrdersClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  @override
  NavigationStates get initialState => MapScreen();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        yield MapScreen();
        break;
      case NavigationEvents.MyAccountClickedEvent:
        yield AccountScreen();
        break;
      default:
        break;
    }
  }
}