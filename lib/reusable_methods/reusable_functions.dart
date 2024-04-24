import 'dart:convert';

import 'package:oxschool/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/temp/users_temp_data.dart';

Future<dynamic> getAllCampuse() async {
  var response = await getCampuseList();
  var campusList = jsonDecode(response);
  // List<String> campuseNameList = [];
  // campuseList.clear();
  for (var item in campusList) {
    String name = item['Name'];
    campuseList.add(name); //.add(name);
  }
  // return campuseNameList;
}

Future<dynamic> getWorkDepartmentList() async {
  // List<String> departments = [];
  var response = await getWorkDepartments();
  var jsonList = jsonDecode(response);

  for (var item in jsonList) {
    areaList.add(item['department']);
  }

  // return departments;
}
