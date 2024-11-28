// ignore_for_file: file_names, unnecessary_late

import 'package:oxschool/data/Models/Cycle.dart';
import 'package:oxschool/data/Models/User.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

late User? currentUser;
late Cycle? currentCycle;

// ignore: unused_element
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
