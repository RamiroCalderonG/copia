class Role {
  int roleID;
  String roleName;
  String roleDescription;
  bool isActive;
  List<Map<String, dynamic>>? events;

  Role(this.roleID, this.roleName, this.roleDescription, this.isActive,
      this.events);

  Map<String, dynamic> toJSON() => {
        'role_id': roleID,
        'role_name': roleName,
        "is_active": isActive,
        "role_description": roleDescription,
      };
}
