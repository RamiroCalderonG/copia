import 'package:flutter/material.dart';
import 'package:oxschool/temp/users_temp_data.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Text(selectedUser),
    );
  }
}
