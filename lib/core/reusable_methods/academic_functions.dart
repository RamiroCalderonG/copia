import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';

import 'package:oxschool/data/Models/Student_eval.dart';
import 'package:oxschool/core/constants/user_consts.dart';

import '../../data/datasources/temp/studens_temp.dart';
import '../../data/services/backend/api_requests/api_calls_list.dart';

import '../../data/datasources/temp/teacher_grades_temp.dart';

dynamic loadStartGrading(int employeeNumber, String schoolYear) async {
  try {
    DateTime now = DateTime.now();
    int month = now.month;
    //FETCH FOR TEACHER DATA
    var startGrading = await getTeacherGradeAndCourses(
        currentUser!.employeeNumber, currentCycle, month);
    List<dynamic> jsonList = json.decode(startGrading);
    jsonDataForDropDownMenuClass = jsonList;
    fetchedDataFromloadStartGrading = jsonList;

    try {
      getTeacherEvalCampuses(jsonList);
      await getSingleTeacherGrades(jsonList);
      await getSingleTeacherGroups(jsonList);
      await getSingleTeacherAssignatures(jsonList);

      return jsonList;
    } catch (e) {
      rethrow;
    }
  } catch (e) {
    insertErrorLog(e.toString(), ' INIT STUDENT EVALUATION GRID ');
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
      String grade = apiResponse[i]['Grade'];
      int gradeSequence = apiResponse[i]['Sequence'];
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
      String group = apiResponse[i]['School_group'];

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
      String assignature = apiResponse[i]['Subject'];
      int assignatureID = apiResponse[i]['Subject_id'];
      originalList.add(assignature);

      oneTeacherAssignatures = originalList.toSet().toList();

      Map<int, String> currentMapValue = {assignatureID: assignature};
      assignaturesMap.addEntries(currentMapValue.entries);
    }
  }
}

Future<List<dynamic>> getStudentsByTeacher(
    int employeeNumber, String selectedCycle, roleName) async {
  var response = await getStudentsByRole(employeeNumber, roleName);
  List<dynamic> jsonList = json.decode(response);

  return jsonList;
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
    String group,
    String gradeSelected,
    String assignature,
    String month,
    String campus) async {
  try {
    var studentsList = await getStudentsToGrade(assignature, group,
        gradeSelected, currentCycle!.claCiclo, campus, month);
    List<dynamic> jsonList = json.decode(studentsList.body);

    List<StudentEval> evaluations = getEvalFromJSON(jsonList, false);

    return evaluations;
  } catch (e) {
    if (e is TimeoutException) {
      return throw TimeoutException(e.toString());
    }
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
    if (e is TimeoutException) {
      return throw TimeoutException(e.toString());
    }
    return throw FormatException(e.toString());
  }
}

Future<void> getCommentsForEvals(int grade) async {
  List<dynamic> commentsList;

  Map<String, String> currentValue = {};

  try {
    var response = await getStudentsGradesComments(grade, false, null, null);
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

Future<List<Map<String, dynamic>>> getCommentsAsignatedToStudent(
    int grade, bool byStudent, String? studentid, int? month) async {
  List<Map<String, dynamic>> assignatedComments = [];
  Map<String, dynamic> currentValue = {};
  try {
    var response = await getStudentsGradesComments(
        grade, byStudent, studentid!.trim(), month);
    var commentsResponse = json.decode(response.body);

    for (var item in commentsResponse) {
      int evalId = item['student_rate'];
      int commentid = item['comment'];
      // var month = item['month'];
      bool active = item['active'];
      String subject = item['subject'];
      String commentName = item['commentName'];
      currentValue = {
        'student_rate': evalId,
        'comment': commentid,
        'active': active,
        'subject': subject,
        'commentName': commentName
      };
      assignatedComments.add(currentValue);
    }

    return assignatedComments;
  } catch (e) {
    throw ErrorDescription(e.toString());
  }
}

List<Map<String, dynamic>> mergeCommentsData(
    List<Map<String, dynamic>> allItemAvailables,
    List<Map<String, dynamic>> actualData) {
  // Create maps for 'active' and 'name2' values keyed by 'comment'
  Map<int, bool> isActiveMap = {
    for (var item in actualData) item['comment']: item['active']
  };
  Map<int, String> name2Map = {
    for (var item in actualData) item['comment']: item['subject']
  };

  // Merge data
  return allItemAvailables.map((item) {
    int id = int.parse(item['idcomment']);
    bool isActive = isActiveMap[id] ?? false;
    String name2 = name2Map[id] ?? '';
    return {
      ...item,
      'is_active': isActive,
      'subject': name2,
    };
  }).toList();
}

void composeBodyToUpdateGradeBySTudent(
    String key, studentID, int value, int subject, month) {
  bool idExists = false;

  if (studentGradesBodyToUpgrade.isEmpty) {
    studentGradesBodyToUpgrade.add(
        {'student': studentID, key: value, 'subject': subject, 'month': month});
  } else {
    for (var obj in studentGradesBodyToUpgrade) {
      if (obj['student'] == studentID && obj['subject'] == subject) {
        //If already exist data for selected student
        idExists = true;
        if (key == 'Comentarios') {
          //Comentarios are stores diferent
          var oldValue = obj[key];
          if (oldValue == null) {
            obj[key] = value;
          } else {
            var oldValue = obj[
                key]; //in case already exist a value, it will add it at the end
            List<dynamic> numbersList =
                oldValue.split(',').map(int.parse).toList();

            // Step 2: Convert the list to a set to handle duplicates
            Set<dynamic> numbersSet = numbersList.toSet();
            // Step 3: Add the new number if it’s not already present
            int newNum = value;
            if (!numbersSet.contains(newNum)) {
              numbersSet.add(newNum);
            }

            // Step 4: Convert the set back to a string
            String updatedNumbersString = numbersSet.join(',');
            commentsIntEval = numbersSet.toList();

            var newValue = updatedNumbersString;
            obj[key] = newValue;
          }
        } else {
          if (obj.containsKey(key)) {
            obj[key] = value; //Update the existing value
          } else {
            obj[key] = value; //Add the new value
          }
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

Future<String> createFodac27Record(String date, String studentID, String cycle,
    String observations, int employeeNumber, int subject) async {
  var responseCode = await postFodac27Record(
      date, studentID, cycle, observations, employeeNumber, subject);

  if (responseCode.statusCode == 200) {
    return 'Succes';
  } else {
    return 'Error: ${responseCode.body}';
  }
}

Future<int> updateFodac27Record(
  Map<String, dynamic> fodac27,
) async {
  int response = await editFodac27Record(fodac27);
  return response;
}

Future<Map<String, dynamic>> populateSubjectsDropDownSelector(
    String studentID, String cycle) async {
  try {
    var subjects = await getStudentSubjects(studentID, cycle);

    if (subjects.statusCode != 200) {
      return {'error': 'Error fetching subjects'};
    }
    var subjectsList = jsonDecode(subjects.body);
    Map<String, dynamic> result = {};

    for (var item in subjectsList) {
      result[item['subject']] = item['subject2'];

      // result.add(item['subject']);
    }

    return result;
  } catch (e) {
    return throw FormatException(e.toString());
  }
}

//Function that validate that value can´t be less than 50 and more than 100
int validateNewGradeValue(int newValue, String columnNameToFind) {
  //If value < 50 -> returns 50
  List<String> columnName = [
    'Calif',
    'Conducta',
    'Uniforme',
    'Ausencia',
    'Tareas',
    // 'Comentarios'
  ];

  bool isContained = columnName.contains(columnNameToFind);

  if (isContained) {
    if (newValue <= 50) {
      //Validate that value can´t be less than 50
      newValue = 50;
      return newValue;
    } else if (newValue > 100) {
      newValue = 100;
      return newValue;
    } else {
      return newValue;
    }
  } else {
    return newValue;
  }
}

Future<dynamic> isDateToEvaluateStudents() async {
  try {
    var originDate = await getActualDate().catchError((error) {
      return error;
    });
    var originResponse = jsonDecode(originDate);
    var response = originResponse['Value'];
    return response;
  } catch (e) {
    insertErrorLog(e.toString(), 'FETCH DATE FOR STUDENT EVALUATION');
    return throw Future.error(e);
  }
}

void getTeacherEvalCampuses(List<dynamic> jsonData) {
  if (jsonData.isNotEmpty) {
    for (var item in jsonData) {
      // Check if the item has the "campus" key and is a String
      if (item.containsKey('Campus') && item['Campus'] is String) {
        campusesWhereTeacherTeach.add(item['Campus']);
      }
    }
  }
}

void searchGradesBySubjectButton(
  String grade,
  String group,
  String subject,
  String month,
  String? campus,
) async {
  try {
    studentList =
        await getStudentsByAssinature(group, grade, subject, month, campus!);
    await getCommentsForEvals(int.parse(grade));
  } catch (e) {
    throw FormatException(e.toString());
  }
}

List<Map<String, dynamic>> filterCommentsBySubject(
  List<Map<String, dynamic>> comments,
  String subjectName,
) {
  var returnedComments = comments
      .where((comment) => comment['subject'].trim() == subjectName)
      .toList();

  return returnedComments;
}

Future<List<Map<String, dynamic>>> getGradesAndGroupsByCampus(
    String cycle) async {
  var response = await getGlobalGradesAndGroups(cycle);
  List<dynamic> data = jsonDecode(response);
  List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(data);

  return items;
}

Future<List<String>> getStudentsListForFodac27(
    String campus, String cycle, String grade, String group) async {
  var response = await getStudentsForFodac27(grade, group, campus, cycle);
  var data = jsonDecode(response);

  List<String> resultData = [];

  for (var item in data) {
    resultData.add(item['name']);
    Map<String, String> itemMap = {};
    itemMap['name'] = item['name'];
    itemMap['studentID'] = item['studentID'];
    tempStudentMap.add(itemMap);
  }
  return resultData;
}
