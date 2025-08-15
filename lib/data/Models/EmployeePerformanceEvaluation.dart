// ignore_for_file: file_names

class EmployeePerformanceEvaluation {
  String? evaluationId;
  String? employeeId;
  String? employeeName;
  String? evaluatorId;
  String? evaluatorName;
  String? department;
  String? position;
  DateTime? evaluationDate;
  DateTime? dueDate;
  String? status; // 'Pending', 'In Progress', 'Completed', 'Overdue'
  String? period; // 'Q1 2024', 'Annual 2024', etc.

  // Performance metrics
  double? overallScore;
  double? technicalSkills;
  double? communicationSkills;
  double? teamwork;
  double? leadership;
  double? problemSolving;
  double? reliability;
  double? initiative;
  double? qualityOfWork;

  // Goals and objectives
  List<PerformanceGoal>? goals;
  String? strengths;
  String? areasForImprovement;
  String? developmentPlan;
  String? comments;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isActive;

  EmployeePerformanceEvaluation({
    this.evaluationId,
    this.employeeId,
    this.employeeName,
    this.evaluatorId,
    this.evaluatorName,
    this.department,
    this.position,
    this.evaluationDate,
    this.dueDate,
    this.status,
    this.period,
    this.overallScore,
    this.technicalSkills,
    this.communicationSkills,
    this.teamwork,
    this.leadership,
    this.problemSolving,
    this.reliability,
    this.initiative,
    this.qualityOfWork,
    this.goals,
    this.strengths,
    this.areasForImprovement,
    this.developmentPlan,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  // Factory constructor from JSON
  factory EmployeePerformanceEvaluation.fromJson(Map<String, dynamic> json) {
    return EmployeePerformanceEvaluation(
      evaluationId: json['evaluationId']?.toString(),
      employeeId: json['employeeId']?.toString(),
      employeeName: json['employeeName']?.toString(),
      evaluatorId: json['evaluatorId']?.toString(),
      evaluatorName: json['evaluatorName']?.toString(),
      department: json['department']?.toString(),
      position: json['position']?.toString(),
      evaluationDate: json['evaluationDate'] != null
          ? DateTime.tryParse(json['evaluationDate'].toString())
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      status: json['status']?.toString(),
      period: json['period']?.toString(),
      overallScore: json['overallScore']?.toDouble(),
      technicalSkills: json['technicalSkills']?.toDouble(),
      communicationSkills: json['communicationSkills']?.toDouble(),
      teamwork: json['teamwork']?.toDouble(),
      leadership: json['leadership']?.toDouble(),
      problemSolving: json['problemSolving']?.toDouble(),
      reliability: json['reliability']?.toDouble(),
      initiative: json['initiative']?.toDouble(),
      qualityOfWork: json['qualityOfWork']?.toDouble(),
      goals: json['goals'] != null
          ? (json['goals'] as List)
              .map((g) => PerformanceGoal.fromJson(g))
              .toList()
          : null,
      strengths: json['strengths']?.toString(),
      areasForImprovement: json['areasForImprovement']?.toString(),
      developmentPlan: json['developmentPlan']?.toString(),
      comments: json['comments']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      isActive: json['isActive'] as bool?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'evaluationId': evaluationId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'evaluatorId': evaluatorId,
      'evaluatorName': evaluatorName,
      'department': department,
      'position': position,
      'evaluationDate': evaluationDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'period': period,
      'overallScore': overallScore,
      'technicalSkills': technicalSkills,
      'communicationSkills': communicationSkills,
      'teamwork': teamwork,
      'leadership': leadership,
      'problemSolving': problemSolving,
      'reliability': reliability,
      'initiative': initiative,
      'qualityOfWork': qualityOfWork,
      'goals': goals?.map((g) => g.toJson()).toList(),
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'developmentPlan': developmentPlan,
      'comments': comments,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Calculate average score from individual metrics
  double calculateAverageScore() {
    final scores = [
      technicalSkills,
      communicationSkills,
      teamwork,
      leadership,
      problemSolving,
      reliability,
      initiative,
      qualityOfWork,
    ].where((score) => score != null).cast<double>().toList();

    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // Check if evaluation is overdue
  bool get isOverdue {
    if (dueDate == null || status == 'Completed') return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Get status with consideration for overdue
  String get effectiveStatus {
    if (isOverdue && status != 'Completed') {
      return 'Overdue';
    }
    return status ?? 'Unknown';
  }

  // Get performance rating based on score
  String getPerformanceRating() {
    final score = overallScore ?? calculateAverageScore();
    if (score >= 4.5) return 'Excellent';
    if (score >= 4.0) return 'Very Good';
    if (score >= 3.5) return 'Good';
    if (score >= 3.0) return 'Satisfactory';
    if (score >= 2.0) return 'Needs Improvement';
    return 'Unsatisfactory';
  }

  // Copy with method for updates
  EmployeePerformanceEvaluation copyWith({
    String? evaluationId,
    String? employeeId,
    String? employeeName,
    String? evaluatorId,
    String? evaluatorName,
    String? department,
    String? position,
    DateTime? evaluationDate,
    DateTime? dueDate,
    String? status,
    String? period,
    double? overallScore,
    double? technicalSkills,
    double? communicationSkills,
    double? teamwork,
    double? leadership,
    double? problemSolving,
    double? reliability,
    double? initiative,
    double? qualityOfWork,
    List<PerformanceGoal>? goals,
    String? strengths,
    String? areasForImprovement,
    String? developmentPlan,
    String? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return EmployeePerformanceEvaluation(
      evaluationId: evaluationId ?? this.evaluationId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      evaluatorId: evaluatorId ?? this.evaluatorId,
      evaluatorName: evaluatorName ?? this.evaluatorName,
      department: department ?? this.department,
      position: position ?? this.position,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      period: period ?? this.period,
      overallScore: overallScore ?? this.overallScore,
      technicalSkills: technicalSkills ?? this.technicalSkills,
      communicationSkills: communicationSkills ?? this.communicationSkills,
      teamwork: teamwork ?? this.teamwork,
      leadership: leadership ?? this.leadership,
      problemSolving: problemSolving ?? this.problemSolving,
      reliability: reliability ?? this.reliability,
      initiative: initiative ?? this.initiative,
      qualityOfWork: qualityOfWork ?? this.qualityOfWork,
      goals: goals ?? this.goals,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      developmentPlan: developmentPlan ?? this.developmentPlan,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class PerformanceGoal {
  String? goalId;
  String? title;
  String? description;
  String? status; // 'Not Started', 'In Progress', 'Completed', 'On Hold'
  DateTime? targetDate;
  DateTime? completedDate;
  double? progress; // 0.0 to 1.0
  String? category; // 'Technical', 'Professional', 'Personal Development'

  PerformanceGoal({
    this.goalId,
    this.title,
    this.description,
    this.status,
    this.targetDate,
    this.completedDate,
    this.progress,
    this.category,
  });

  factory PerformanceGoal.fromJson(Map<String, dynamic> json) {
    return PerformanceGoal(
      goalId: json['goalId']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'].toString())
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.tryParse(json['completedDate'].toString())
          : null,
      progress: json['progress']?.toDouble(),
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'title': title,
      'description': description,
      'status': status,
      'targetDate': targetDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'progress': progress,
      'category': category,
    };
  }

  bool get isCompleted => status == 'Completed';
  bool get isOverdue =>
      targetDate != null && DateTime.now().isAfter(targetDate!) && !isCompleted;
}
