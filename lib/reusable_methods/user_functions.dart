import '../Models/User.dart';

List<User> parseUsersFromJSON(List<dynamic> jsonList) {
  List<User> users = [];

  for (var item in jsonList) {
    int employeeNumber = item['noempleado'];
    String employeeName = item['nombre_gafete'];
    String claUn = item['claun'];
    String role = item['role_name'];
    int userId = item['id'];
    String token = 'null';
    String schoolEmail = item['user_email'];
    String usergenre = item['genre'];
    int isActive = item['bajalogicasino'];

    User currentUser = User(claUn, employeeName, employeeNumber, role, userId,
        token, schoolEmail, usergenre, isActive);

    users.add(currentUser);
  }

  // for (var i = 0; i < jsonList.length; i++) {
  //   int employeeNumber = jsonList[i]['NoEmpleado'];
  //   String employeeName = jsonList[i]['Nombre_Gafete'];
  //   String claUn = jsonList[i]['ClaUn'];
  //   String role = jsonList[i]['RoleName'];
  //   int userId = jsonList[i]['id'];
  //   String token = jsonList[i]['token'];
  //   String schoolEmail = jsonList[i]['user_email'];
  //   String usergenre = jsonList[i]['genre'];
  //   int isActive = jsonList[i]['bajalogicasino'];

  //   User currentUser = User(claUn, employeeName, employeeNumber, role, userId,
  //       token, schoolEmail, usergenre, isActive);

  //   users.add(currentUser);
  // }

  return users;
}

bool isUserAdminFunction(User currentUser) {
  if (currentUser.role == "Administrator") {
    return true;
  } else {
    return false;
  }
}
