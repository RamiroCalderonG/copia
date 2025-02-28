// ignore_for_file: file_names

import 'package:oxschool/data/DataTransferObjects/RoleModuleRelationshipDto.Dart';
import 'package:oxschool/data/Models/Event.dart';

class Role {
  int roleID;
  String roleName;
  String roleDescription;
  bool isActive;
  List<Event>? events;
  List<RoleModuleRelationshipDto>?
      roleModuleRelationships; //Used to get relationship between role and modules
  List<Map<String, dynamic>>? moduleScreenList;
  List<Map<String, dynamic>>? screenEventList;


  Role(
      {required this.roleID,
      required this.roleName,
      required this.roleDescription,
      required this.isActive,
      this.events,
      this.roleModuleRelationships, this.moduleScreenList, this.screenEventList});

  Role.fromJson(Map<String, dynamic> json)
      : roleID = json["id"],
        roleName = json["softName"],
        roleDescription = json["description"],
        isActive = json["isActive"],
        events = [],
        roleModuleRelationships = [];

  // Map<String, dynamic> toJSON() => {
  //       'role_id': roleID,
  //       'role_name': roleName,
  //       "is_active": isActive,
  //       "role_description": roleDescription,
  //     };
}
