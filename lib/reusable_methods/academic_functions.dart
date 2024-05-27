import 'dart:convert';

import 'package:oxschool/constants/User.dart';

import '../backend/api_requests/api_calls_list.dart';
import '../temp/teacher_grades_temp.dart';

dynamic loadStartGrading(int employeeNumber, String schoolYear) async {
  try {
    var startGrading = await getTeacherGradeAndCourses(
        currentUser!.employeeNumber, currentCycle);
    List<dynamic> jsonList = json.decode(startGrading);

    try {
      await getSingleTeacherGrades(jsonList);
      await getSingleTeacherGroups(jsonList);
      await getSingleTeacherAssignatures(jsonList);
      await getStudentsByTeacher(jsonList);
      await getStudentsIDByTeacher(jsonList);
      // await getGroupsByTeacher(jsonList);
      return 200;
    } catch (e) {
      throw FormatException(e.toString());
    }
  } catch (e) {
    throw FormatException(e.toString());
  }
}

Future<void> getSingleTeacherGrades(List<dynamic> apiResponse) async {
  List<String> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherGrades.isNotEmpty) {
      oneTeacherGrades.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String grade = apiResponse[i]['grade'];
      originalList.add(grade);
      oneTeacherGrades = originalList.toSet().toList();
    }
  }
}

Future<void> getSingleTeacherGroups(List<dynamic> apiResponse) async {
  List<String> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherGroups.isNotEmpty) {
      oneTeacherGroups.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String group = apiResponse[i]['school_group'];
      originalList.add(group);
      oneTeacherGroups = originalList.toSet().toList();
    }
  }
}

Future<void> getSingleTeacherAssignatures(List<dynamic> apiResponse) async {
  List<String> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherAssignatures.isNotEmpty) {
      oneTeacherAssignatures.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String assignature = apiResponse[i]['assignature_name'];
      originalList.add(assignature);
      oneTeacherAssignatures = originalList.toSet().toList();
    }
  }
}

Future<void> getStudentsByTeacher(List<dynamic> apiResponse) async {
  List<String> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherStudents.isNotEmpty) {
      oneTeacherStudents.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      String studentName = apiResponse[i]['student_name'];
      originalList.add(studentName);
      oneTeacherStudents = originalList.toSet().toList();
    }
  }
}

Future<void> getStudentsIDByTeacher(List<dynamic> apiResponse) async {
  List<int> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherStudentID.isNotEmpty) {
      oneTeacherStudentID.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      int studentID = apiResponse[i]['student_id'];
      originalList.add(studentID);
      oneTeacherStudentID = originalList.toSet().toList();
    }
  }
}

// Future<void> getGroupsByTeacher(List<dynamic> apiResponse) async {
//   List<String> originalList = [];
//   if (apiResponse.isNotEmpty) {
//     if (oneTeacherGroup.isNotEmpty) {
//       oneTeacherGroup.clear();
//     }
//     for (var i = 0; i < apiResponse.length; i++) {
//       String teacherGroups = apiResponse[i]['school_group'];
//       originalList.add(teacherGroups);
//       oneTeacherGroup = originalList.toSet().toList();
//     }
//   }
// }
