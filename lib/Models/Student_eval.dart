class StudentEval {
  int rateID;
  String studentName;
  String student1LastName;
  String student2LastName;
  String studentID;
  int grades;
  int absence;
  int homework;
  int discipline;
  int comment;
  int habits_evaluation;
  int other;
  int subject;

  StudentEval(
      this.rateID,
      this.studentName,
      this.student1LastName,
      this.student2LastName,
      this.studentID,
      this.grades,
      this.absence,
      this.homework,
      this.discipline,
      this.comment,
      this.habits_evaluation,
      this.other,
      this.subject);
}

dynamic getEvalFromJSON(List<dynamic> jsonList) {
  List<StudentEval> studentEval = [];
  if (jsonList.isEmpty) {
    return null;
  } else {
    for (var item in jsonList) {
      int rateID = jsonList[item]['id'];
      String studentName = jsonList[item]['student_name'];
      String student1LastName = jsonList[item]['1lastName'];
      String student2LastName = jsonList[item]['2lastName'];
      String studentID = jsonList[item]['studentID'];
      int grades = jsonList[item]['eval_type'];
      int absence = jsonList[item]['absence_eval'];
      int homework = jsonList[item]['homework_eval'];
      int discipline = jsonList[item]['discipline_eval'];
      int comment = jsonList[item]['comment'];
      int habits_evaluation = jsonList[item]['habit_eval'];
      int other = jsonList[item]['other'];
      int subject = jsonList[item]['subject'];
      studentEval.add(StudentEval(
          rateID,
          studentName,
          student1LastName,
          student2LastName,
          studentID,
          grades,
          absence,
          homework,
          discipline,
          comment,
          habits_evaluation,
          other,
          subject));
    }
  }
}
