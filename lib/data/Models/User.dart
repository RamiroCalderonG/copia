// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Role.dart';

class User {
  int? employeeNumber;
  String? employeeName;
  String? claUn;
  String role;
  int userId;
  String token;
  String? userEmail;
  //String? usergenre;
  int? isActive;
  String? work_area;
  String? work_position;
  String? creationDate;
  String? birthdate;
  bool? isTeacher;
  bool? isAdmin;
  int? roleID;
  bool? canUpdatePassword;
  bool? isAcademicCoord;
  Role? userRole;
  int? idLogin;
  Uint8List? userPicture;

  // late final notActive;

  User(
      this.claUn,
      this.employeeName,
      this.employeeNumber,
      this.role,
      this.userId,
      this.token,
      this.userEmail,
      //this.usergenre,
      this.isActive,
      this.work_area,
      this.work_position,
      this.creationDate,
      this.birthdate,
      this.isTeacher,
      this.isAdmin,
      this.roleID,
      this.canUpdatePassword,
      this.isAcademicCoord,
      this.userRole,
      this.idLogin,
      this.userPicture);

  Map<dynamic, dynamic> toJson() => {
        "employeeNumber": employeeNumber,
        "employeeName": employeeName,
        "claUn": claUn,
        "token": token,
        "id": userId,
        "role": role,
        'useremail': userEmail,
        //'genre': usergenre,
        "bajalogicasino": isActive,
        "department": work_area,
        "position": work_position,
        "creationDate": creationDate.toString(),
        "birthdate": birthdate,
        "is_Teacher": isTeacher,
        "isAdmin": isAdmin,
        "roleID": roleID,
        // "notActive": notActive
      };

  User.fromJson(Map<String, dynamic> json)
      : employeeNumber = json['employeeNumber'],
        employeeName = json['userFullName'],
        claUn = json['userCampus'],
        role = json['userRole']['softName'],
        userId = json['id'],
        token = '',
        userEmail = json['userMail'],
        isActive = json['userActive'],
        work_area = json['userDept'],
        work_position = json['userPosition'],
        creationDate = json['creation_date'],
        birthdate = json['userBirth'],
        isTeacher = json['userTeacher'],
        isAdmin = json['userRole']['isAdmin'],
        roleID = json['userRole']['id'],
        canUpdatePassword = json['userCanUpdatePassword'],
        isAcademicCoord = json['userRole']['isAcademicCoordinator'],
        idLogin = json['idLogin'],
        userPicture = base64Decode(json['userPicture']);

  void clear() {
    employeeName = null;
    employeeNumber = null;
    claUn = null;
    token = "";
    isAdmin = null;
  }

  bool isUserTeacher() {
    return isTeacher!;
  }

  bool isCurrentUserAdmin() {
    return isAdmin!;
  }

  bool isCurrentUserAcademicCoord() {
    return isAcademicCoord!;
  }

  bool hasAccesToEventById(int eventId) {
    try {
      if (userRole != null && userRole!.roleModuleRelationships != null) {
        // Use where() to find matching events, then check if any exist
        var matchingEvents = userRole!.roleModuleRelationships!
            .where((event) => event.eventId == eventId);

        if (matchingEvents.isNotEmpty) {
          var eventSelected = matchingEvents.first;
          return eventSelected.canAccessEvent ?? false;
        } else {
          // Event not found in user's permissions
          insertAlertLog(
              'Event not found in user\'s permissions for eventId $eventId , ${currentUser!.employeeName} | ${currentUser!.userEmail} | ');
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      insertErrorLog('Error in hasAccesToEventById for eventId $eventId: $e',
          'hasAccesToEventById');
      // Log the error for debugging
      // print('Error in hasAccesToEventById for eventId $eventId: $e');
      return false;
    }
  }

  bool hasAccesToEventByName(String eventName) {
    try {
      if (userRole != null && userRole!.roleModuleRelationships != null) {
        // Use where() to find matching events, then check if any exist
        var matchingEvents = userRole!.roleModuleRelationships!.where(
          (event) => event.eventName.toString().trim() == eventName.trim(),
        );

        if (matchingEvents.isNotEmpty) {
          var eventSelected = matchingEvents.first;
          return eventSelected.canAccessEvent ?? false;
        } else {
          // Event not found in user's permissions
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      // Log the error for debugging
      print('Error in hasAccesToEventByName for eventName "$eventName": $e');
      return false;
    }
  }

  /*
  *Function used for getting all users from backend and display it
  *uses less fiields because needs to be simplified.
  */
  User.usersSimplifiedList(Map<String, dynamic> json)
      : claUn = json['campus'].toString().toTitleCase,
        employeeName = json['name'],
        employeeNumber = json['employeeNumber'],
        role = json['roleName'].toString().toTitleCase,
        userId = json['id'],
        token = '',
        userEmail = json['email'],
        isActive = json['isActive'],
        work_area = json['department'].toString().toTitleCase,
        work_position = json['position'].toString().toTitleCase,
        creationDate = json['creationDate'],
        birthdate = json['birthdate'],
        isTeacher = json['isTeacher'],
        isAdmin = json['admin'] ?? false,
        roleID = 0,
        canUpdatePassword = json['can_update_password'],
        idLogin = json['idLogin'];
}
