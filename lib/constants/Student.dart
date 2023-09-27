import 'package:oxschool/Models/Family.dart';
import 'package:oxschool/Models/Medicines.dart';
import 'package:oxschool/Models/Student.dart';

late Student? nurseryStudent; //Student data getted from nursery/student
var selectedStudent; //Student data getted from nursery/student
var nurseryHistoryStudent; //Student history from Nursery, from /nursery/history

late var selectedFamily; //Selected family from /family
late Family? studentFamily; //Selected family from /family
var studentAllowedMedicines; //Medicines allowed from the current student
var studentsList; //Students to update grades

void clearStudentData() {
  if (nurseryStudent?.claFamilia != null) {
    nurseryStudent?.clear();
  }
  if (studentFamily?.idFamilyDet != null) {
    studentFamily?.clear();
  }

  selectedStudent = null;
  nurseryHistoryStudent = null;
  selectedFamily = null;

  studentAllowedMedicines = null;
}
