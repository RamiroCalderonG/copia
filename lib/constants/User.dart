import 'package:oxschool/Models/Cycle.dart';
import 'package:oxschool/Models/User.dart';
import 'package:http/http.dart' as http;

late User? currentUser;
late Cycle? currentCycle;

late List<String>? _grades = [];
late Future<http.Response> userEvents;
late List<dynamic>? eventsList = [];

var deviceInformation = <String, dynamic>{};
String? deviceIp;

void clearUserData() {
  currentUser?.clear();
  currentCycle?.clear();
  _grades = null;
}
