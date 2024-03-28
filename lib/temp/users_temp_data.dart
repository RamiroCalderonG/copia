import 'package:oxschool/Models/User.dart';
import 'package:pluto_grid/pluto_grid.dart';

dynamic listOfUsersForGrid;
late List<PlutoRow> usersPlutoRowList;
late dynamic selectedUser;
String? tempUserId;
User? tempSelectedUsr;
List<PlutoRow> userRows = [];
List<dynamic> tmpRolesList = [];
//var