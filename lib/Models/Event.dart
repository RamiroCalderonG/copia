class Event {
  int eventID;
  String eventName;
  bool isActive;
  String moduleName;
  int moduleID;

  Event(this.eventID, this.eventName, this.isActive, this.moduleName,
      this.moduleID);

  Map<String, dynamic> toJSON() => {
        'event_ID': eventID,
        'event_name': eventName,
        "is_active": isActive,
        "module_name": moduleName,
        "module_id": moduleID
      };
}
