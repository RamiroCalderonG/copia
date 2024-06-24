import 'dart:convert';

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

    List<StudentEval> evaluations = getEvalFromJSON(jsonList);

    return evaluations;
  } catch (e) {
    return throw FormatException(e.toString());
  }

  // try {
  //   if (jsonList.isNotEmpty) {
  //     if (oneTeacherStudents.isNotEmpty) {
  //       oneTeacherStudents.clear();
  //     }
  //     for (var i = 0; i < jsonList.length; i++) {
  //       int rateID = jsonList[i]['id'];
  //       String studentName = jsonList[i]['student_name'];
  //       String student1LastName = jsonList[i]['1lastName'];
  //       String student2LastName = jsonList[i]['2lastName'];
  //       String studentID = jsonList[i]['studentID'];
  //       int grades = jsonList[i]['eval_type'];
  //       int absence = jsonList[i]['absence_eval'];
  //       int homework = jsonList[i]['homework_eval'];
  //       int discipline = jsonList[i]['discipline_eval'];
  //       int comment = jsonList[i]['comment'];
  //       int habits_evaluation = jsonList[i]['habit_eval'];
  //       int other = jsonList[i]['other'];
  //       int subject = jsonList[i]['subject'];

  //       oneTeacherStudentID.add(studentID);
  //       oneTeacherStudents.add(studentName);
  //       gradesID.add(grades);
  //     }
  //   }
  // } catch (e) {}
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

// dynamic patchStudentGradesToDB() async {
//   var response = await patchStudentsGrades(studentGradesBodyToUpgrade);
//   if (response == 200) {
//     return 200;
//   } else {
//     return 400;
//   }

//   // return response;
// }

String validateNewGradeValue(String newValue, String columnNameToFind) {
  //If value < 50 -> returns 50
  List<String> columnName = [
    'Calif',
    'Conducta',
    'Uniforme',
    'Ausencia',
    'Tareas',
    'Comentarios'
  ];

  bool isContained = columnName.contains(columnNameToFind);

  if (isContained) {
    if (int.parse(newValue) <= 50) {
      newValue = 50.toString();
      return newValue;
    } else {
      return newValue;
    }
  } else {
    return newValue;
  }
}
