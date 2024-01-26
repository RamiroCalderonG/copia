class User {
  int? employeeNumber;
  String? employeeName;
  int? idLogin;
  int? isTeacher;
  int? isWorker;
  String? claUn;
  String? claLogin;
  String token;
  // late final notActive;

  User(this.claLogin, this.claUn, this.employeeName, this.employeeNumber,
      this.idLogin, this.isWorker, this.isTeacher, this.token);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "idLogin": idLogin,
        "isTeacher": isTeacher,
        "isWorker": isWorker,
        "claUn": claUn,
        "claLogin": claLogin,
        "token": token
        // "notActive": notActive
      };

  void clear() {
    employeeName = null;
    employeeNumber = null;
    idLogin = null;
    isTeacher = null;
    isWorker = null;
    claUn = null;
    claLogin = null;
  }
}
