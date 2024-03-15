import '../Models/User.dart';

List<User> parseUsersFromJSON(List<dynamic> jsonList) {
  List<User> users = [];

  for (var i = 0; i < jsonList.length; i++) {
    int employeeNumber = jsonList[i]['NoEmpleado'];
    String employeeName = jsonList[i]['Nombre_Gafete'];
    String claUn = jsonList[i]['ClaUn'];
    String role = jsonList[i]['RoleName'];
    int userId = jsonList[i]['id'];
    String token = jsonList[i]['token'];
    String schoolEmail = jsonList[i]['user_email'];
    String usergenre = jsonList[i]['genre'];
    int isActive = jsonList[i]['bajalogicasino'];

    User currentUser = User(claUn, employeeName, employeeNumber, role, userId,
        token, schoolEmail, usergenre, isActive);

    users.add(currentUser);
  }

  return users;
}
