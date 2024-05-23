import 'dart:convert';

import 'package:oxschool/constants/User.dart';

import '../backend/api_requests/api_calls_list.dart';
import '../temp/teacher_grades_temp.dart';

void loadStartGrading(int employeeNumber, String schoolYear) async {
  try {
    var startGrading = await getTeacherGradeAndCourses(
        currentUser!.employeeNumber, currentCycle);
    List<dynamic> jsonList = json.decode(startGrading);

    try {
      getSingleTeacherGrades(jsonList);
      getSingleTeacherGroups(jsonList);
      getSingleTeacherAssignatures(jsonList);
    } catch (e) {
      throw FormatException(e.toString());
    }
  } catch (e) {
    throw FormatException(e.toString());
  }
}

void getSingleTeacherGrades(List<dynamic> apiResponse) async {
  if (apiResponse.isNotEmpty) {
    if (oneTeacherGrades.isNotEmpty) {
      oneTeacherGrades.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String grade = apiResponse[i]['grade'];
      oneTeacherGrades.add(grade);
    }
  }
}

void getSingleTeacherGroups(List<dynamic> apiResponse) async {
  if (apiResponse.isNotEmpty) {
    if (oneTeacherGroups.isNotEmpty) {
      oneTeacherGroups.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String group = apiResponse[i]['school_group'];
      oneTeacherGroups.add(group);
    }
  }
}

void getSingleTeacherAssignatures(List<dynamic> apiResponse) async {
  if (apiResponse.isNotEmpty) {
    for (var i = 0; i < apiResponse.length; i++) {
      String assignature = apiResponse[i]['assignature_name'];
      oneTeacherAssignatures.add(assignature);
    }
  }
}
