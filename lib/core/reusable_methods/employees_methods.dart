import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/Models/Employee.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls.dart';
import 'package:oxschool/core/constants/user_consts.dart';

//selectedcampus:  can be 'A' to get all campuses or the initial letter of each campus
//employeeID: if you want to get a single employee
//logData: logger function to post data from the device making the call
//param: to determinate if we want a single employee(1) or all of them(0)
getEmployee(
    String selectedCampus, String employeeID, String logData, int param) async {
  List<dynamic> jsonList;
  int? numberOfRecords;
  List<Employee> employeeResultList = [];
  var apiResultxgr = await EmployeeCall.call(
          campus: selectedCampus,
          employeeID: employeeID,
          logData: logData,
          param: param.toString(),
          ip: deviceIp!)
      .timeout(const Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    jsonList = json.decode(apiResultxgr.response!.body);
    numberOfRecords = jsonList.length;

    // Extract fetched data into a List<Employee>
    if (numberOfRecords >= 1) {
      for (var jsonItem in jsonList) {
        Employee employee = Employee(
            jsonItem['employeeID'],
            jsonItem['name'],
            jsonItem['firstLastName'],
            jsonItem['secondLastName'],
            jsonItem['workPosition'],
            jsonItem['workArea'],
            jsonItem['birthDate'] != null
                ? DateTime.parse(jsonItem['birthDate']).toString()
                : null,
            jsonItem['disabled'],
            jsonItem['genre']);
        employeeResultList.add(employee);
      }
    } else {
      debugPrint('No se ecuentran registros');
    }
  }
}

getTeacherByGradeAndGroup(int grade, String group, String campus, String cycle,
    String employeID, String deviceIP) async {
  List<dynamic> jsonList;
  List<dynamic> teacherList;
  var apiResultxgr = await TeacherCall.call(
          ipData: deviceIP,
          campus: campus,
          grade: grade,
          group: group,
          param:
              '11', //Number 11 means to the backend that it has to fetch all the teachers from the selected group and grade
          cycle: cycle)
      .timeout(const Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    try {
      // Parse the JSON response
      jsonList = json.decode(apiResultxgr.response!.body);

      // Extract nombre into causesLst
      teacherList = List<String>.from(jsonList.map((json) => json['Nombre']));
      tempTeachersList = jsonList;
      return teacherList;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

//ONLY GET THE DATA FROM  getTeacherByGradeAndGroup() RESPONSE
String? obtainEmployeeNumberbyName(List<dynamic> dataList, String targetData1) {
  for (var item in dataList) {
    if (item is Map<String, dynamic> && item.containsKey('Nombre')) {
      if (item['Nombre'] == targetData1 && item.containsKey('NoEmpleado')) {
        return item['NoEmpleado'];
      }
    }
  }
  return null; // Return null if the value is not found
}
