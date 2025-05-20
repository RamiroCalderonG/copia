/*
VALIDATES USER PERMISSIONS FROM BACKEND
 */


import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';

bool? canRoleConsumeEvent(String eventName) {
  try {
    for (var element in currentUser!.userRole!.roleModuleRelationships! ){
      if (element.eventName == eventName) {
        return element.canAccessEvent;
      } 
    }
  } catch (e) {
    insertErrorLog(e.toString(), 'canRoleConsumeEvent $eventName');
  }
}