class User {
  int? employeeNumber;
  String? employeeName;
  String? claUn;
  String role;
  int userId;
  String token;

  // late final notActive;

  User(this.claUn, this.employeeName, this.employeeNumber, this.role,
      this.userId, this.token);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "claUn": claUn,
        "token": token,
        "id": userId,
        "role": role,

        // "notActive": notActive
      };

  void clear() {
    employeeName = null;
    employeeNumber = null;

    claUn = null;

    token = "";
  }
}
