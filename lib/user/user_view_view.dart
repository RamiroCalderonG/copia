import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

class UserWindow extends StatefulWidget {
  const UserWindow({super.key});

  @override
  State<UserWindow> createState() => _UserWindowState();
}

class _UserWindowState extends State<UserWindow> {
  late Future<User> userFuture; // Future to hold the user data

  @override
  void initState() {
    super.initState();
    //userFuture = _fetchUser(); // Fetch user data on initialization
  }

  // // Simulating user data fetching
  // Future<User> _fetchUser() async {
  //   // Replace this with your actual implementation
  //   await Future.delayed(const Duration(seconds: 2));
  //   return User(
  //     currentUser?.claLogin,
  //     currentUser?.claUn,
  //     currentUser?.employeeName,
  //     currentUser?.employeeNumber,
  //     currentUser?.idLogin,
  //     currentUser?.isWorker,
  //     currentUser?.isTeacher
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Placeholder());
    // return FutureBuilder<User>(
    //   future: userFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final user = snapshot.data!;
    //       return Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             CircleAvatar(
    //               radius: 50,
    //               backgroundImage:
    //                   NetworkImage('https://oxschool.edu.mx/index.aspx'),
    //             ),
    //             Text(
    //               '${currentUser?.employeeName}',
    //               style: Theme.of(context).textTheme.headline6,
    //             ),
    //             Text('${currentUser?.idLogin}'),
    //           ],
    //         ),
    //       );
    //     } else if (snapshot.hasError) {
    //       return Text('Error fetching user data: ${snapshot.error}');
    //     } else {
    //       return const CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}
