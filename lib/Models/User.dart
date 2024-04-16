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
  User fromJson(List<dynamic> jsonUser) {
    for (var item in jsonUser) {
      claUn = jsonUser[item]['claun'];
      employeeName = jsonUser[item]['nombre_gafete'];
      employeeNumber = jsonUser[item]['noempleado'];
      role = jsonUser[item]['role_name'];
      userId = jsonUser[item]['role_name'];
      token = '';
      userEmail = jsonUser[item]['user_email'];
      usergenre = jsonUser[item]['genre'];
      isActive = jsonUser[item]['bajalogicasino'];
    }
    return User(claUn, employeeName, employeeNumber, role, userId, token,
        userEmail, usergenre, isActive);
  }

  void clear() {
    employeeName = null;
    employeeNumber = null;

    claUn = null;

    token = "";
  }
}
