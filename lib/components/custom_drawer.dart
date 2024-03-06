import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:http/http.dart' as http;

// Widget customDrawer() {
//   return Drawer(
//     child: ListView(
//       padding: EdgeInsets.zero,
//       children: currentUser!.events.map((group) {
//         return ExpansionTile(
//           title: Text(group),
//           children: currentUser!.events[group]!.map((item) {
//             return ListTile(
//               title: Text(item),
//               onTap: () {
//                 //None
//               },
//             );
//           }).toList(),
//         );
//       }).toList(),
//     ),
//   );
// }


