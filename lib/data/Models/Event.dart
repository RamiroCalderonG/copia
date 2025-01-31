// ignore_for_file: file_names

class Event {
  int eventID;
  String eventName;
  bool isActive;
  String moduleName;
  int roleID;

  Event(this.eventID, this.eventName, this.isActive, this.moduleName,
      this.roleID);

  Map<String, dynamic> toJSON() => {
        'event_ID': eventID,
        'event_name': eventName,
        "is_active": isActive,
        "module_name": moduleName,
        "role_event_active": roleID
      };
}
