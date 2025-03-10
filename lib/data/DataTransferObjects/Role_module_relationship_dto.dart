class RoleModuleRelationshipDto {
  int? roleId;
  int? moduleId;
  String? moduleName;
  bool? canAccessModule;
  int? screenId;
  String? screenName;
  bool? canAccessScreen;
  int? eventId;
  String? eventName;
  bool? canAccessEvent;

  RoleModuleRelationshipDto(this.roleId, this.moduleId, this.moduleName,
  this.canAccessModule, this.screenId, this.screenName, this.canAccessScreen, 
  this.eventId, this.eventName, this.canAccessEvent);

  RoleModuleRelationshipDto.fromJSON(Map<String, dynamic> json)
  : roleId = json['role'],
  moduleId = json['module'],
  moduleName = json['module_name'],
  canAccessModule = json['can_role_access_module'],
  screenId = json['screen'],
  screenName = json['screen_name'],
  canAccessScreen = json['can_role_access_screen'],
  eventId = json['event'],
  eventName = json['event_name'],
  canAccessEvent = json['can_role_access_event'];
}