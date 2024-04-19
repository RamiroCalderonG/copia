import 'package:oxschool/Models/User.dart';
import 'package:pluto_grid/pluto_grid.dart';

dynamic listOfUsersForGrid;
late List<PlutoRow> usersPlutoRowList;
late dynamic selectedUser;
int? tempUserId;
User? tempSelectedUsr;
List<PlutoRow> userRows = [];
List<dynamic> tmpRolesList = [];
List<dynamic> userRoles = [];
List<dynamic> tmpeventsList = [];
List<Map<String, dynamic>> eventsLisToShow = [];
List<String> campuseList = [];
List<String> areaList = [];

//var

void cleatTempData() async {
  listOfUsersForGrid = null;
  usersPlutoRowList.clear();
  selectedUser = null;
  tempUserId = null;
  tempSelectedUsr?.clear();
  userRows.clear();
  tmpRolesList.clear();
  userRoles.clear();
  tmpeventsList.clear();
  eventsLisToShow.clear();
  campuseList.clear();
}
