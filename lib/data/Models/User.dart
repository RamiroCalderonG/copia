// ignore_for_file: file_names, non_constant_identifier_names

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
  String? work_area;
  String? work_position;
  String? creationDate;
  String? birthdate;
  bool? isTeacher;

  // late final notActive;

  User(
      this.claUn,
      this.employeeName,
      this.employeeNumber,
      this.role,
      this.userId,
      this.token,
      this.userEmail,
      this.usergenre,
      this.isActive,
      this.work_area,
      this.work_position,
      this.creationDate,
      this.birthdate,
      this.isTeacher);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "claUn": claUn,
        "token": token,
        "id": userId,
        "role": role,
        'useremail': userEmail,
        'genre': usergenre,
        "bajalogicasino": isActive,
        "department": work_area,
        "position": work_position,
        "creationDate": creationDate.toString(),
        "birthdate": birthdate,
        "is_Teacher": isTeacher

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
      work_area = jsonUser[item]['work_area'];
      work_position = jsonUser[item]['work_position'];
      creationDate = jsonUser[item]['creation_date'];
      birthdate = jsonUser[item]['birthdate'];
      isTeacher = jsonUser[item]['is_Teacher'];
    }
    return User(
        claUn,
        employeeName,
        employeeNumber,
        role,
        userId,
        token,
        userEmail,
        usergenre,
        isActive,
        work_area,
        work_position,
        creationDate,
        birthdate,
        isTeacher);
  }

  void clear() {
    employeeName = null;
    employeeNumber = null;
    claUn = null;
    token = "";
  }
}
