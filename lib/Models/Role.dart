class Role {
  int roleID;
  String roleName;
  String roleDescription;
  bool isActive;

  Role(this.roleID, this.roleName, this.roleDescription, this.isActive);

  Map<String, dynamic> toJSON() => {
        'role_id': roleID,
        'role_name': roleName,
        "is_active": isActive,
        "role_description": roleDescription,
      };
}
