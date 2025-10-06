import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

class AcademicAwards extends StatefulWidget {
  const AcademicAwards({super.key});

  @override
  State<AcademicAwards> createState() => _AcademicAwardsState();
}

class _AcademicAwardsState extends State<AcademicAwards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reconocimientos académicos'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Center(
            child: const Placeholder(
          child: Text('Reconocimientos académicos'),
        )));
  }
}
