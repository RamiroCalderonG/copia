import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:trina_grid/trina_grid.dart';

List<User> listOfUsersForGrid = [];
late List<TrinaRow> usersTrinaRowList;
late dynamic selectedUser;
int? tempUserId;
User? tempSelectedUsr;
List<TrinaRow> userRows = [];
List<dynamic> tmpRolesList = [];
List<Role> tmpRoleObjectslist = [];
List<dynamic> userRoles = [];
List<dynamic> tmpeventsList = [];
List<Map<String, dynamic>> eventsLisToShow = [];
List<String> campuseList = [];
List<String> areaList = [];

//var

void cleatTempData() async {
  listOfUsersForGrid.clear();
  usersTrinaRowList.clear();
  selectedUser = null;
  tempUserId = null;
  tempSelectedUsr?.clear();
  // userRows.clear();
  tmpRolesList.clear();
  userRoles.clear();
  tmpeventsList.clear();
  eventsLisToShow.clear();
  campuseList.clear();
}
