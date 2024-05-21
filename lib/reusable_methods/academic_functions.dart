import 'package:flutter/material.dart';

import '../backend/api_requests/api_calls_list.dart';

void loadStartGrading(int employeeNumber, String schoolYear) async {
  try {
    var startGrading = getTeacherGradeAndCourses(employeeNumber, schoolYear);
    debugPrint(startGrading.toString());
  } catch (e) {}
}
