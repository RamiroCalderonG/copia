class RoleModuleRelationshipDto{
  int? roleId;
  int? moduleId;
  String? moduleName;
  bool? canAccessModule;
  int? screenId;
  int? screenName;
  bool? canAccessScreen;
  int? eventId;
  String? eventName;
  bool? canAccessEvent;

  RoleModuleRelationshipDto({this.roleId, this.moduleId, this.moduleName,
  this.canAccessModule, this.screenId, this.screenName, this.canAccessScreen
  , this.eventId, this.eventName, this.canAccessEvent});

  RoleModuleRelationshipDto.fromJSON(Map<String, dynamic> json)
  : role_id = json['role'],
  module_id = json['module'],
  module_name = json['module_name'],
  can_access_module = json['can_role_access_module'],
  screen_id = json['screen'],
  screen_name = json['screen_name'],
  can_access_screen = json['can_role_access_screen'],
  event_id = json['event'],
  event_name = json['event_name'],
  can_access_event = json['can_role_access_event'];
}