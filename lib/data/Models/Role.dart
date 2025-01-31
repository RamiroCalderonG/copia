// ignore_for_file: file_names

import 'package:oxschool/data/Models/Event.dart';

class Role {
  int roleID;
  String roleName;
  String roleDescription;
  bool isActive;
  List<Event>? events;

  Role(
      {required this.roleID,
      required this.roleName,
      required this.roleDescription,
      required this.isActive,
      this.events});

  Role.fromJson(Map<String, dynamic> json)
      : roleID = json["id"],
        roleName = json["softName"],
        roleDescription = json["description"],
        isActive = json["isActive"],
        events = [];

  // Map<String, dynamic> toJSON() => {
  //       'role_id': roleID,
  //       'role_name': roleName,
  //       "is_active": isActive,
  //       "role_description": roleDescription,
  //     };
}
