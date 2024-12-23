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
  // String comment;
  int habits_evaluation;
  int outfit;
  int subject;
  String? subjectName;
  double evaluation;
  int? other;
  String? fulllName;

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
      // this.comment,
      this.habits_evaluation,
      this.outfit,
      this.subject,
      this.subjectName,
      this.evaluation,
      this.other,
      this.fulllName);
}

dynamic getEvalFromJSON(List<dynamic> jsonList, bool isByStudent) {
  List<StudentEval> studentEval = [];
  if (jsonList.isEmpty) {
    return null;
  } else {
    if (isByStudent == false) {
      for (var item in jsonList) {
        int rateID = item['idCicloEscolar'];
        String studentName = item['student'];
        String student1LastName = item['1lastName'];
        String student2LastName = item['2lastName'];
        String studentID = item['studentID'];
        //int grades = item['eval_type'];
        int absence = item['absence_eval'];
        int homework = item['homework_eval'];
        int discipline = item['discipline_eval'];
        // String comment = item['comment'];
        int habitsEvaluation = item['habit_eval'];
        //int outfit = item['outfit'];
        int subject = item['subjectId'];
        String? subjectName = item['subject_name'];
        double evaluation = item['evaluation'];
        int? other = item['other'];
        studentEval.add(StudentEval(
            rateID,
            studentName,
            student1LastName,
            student2LastName,
            studentID,
            0,
            absence,
            homework,
            discipline,
            // comment,
            habitsEvaluation,
            0,
            subject,
            subjectName,
            evaluation,
            other,
            '$studentName $student1LastName $student2LastName'));
      }
      return studentEval;
    } else {
      for (var item in jsonList) {
        // String rateID = item['studentID'];
        // String studentName = item['nombre'];
        // String student1LastName = item['apmaterno'];
        // String student2LastName = item['apmaterno'];
        String studentID = item['studentID'];
        int grades = 0;
        int absence = item['absence_eval'];
        int homework = item['homework_eval'];
        int discipline = item['discipline_eval'];
        // String comment = item['comment'];
        int habitsEvaluation = item['habit_eval'];
        int outfit = 0;
        int subject = item['subjectId'];
        String? subjectName = item['subject_name'];
        double evaluation = item['evaluation'];
        int? other = item['other'];
        String fullName =
            item['student'] + ' ' + item['1lastName'] + ' ' + item['2lastName'];
        studentEval.add(StudentEval(
            0,
            '',
            '',
            '',
            studentID,
            grades,
            absence,
            homework,
            discipline,
            // comment,
            habitsEvaluation,
            outfit,
            subject,
            subjectName,
            evaluation,
            other,
            fullName));
      }
      return studentEval;
    }
  }
}
