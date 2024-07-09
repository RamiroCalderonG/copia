import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/Models/Student_eval.dart';
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
      // await getStudentsByTeacher(jsonList);
      // await getStudentsIDByTeacher(jsonList);
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
      int gradeSequence = apiResponse[i]['gradeseq'];
      originalList.add(grade);
      oneTeacherGrades = originalList.toSet().toList();

      Map<int, String> currentMapValue = {gradeSequence: grade};

      teacherGradesMap.addEntries(currentMapValue.entries);
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
      int assignatureID = int.parse(apiResponse[i]['assignature_id']);
      originalList.add(assignature);

      oneTeacherAssignatures = originalList.toSet().toList();

      Map<int, String> currentMapValue = {assignatureID: assignature};
      assignaturesMap.addEntries(currentMapValue.entries);
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

Future<void> updateStudentGrades() async {}
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

Future<List<StudentEval>> getStudentsByAssinature(
    String group, gradeSelected, assignature, month) async {
  try {
    var studentsList = await getStudentsToGrade(assignature, group,
        gradeSelected, currentCycle!.claCiclo, currentUser!.claUn, month);
    List<dynamic> jsonList = json.decode(studentsList.body);

    List<StudentEval> evaluations = getEvalFromJSON(jsonList, false);

    return evaluations;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<List<StudentEval>> getSubjectsAndGradesByStudent(
    String grade, group, cycle, campus, month) async {
  try {
    var subjectsGradesList =
        await getSubjectsAndGradeByStuent(group, grade, cycle, campus, month);

    List<dynamic> jsonList = json.decode(subjectsGradesList.body);
    List<StudentEval> evaluations = getEvalFromJSON(jsonList, true);
    uniqueStudentsList.clear();
    uniqueStudents.clear();

    for (var student in jsonList) {
      uniqueStudents[student['studentID']] = student['studentName'];
      // uniqueStudents[student['studentName']] = student['studentName'];
    }

    // Convert the map to a list of maps
    uniqueStudentsList = uniqueStudents.entries
        .map((entry) => {'studentID': entry.key, 'studentName': entry.value})
        .toList();

    // print(uniqueStudentsList);

    return evaluations;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

Future<void> getCommentsForEvals(int grade) async {
  List<dynamic> commentsList;

  Map<String, String> currentValue = {};

  try {
    var response = await getStudentsGradesComments(grade);
    commentsList = json.decode(response.body);
    if (studentsGradesCommentsRows.isNotEmpty && commentStringEval.isNotEmpty) {
      studentsGradesCommentsRows.clear();
      commentStringEval.clear();
    }

    for (var item in commentsList) {
      String id = item['Comment'].toString();
      String comment = item['Name'];
      commentStringEval.add(comment);

      currentValue = {'idcomment': id.toString(), 'comentname': comment};

      studentsGradesCommentsRows.add(currentValue);
    }
  } catch (e) {
    throw ErrorDescription(e.toString());
  }
}

void composeBodyToUpdateGradeBySTudent(
    String key, studentID, dynamic value, int subject, month) {
  bool idExists = false;

  if (studentGradesBodyToUpgrade.isEmpty) {
    studentGradesBodyToUpgrade.add(
        {'student': studentID, key: value, 'subject': subject, 'month': month});
  } else {
    for (var obj in studentGradesBodyToUpgrade) {
      if (obj['student'] == studentID && obj['subject'] == subject) {
        idExists = true;
        if (obj.containsKey(key)) {
          obj[key] = value; //Update the existing value
        } else {
          obj[key] = value; //Add the new value
        }
      }
    }

    if (!idExists) {
      studentGradesBodyToUpgrade.add({
        'student': studentID,
        key: value,
        'subject': subject,
        'month': month
      });
    }
  }
}

void composeUpdateStudentGradesBody(String key, dynamic value, int rowIndex) {
  var idToupdate = studentList[rowIndex].rateID;
  bool idExists = false;

  if (studentGradesBodyToUpgrade.isEmpty) {
    studentGradesBodyToUpgrade.add({'id': idToupdate, key: value});
  } else {
    for (var obj in studentGradesBodyToUpgrade) {
      if (obj['id'] == idToupdate) {
        idExists = true;
        if (obj.containsKey(key)) {
          obj[key] = value; // Update the existing value
        } else {
          obj[key] = value; // Add the new key-value pair
        }
      }
    }
    if (!idExists) {
      studentGradesBodyToUpgrade.add({'id': idToupdate, key: value});
    }
  }
}

String validateNewGradeValue(String newValue, String columnNameToFind) {
  //If value < 50 -> returns 50
  List<String> columnName = [
    'Calif',
    'Conducta',
    'Uniforme',
    'Ausencia',
    'Tareas',
    // 'Comentarios'
  ];

  if (columnNameToFind == 'Comentarios') {
    for (var item in studentsGradesCommentsRows) {
      if (item['comentname'] == newValue) {
        // print(item['idcomment'].toString());
        return item['idcomment'].toString();
      }
    }
  }

  bool isContained = columnName.contains(columnNameToFind);

  if (isContained) {
    if (int.parse(newValue) <= 50) {
      //Validate that value can´t be less than 50
      newValue = 50.toString();
      return newValue;
    } else if (int.parse(newValue) > 100) {
      newValue = 100.toString();
      return newValue;
    } else {
      return newValue;
    }
  } else {
    return newValue;
  }
}
