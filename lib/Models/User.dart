class User {
  late final int employeeNumber;
  late final String employeeName;
  late int idLogin;
  late final isTeacher;
  late final int isWorker;
  late String claUn;
  late String claLogin;
  // late final notActive;

  User(this.claLogin, this.claUn, this.employeeName, this.employeeNumber,
      this.idLogin, this.isWorker, this.isTeacher);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "idLogin": idLogin,
        "isTeacher": isTeacher,
        "isWorker": isWorker,
        "claUn": claUn,
        "claLogin": claLogin
        // "notActive": notActive
      };
}
