class User {
  int? employeeNumber;
  String? employeeName;
  String? claUn;
  String role;
  int userId;
  String token;
  String? userEmail;
  String? usergenre;
  int? isActive;

  // late final notActive;

  User(this.claUn, this.employeeName, this.employeeNumber, this.role,
      this.userId, this.token, this.userEmail, this.usergenre, this.isActive);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "claUn": claUn,
        "token": token,
        "id": userId,
        "role": role,
        'useremail': userEmail,
        'genre': usergenre,
        "bajalogicasino": isActive

        // "notActive": notActive
      };

  void clear() {
    employeeName = null;
    employeeNumber = null;

    claUn = null;

    token = "";
  }
}
