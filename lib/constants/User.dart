import 'package:oxschool/Models/Cycle.dart';
import 'package:oxschool/Models/User.dart';

late User? currentUser;
late Cycle? currentCycle;

late List<String>? _grades = [];

late List<dynamic>? userPermissions = [];

var deviceInformation = <String, dynamic>{};
String? deviceIp;

void clearUserData() {
  currentUser?.clear();
  currentCycle?.clear();
  _grades = null;
  userPermissions = null;
}
