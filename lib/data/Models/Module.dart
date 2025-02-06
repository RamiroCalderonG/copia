import 'package:flutter/material.dart';
import 'package:oxschool/data/Models/Event.dart';

class Module {
  int id;
  String name;
  String description;
  List<Event>? eventsList;
  bool isModuleActive;

  Module(
      {required this.id,
      required this.name,
      this.eventsList,
      required this.isModuleActive,
      this.description = ''});

  Module.fromJson(Map<String, dynamic> json)
      : id = json['number'],
        name = json['name'],
        description = json['description'],
        eventsList = json['eventsList'] ? null : null,
        isModuleActive = json['active'];

  Module.fromJsonWithoutEvents(Map<String, dynamic> json)
      : id = json['number'],
        name = json['name'],
        description = json['description'],
        eventsList = [],
        isModuleActive = json['active'];
}
