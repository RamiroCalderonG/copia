import 'package:oxschool/data/Models/Student_eval.dart';
import 'package:pluto_grid/pluto_grid.dart';

List<String> oneTeacherGrades = [];
List<String> oneTeacherGroups = [];
List<String> oneTeacherAssignatures = [];
List<String> oneTeacherStudents = [];
List<int> oneTeacherStudentID = [];
List<int> gradesID = [];
// List<String> oneTeacherGroup = [];
Map<int, String> assignaturesMap = {};
Map<int, String> teacherGradesMap =
    {}; //Stores teacher employeeNo, cycle, campus, grade, group, subject_id, subject_name, gradeseq

List<StudentEval> studentList = [];
List<PlutoRow> assignatureRows = [];
List<PlutoRow> studentEvaluationRows = []; //used at grades_per_student.dart
List<PlutoRow> selectedStudentRows = []; //used at grades_per_student.dart

List<Map<String, dynamic>> studentGradesBodyToUpgrade =
    []; //user at grades_by_assignature.dart
List<Map<String, dynamic>> gradesByStudentBodyToUpgrade =
    []; //used at grades_per_student.dart
List<Map<String, String>> studentsGradesCommentsRows = [];
List<Map<String, dynamic>> commentsAsignated = [];
List<PlutoRow> evaluationComments = [];

// Set<Map<String, String>> uniqueStudents = {};
Map<String, String> uniqueStudents = {};
List<Map<String, String>> uniqueStudentsList = [];
List<StudentEval> selectedStudentList = [];
//int campusCount = 0; //Count for how many campus does the teacher teaches.
Set<String> campusesWhereTeacherTeach =
    {}; //When the teacher teaches in more than one campus, store the name from the campus
List<dynamic> jsonDataForDropDownMenuClass = [];

List<String> commentStringEval = [];
List<dynamic> commentsIntEval = [];
List<Map<String, dynamic>> mergedData = [];
List<PlutoRow> commentsAsignatedList = [];
