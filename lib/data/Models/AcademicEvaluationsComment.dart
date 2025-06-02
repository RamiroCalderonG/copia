class Academicevaluationscomment {
  int commentId;
  String commentName;
  bool isActive;
  int academicLevel;
  int gradeSequence;
  // int sesionId;

  Academicevaluationscomment(this.commentId, this.commentName, this.isActive,
      this.academicLevel, this.gradeSequence);

  Academicevaluationscomment.fromJson(Map<String, dynamic> json)
      : commentId = json['commentKey'],
        commentName = json['commentName'],
        isActive = json['isDeactivated'] ?? false,
        academicLevel = json['scholarGrade'],
        gradeSequence = json['sequence'];
  // sesionId = json['sesionId'];
}
