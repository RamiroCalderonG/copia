import 'package:flutter/material.dart';

import '../flutter_flow/flutter_flow_theme.dart';

class GradesViewScreen extends StatefulWidget {
  const GradesViewScreen({super.key});

  @override
  State<GradesViewScreen> createState() => _GradesViewScreenState();
}

class _GradesViewScreenState extends State<GradesViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calificaciones',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
  }
}
