class Permission {
  int? idPermission;
  String? module;
  String? group;
  String? form;
  String? description;
  bool? acces;

  Permission(this.idPermission, this.module, this.group, this.form,
      this.description, this.acces);

  Map<dynamic, dynamic> toJson() => {
        "idEvento": idPermission,
        "ClaModulo": module,
        "ClaGrupo": group,
        "ClaForma": form,
        "Descripcion": description,
        "Acceso": acces,
      };
}

dynamic permissionFromJSON(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else {
    var item = jsonList[0];
    String idPermission = item['idEvento'];
    String module = item['ClaModulo'];
    String group = item['ClaGrupo'];
    String form = item['ClaForma'];
    String description = item['Descripcion'];
    String acces = item['Acceso'];

    return Permission(
        idPermission as int?, module, group, form, description, acces as bool?);
  }
}
