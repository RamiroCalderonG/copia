import 'dart:async';

import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/AcademicEvaluationsComment.dart';
import 'package:oxschool/data/Models/Student.dart';

import 'package:oxschool/data/Models/Student_eval.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/temp/studens_temp.dart';
import '../../data/services/backend/api_requests/api_calls_list_dio.dart';

import '../../data/datasources/temp/teacher_grades_temp.dart';

//Function to fetch groups, grades, campuses where it teach, and subjects from selected user
//is use is academic coordinator will retrive all grades under its coordination
dynamic loadStartGrading(int employeeNumber, String schoolYear, bool isAdmin,
    bool isAcademicCoordinator, String? campus) async {
  try {
    DateTime now = DateTime.now();
    int month = now.month;
    List<dynamic> jsonList;
    //FETCH FOR TEACHER DATA
    await getTeacherGradeAndCourses(currentUser!.employeeNumber, currentCycle,
            month, isAdmin, isAcademicCoordinator, campus)
        .then((onValue) {
      jsonList = onValue.data;
      jsonDataForDropDownMenuClass = jsonList;
      fetchedDataFromloadStartGrading = jsonList;
      try {
        getTeacherEvalCampuses(jsonList);
        getSingleTeacherGrades(jsonList);
        getSingleTeacherGroups(jsonList);
        getSingleTeacherAssignatures(jsonList);
        return jsonList;
      } catch (e) {
        rethrow;
      }
    }).catchError((onError) {
      insertErrorLog('Error fetching start grading data', onError);
      throw FormatException(onError);
    });
    // List<dynamic> jsonList = json.decode(startGrading);
  } catch (e) {
    insertErrorLog(e.toString(), ' INIT STUDENT EVALUATION GRID ');
    throw FormatException(e.toString());
  }
}

Future<dynamic> loadStartGradingAsAdminOrAcademicCoord(
    String schoolYear,
    String? campus,
    bool initialFetch,
    int? subject,
    int? group,
    bool isAcademicCoord,
    bool isAdmin) async {
  try {
    DateTime now = DateTime.now();
    int month = now.month;
    List<dynamic> jsonList;
    List<String> originalList = [];
    if (initialFetch) {
      //First time loading screen, to display all grades, groups, campus and assignatures to dispaly at DropdownSelector
      await getTeacherGradeAndCoursesAsAdmin(month, isAdmin,
              isAdmin ? null : campus, currentCycle!.claCiclo, isAcademicCoord)
          .then((response) {
        jsonList = response.data;
        jsonDataForDropDownMenuClass = jsonList;
        try {
          for (var item in jsonList) {
            // Check if the item has the "campus" key and is a String
            if (item.containsKey('campus') && item['campus'] is String) {
              campusesWhereTeacherTeach.add(item['campus']);
            }
          }
          originalList.clear();
          for (var i = 0; i < jsonList.length; i++) {
            originalList.add(jsonList[i]['grade']);
            oneTeacherGrades = originalList.toSet().toList();

            Map<int, String> currentMapValue = {
              jsonList[i]['sequence']: jsonList[i]['grade']
            };

            teacherGradesMap.addEntries(currentMapValue.entries);
          }

          if (oneTeacherGroups.isNotEmpty) {
            oneTeacherGroups.clear();
          }
          originalList.clear();
          for (var i = 0; i < jsonList.length; i++) {
            // String group = apiResponse[i]['School_group'];
            originalList.add(jsonList[i]['school_group']);
            oneTeacherGroups = originalList.toSet().toList();
          }
          originalList.clear();
          for (var i = 0; i < jsonList.length; i++) {
            // String assignature = apiResponse[i]['Subject'];
            // int assignatureID = apiResponse[i]['Subject_id'];
            originalList.add(jsonList[i]['subject']);

            oneTeacherAssignatures = originalList.toSet().toList();

            Map<int, String> currentMapValue = {
              jsonList[i]['subject_id']: jsonList[i]['subject']
            };
            assignaturesMap.addEntries(currentMapValue.entries);
          }

          // getSingleTeacherGroups(jsonList);
        } catch (e) {
          throw Future.error(e.toString());
        }
      }).catchError((onError) {
        insertErrorLog(
            'Error fetching start grading data loadStartGradingAsAdmin()',
            onError);
        throw FormatException(onError);
      });
    } else {
      //When admin wants to retreive data for a specific grade and assignature
      //TODO: PENDING TO IMPLEMENT
    }
  } catch (e) {
    insertErrorLog(e.toString(), ' loadStartGradingAsAdmin  ');
    throw Future.error(e.toString());
  }
}

Future<void> getSingleTeacherGrades(List<dynamic> apiResponse) async {
  List<String> originalList = [];
  if (apiResponse.isNotEmpty) {
    if (oneTeacherGrades.isNotEmpty) {
      oneTeacherGrades.clear();
    }
    for (var i = 0; i < apiResponse.length; i++) {
      // String grade = apiResponse[i]['Grade'];
      // int gradeSequence = apiResponse[i]['Sequence'];
      originalList.add(apiResponse[i]['Grade']);
      oneTeacherGrades = originalList.toSet().toList();

      Map<int, String> currentMapValue = {
        apiResponse[i]['Sequence']: apiResponse[i]['Grade']
      };

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
      // String group = apiResponse[i]['School_group'];

      originalList.add(apiResponse[i]['School_group']);
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
      // String assignature = apiResponse[i]['Subject'];
      // int assignatureID = apiResponse[i]['Subject_id'];
      originalList.add(apiResponse[i]['Subject']);

      oneTeacherAssignatures = originalList.toSet().toList();

      Map<int, String> currentMapValue = {
        apiResponse[i]['Subject_id']: apiResponse[i]['Subject']
      };
      assignaturesMap.addEntries(currentMapValue.entries);
    }
  }
}

Future<List<dynamic>> getStudentsByTeacher(String selectedCycle) async {
  var response = await getStudentsByRole(selectedCycle);
  dynamic jsonList = response.data;

  for (var item in jsonList) {
    String campus = item['Claun'];
    String grade = item['GradoSecuencia'].toString();
    String group = item['Grupo'];
    String gradeName = item['gradeName'];

    if (!teacherCampusListFODAC27.contains(campus)) {
      teacherCampusListFODAC27.add(campus);
    }
    if (!teacherGradesListFODAC27.contains(grade)) {
      teacherGradesListFODAC27.add(grade);
    }
    if (!gradesMapFODAC27.containsKey(gradeName.trim())) {
      gradesMapFODAC27[gradeName.trim()] = int.parse(grade);
    }
  }

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
    String campus,
    int? teacher) async {
  try {
    var studentsList = await getStudentsToGrade(
        assignature,
        group,
        gradeSelected,
        currentCycle!.claCiclo,
        campus,
        month,
        currentUser!.isCurrentUserAdmin(),
        currentUser!.isCurrentUserAcademicCoord(),
        teacher);
    var jsonList = studentsList.data;
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
    int grade,
    String group,
    String cycle,
    String campus,
    int month,
    bool isAdmin,
    bool isAcademicCoord,
    int? teacher) async {
  try {
    var subjectsGradesList = await getSubjectsAndGradeByStuent(
        group, grade, cycle, campus, month, isAdmin, isAcademicCoord, teacher);
    if (subjectsGradesList != null) {
      List<dynamic> jsonList = subjectsGradesList.data;
      List<StudentEval> evaluations = getEvalFromJSON(jsonList, true);
      uniqueStudentsList.clear();
      uniqueStudents.clear();

      for (var student in jsonList) {
        uniqueStudents[student['studentID']] = student['firstlastName'] +
            ' ' +
            student['secondlastName'] +
            ' ' +
            student['student'];
      }

      // Convert the map to a list of maps
      uniqueStudentsList = uniqueStudents.entries
          .map((entry) => {'studentID': entry.key, 'studentName': entry.value})
          .toList();

      // print(uniqueStudentsList);

      return evaluations;
    } else {
      throw Exception('No data found for the given parameters.');
    }
  } catch (e) {
    if (e is TimeoutException) {
      return throw TimeoutException(e.toString());
    }
    return throw FormatException(e.toString());
  }
}

// Future<void> getCommentsForEvals(int grade) async {
//   List<dynamic> commentsList;

//   Map<String, String> currentValue = {};

//   try {
//     var response = await getStudentsGradesComments(grade, false, null, null);
//     commentsList = json.decode(response.body);
//     if (studentsGradesCommentsRows.isNotEmpty && commentStringEval.isNotEmpty) {
//       studentsGradesCommentsRows.clear();
//       commentStringEval.clear();
//     }

//     for (var item in commentsList) {
//       String id = item['Comment'].toString();
//       String comment = item['Name'];
//       commentStringEval.add(comment);

//       currentValue = {'idcomment': id.toString(), 'comentname': comment};

//       studentsGradesCommentsRows.add(currentValue);
//     }
//   } catch (e) {
//     throw ErrorDescription(e.toString());
//   }
// }

// Future<List<Map<String, dynamic>>> getCommentsAsignatedToStudent(
//     int grade, bool byStudent, String? studentid, int? month) async {
//   List<Map<String, dynamic>> assignatedComments = [];
//   Map<String, dynamic> currentValue = {};
//   try {
//     var response = await getStudentsGradesComments(
//         grade, byStudent, studentid!.trim(), month);
//     var commentsResponse = json.decode(response.body);

//     for (var item in commentsResponse) {
//       int evalId = item['student_rate'];
//       int commentid = item['comment'];
//       // var month = item['month'];
//       bool active = item['active'];
//       String subject = item['subject'];
//       String commentName = item['commentName'];
//       currentValue = {
//         'student_rate': evalId,
//         'comment': commentid,
//         'active': active,
//         'subject': subject,
//         'commentName': commentName
//       };
//       assignatedComments.add(currentValue);
//     }

//     return assignatedComments;
//   } catch (e) {
//     throw ErrorDescription(e.toString());
//   }
// }

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
    String key, studentID, int value, int evalId, month) {
  bool idExists = false;

  if (studentGradesBodyToUpgrade.isEmpty) {
    studentGradesBodyToUpgrade.add({
      'student': studentID,
      'eval': value,
      'idEval': evalId,
      'month': month
    });
  } else {
    for (var obj in studentGradesBodyToUpgrade) {
      if (obj['student'] == studentID && obj['idEval'] == evalId) {
        //*If already exist data for selected student
        idExists = true;
        if (key == 'Comentarios') {
          //*Comentarios are stores diferent
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
          if (obj.containsKey('eval')) {
            obj['eval'] = value; //Update the existing value
          } else {
            obj['eval'] = value; //Add the new value
          }
        }
      }
    }

    if (!idExists) {
      studentGradesBodyToUpgrade.add({
        'student': studentID,
        'eval': value,
        'idEval': evalId,
        'month': month
      });
    }
  }
}

void composeUpdateStudentGradesBody(
    String key, dynamic value, int idEval) async {
  bool idExists = false;
  SharedPreferences devicePrefs = await SharedPreferences.getInstance();
  int? idSesion = devicePrefs.getInt("idSession");

  if (key == 'Calificación') {
    key = 'eval';
  }
  if (key == 'Hab') {
    key = 'homework';
  }
  if (key == 'Con') {
    key = 'behavior';
  }
  if (key == 'R') {
    key = 'homework';
  }
  if (key == 'Comentarios') {
    key = 'Comment';
  }
  if (key == 'Faltas') {
    key = 'absences';
  }

  if (studentGradesBodyToUpgrade.isEmpty) {
    studentGradesBodyToUpgrade
        .add({'idEval': idEval, key: value, 'idSesion': idSesion});
  } else {
    for (var obj in studentGradesBodyToUpgrade) {
      if (obj['idEval'] == idEval) {
        idExists = true;
        if (obj.containsKey(key)) {
          obj[key] = value; // Update the existing value
        } else {
          obj[key] = value; // Add the new key-value pair
        }
      }
    }
    if (!idExists) {
      studentGradesBodyToUpgrade
          .add({'idEval': idEval, key: value, 'idSesion': idSesion});
    }
  }
}

Future<dynamic> createFodac27Record(DateTime date, String studentID,
    String cycle, String observations, int employeeNumber, int subject) async {
  // var responseCode =
  try {
    var result = await postFodac27Record(
            date, studentID, cycle, observations, employeeNumber, subject)
        .catchError((error) {
      return Future.error('Error: ${error.toString()}');
    });
    return result;
  } catch (e) {
    Future.error(e.toString());
  }

  // if (responseCode.statusCode == 200) {
  //   return 'Succes';
  // } else {
  //   return 'Error: ${responseCode.body}';
  // }
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
    var subjects = await getStudentSubjects(studentID, cycle).catchError((e) {
      return {'error': 'Error fetching subjects ${e.toString()}'};
    });
    // if (subjects.statusCode != 200) {
    //   return {'error': 'Error fetching subjects'};
    // }
    var subjectsList = subjects.data;
    Map<String, dynamic> result = {};

    for (var item in subjectsList) {
      result[item['subject'].trim()] = item['subject2'];
    }

    return result;
  } catch (e) {
    return Future.error(e.toString());
  }
}

//Function that validate that value can´t be less than 50 and more than 100
int validateNewGradeValue(dynamic newValue, String columnNameToFind) {
  //If value < 50 -> returns 50, if value > 100 -> returns 100
  List<String> columnName = [
    'Calif',
    //'Conducta',
    //'Uniforme',
    //'Ausencia',
    //'Tareas'
    // 'Comentarios'
  ];

  bool isContained = columnName.contains(columnNameToFind);

  //! If column name is one of the above, validate the value
  if (isContained) {
    // Convert to integer if it's a double
    if (newValue is double) {
      newValue = newValue.toInt();
    }

    // Convert to int if it's a string number
    if (newValue is String) {
      try {
        newValue = int.parse(newValue);
      } catch (e) {
        // If parsing fails, return 50 as default
        return 50;
      }
    }

    // Ensure newValue is an integer
    if (newValue is! int) {
      return 50;
    }

    // For 'Calif' column, enforce stricter validation (50-100)
    if (columnNameToFind == 'Calif') {
      if (newValue < 50) {
        //Validate that value can´t be less than 50
        return 50;
      } else if (newValue > 100) {
        return 100;
      } else {
        return newValue;
      }
    } else {
      // For other columns, use the original logic
      if (newValue <= 50) {
        return 50;
      } else if (newValue > 100) {
        return 100;
      } else {
        return newValue;
      }
    }
  } else {
    return newValue;
  }
}

Future<dynamic> isDateToEvaluateStudents() async {
  try {
    var originDate = await getActualDate().catchError((error) {
      return Future.error(error);
    });
    var originResponse = originDate; //jsonDecode(originDate);
    var response = originResponse['Value'];
    if (!response) {
      return Future.error(
          'No se puede acceder en este momento, intente más tarde.');
    }
    return response;
  } catch (e) {
    insertErrorLog(e.toString(), 'FETCH DATE FOR STUDENT EVALUATION');
    return Future.error(e);
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

// void searchGradesBySubjectButton(
//   String grade,
//   String group,
//   String subject,
//   String month,
//   String? campus,
// ) async {
//   try {
//     studentList =
//         await getStudentsByAssinature(group, grade, subject, month, campus!);
//     await getCommentsForEvals(int.parse(grade));
//   } catch (e) {
//     throw FormatException(e.toString());
//   }
// }

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
  List<dynamic> data = response.data; //jsonDecode(response);
  List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(data);

  return items;
}

Future<List<String>> getStudentsListForFodac27(
    String campus, String cycle, String grade, String group) async {
  var response = await getStudentsForFodac27(grade, group, campus, cycle);
  var data = response.data; //jsonDecode(response);

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

Future<dynamic> getStudentsDisciplinaryReportsByDates(
    String cycle, String initialDate, String finalDate) async {
  try {
    var response =
        await getDisciplinaryReportsByDate(cycle, initialDate, finalDate);
    return response;
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> getDisciplinaryCausesToPopulateScreen(
    int kindOfReport, int gradeSequence) async {
  try {
    return await getDisciplinaryCauses(gradeSequence, kindOfReport);
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> createDisciplinaryReportF(Map<String, dynamic> body) async {
  try {
    return await createDisciplinaryReport(body);
  } catch (e) {
    rethrow;
  }
}

Future<List<Student>> getSimpleStudentsByCycle(String cycle) async {
  try {
    var response = await getStudentsByDynamicParam("cycle", cycle);
    List<Student> resultData = [];
    for (var item in response) {
      resultData.add(Student.fromJson(item));
    }

    return resultData;
  } catch (e) {
    insertErrorLog(e.toString(), 'getSimpleStudentsByCycle($cycle)');
    rethrow;
  }
}

Future<dynamic> getTeachersListByCycle(String cycle) async {
  try {
    var response = await getTeachersGradeGroupSubjectsByCycle(cycle);

    // List<Map<String, dynamic>> data = response;
    return response;
  } catch (e) {
    insertErrorLog(e.toString(), 'getTeachersListByCycle($cycle)');
    rethrow;
  }
}

Future<List<Academicevaluationscomment>> getEvaluationsCommentsByGradeSequence(
    int gradeSequence) async {
  try {
    var response = await getStudentsGradesComments(gradeSequence);
    List<Academicevaluationscomment> commentsList = [];
    if ((response.isNotEmpty) || (response.length > 0)) {
      for (var element in response) {
        Academicevaluationscomment comment =
            Academicevaluationscomment.fromJson(element);
        if (commentsList.isEmpty) {
          commentsList.add(comment);
        } else {
          // Check if the comment already exists in the list
          bool exists =
              commentsList.any((c) => c.commentId == comment.commentId);
          if (!exists) {
            commentsList.add(comment);
          }
        }
      }
      return commentsList;
    } else {
      return [];
    }
  } catch (e) {
    insertErrorLog(
        e.toString(), 'getEvaluationsCommentsByGradeSequence($gradeSequence)');
    rethrow;
  }
}
