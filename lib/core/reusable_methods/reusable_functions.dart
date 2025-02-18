import 'dart:convert';

import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';

Future<dynamic> getAllCampuse() async {
  await getCampuseList().then((response){
    var campusList = jsonDecode(response);
     for (var item in campusList) {
    String name = item['Name'];
    campuseList.add(name); //.add(name);
  }
  }).onError((error, stackTrace){ 
    insertErrorLog(error.toString(), 'getAllCampuse() | ');
    return Future.error(error.toString());
  });
}

Future<dynamic> getWorkDepartmentList() async {
  try {
    areaList.clear();
    await getWorkDepartments().then((response) {
      var jsonList = jsonDecode(response);
      for (var item in jsonList) {
        areaList.add(item['bureauName'].toString().trim().toTitleCase);
      }
    }).catchError((onError) {
      insertErrorLog(onError.toString(), 'getWorkDepartmentList()');
      throw Future.error(onError);
    });
  } catch (e) {
    insertErrorLog(e.toString(), 'getWorkDepartmentList()');
    return Future.error(e.toString());
  }
}

int? getKeyFromValue(Map<int, String> map, String value) {
  return map.entries
      .firstWhere((entry) => entry.value == value,
          orElse: () => const MapEntry(-1, ''))
      .key;
}

dynamic getValueFromKey(Map<int, String> map, dynamic key) {
  return map.entries
      .firstWhere((element) => element.key == key,
          orElse: () => const MapEntry(-1, ''))
      .value;
}

dynamic searchValueByKey(List<Map<String, dynamic>> list, String key, keytitle,
    dynamic searchValue) {
  for (final map in list) {
    if (map.containsKey(key.trimRight())) {
      final value = map[keytitle];
      if (map[key] == searchValue) {
        return value;
      }
    }
  }
  return null; // Value not found
}

//
// List<String> splitAndAddToList(String input) {
//   final List<String> result = [];
//   final List<String> words = input.replaceAll(RegExp(r'[\[\]]'), '').split(',');

//   for (final word in words) {
//     final trimmedWord = word.trim();
//     if (trimmedWord.isNotEmpty) {
//       result.add(trimmedWord);
//     }
//   }

//   return result;
// }
