class RoleModuleRelationshipDto{
  int screenRoleId;
  int moduleId;
  bool canRoleAccessModule;
  int roleId;
  String moduleName;

  RoleModuleRelationshipDto(this.screenRoleId, this.moduleId, 
    this.canRoleAccessModule, this.roleId, this.moduleName);

  RoleModuleRelationshipDto.fromJSON(Map<String, dynamic> json)
  : screenRoleId = json['screen_role'],
    moduleId = json['module'],
    canRoleAccessModule = json['can_role_access_module'],
    roleId = json['role'],
    moduleName = json['module_name'];

}