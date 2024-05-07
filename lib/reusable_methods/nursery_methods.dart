//GET LIST OF CAUSES
// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:oxschool/backend/api_requests/api_calls.dart';
import 'package:oxschool/constants/User.dart';

Future<List<String>> getPainList(String logger) async {
  List<dynamic> jsonList;
  List<String> resultPainList = [];

  var apiResultxgr = await NurseryPainListCall.call(dataLog: logger)
      .timeout(const Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    jsonList = json.decode(apiResultxgr.response!.body);

    // Extract 'painList' values into a List<String>
    resultPainList =
        List<String>.from(jsonList.map((json) => json['NomCausa']));

    return resultPainList;
  } else {
    if (kDebugMode) {
      print("Error en llamada a dolores");
    }
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch");
  }
}

Future<List<String>> getWoundsList(String logger) async {
  List<dynamic> jsonList;
  List<String> resultWoundsList = [];

  var apiResultxgr = await NurseryWoundsCall.call(dataLog: logger)
      .timeout(const Duration(seconds: 15));

  if (apiResultxgr.succeeded) {
    // Parse the JSON response
    jsonList = json.decode(apiResultxgr.response!.body);

    // Extract 'painList' values into a List<String>
    resultWoundsList =
        List<String>.from(jsonList.map((json) => json['NomCausa']));

    return resultWoundsList;
  } else {
    if (kDebugMode) {
      print("Error en llamada a dolores");
    }
    // Throw an exception or return an empty list based on your error handling strategy
    throw Exception("Failed to fetch");
  }
}

Future<String> postNurseryStudent(
    int employeeID,
    String? kindOfPain,
    String kindOfWound,
    String otherCauses,
    String studentId,
// String studentName,
    String reasonForVisit,
    String valoration,
    String treatment,
    String kindOfAccident,
    String? responsableTeacher,
    String? observations,
    bool sentToClinic,
    bool sentToDoctor,
    bool phoneNotif,
    bool personalNotif,
    bool reportNotif,
    DateTime dateAndTime,
    int notifType,
    String deviceInformation,
    String responsableTeacherID) async {
  var responseID;

  //Parse params to manage as JSON
  var body = nurseryToJSON(
      employeeID,
      kindOfPain,
      kindOfWound,
      otherCauses,
      studentId,
      currentCycle!.claCiclo.toString(),
      reasonForVisit,
      valoration,
      treatment,
      kindOfAccident,
      responsableTeacher,
      observations,
      sentToClinic,
      sentToDoctor,
      phoneNotif,
      personalNotif,
      reportNotif,
      dateAndTime,
      notifType,
      deviceInformation,
      responsableTeacherID);

  try {
    var apiResultxgr = await POSTNurseryStudentVisit.call(requiredBody: body)
        .timeout(const Duration(seconds: 15));

    if (apiResultxgr.succeeded) {
      // Parse the JSON response ID from DB
      responseID = json.decode(apiResultxgr.response!.body);
    }
    return responseID;
  } catch (e) {
    if (kDebugMode) {
      print("Error in API Call$e");
    }
    throw Exception(e.toString());
  }
}

Map<String, dynamic> nurseryToJSON(
    int employeeID,
    String? kindOfPain,
    String kindOfWound,
    String otherCauses,
    String studentId,
    String currentCycle,
// String studentName,
    String reasonForVisit,
    String valoration,
    String treatment,
    String kindOfAccident,
    String? responsableTeacher,
    String? observations,
    bool sentToClinic,
    bool sentToDoctor,
    bool phoneNotif,
    bool personalNotif,
    bool reportNotif,
    DateTime dateAndTime,
    int notifType,
    String deviceInformation,
    String responsableTeacherID) {
  return {
    'NoEmpleado': employeeID,
    'TipoDolor': kindOfPain,
    'TipoHerida': kindOfWound,
    'OtraCausa': otherCauses,
    'Matricula': studentId,
    'ClaCiclo': currentCycle,
    'MotivoVisita': reasonForVisit,
    'Valoracion': valoration,
    'Tratamiento': treatment,
    'TipoAccidente': kindOfAccident,
    'Responsable': responsableTeacher,
    'Observaciones': observations,
    'Clinica': sentToClinic.toString(),
    'Doctor': sentToDoctor.toString(),
    'Telefono': phoneNotif.toString(),
    'Personal': personalNotif.toString(),
    'Reporte': reportNotif.toString(),
    'Fecha': dateAndTime.toString(),
    'TipoNotificacion': notifType.toString(),
    'Computadora': deviceInformation.toString(),
    'MtroResponsableID': responsableTeacherID
  };
}
