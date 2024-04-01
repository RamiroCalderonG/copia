import 'package:flutter/material.dart';

class UserEventsManager extends StatefulWidget {
  const UserEventsManager({super.key});

  @override
  State<UserEventsManager> createState() => UserEventsManagerState();
}

class UserEventsManagerState extends State<UserEventsManager> {
  final overviewMessage = Container(
    child: Text('Mensaje general'),
  );

  Widget eventsList(String role, String desc, int index) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 600) {
        return Placeholder();
      } else {
        return Column(children: [Placeholder()]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
