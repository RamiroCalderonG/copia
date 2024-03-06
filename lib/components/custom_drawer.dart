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

Widget createDrawer(BuildContext context, Future<http.Response> userEvents) {
  final _controller = ScrollController();

  return Drawer(
    child: SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(currentUser!.employeeName!),
            accountEmail: Text(currentUser!.employeeNumber!.toString()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(currentUser!.employeeName![0]),
            ),
          ),
          new FutureBuilder(
              future: userEvents,
              builder: (BuildContext context,
                  AsyncSnapshot<http.Response> response) {
                if (!response.hasData) {
                  return const Center(
                    child: const Text('Loading...'),
                  );
                } else if (response.data!.statusCode != 200) {
                  return const Center(
                    child: const Text('Error Loading'),
                  );
                } else {
                  List<dynamic> json = jsonDecode(response.data!.body);
                  return Placeholder();
                }
              })
        ],
      ),
    ),
  );
}
