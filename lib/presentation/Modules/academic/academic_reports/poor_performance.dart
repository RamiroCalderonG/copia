import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

class PoorPerformance extends StatefulWidget {
  const PoorPerformance({super.key});

  @override
  State<PoorPerformance> createState() => _PoorPerformanceState();
}

class _PoorPerformanceState extends State<PoorPerformance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bajo rendimiento'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Center(
            child: const Placeholder(
          child: Text('Bajo rendimiento'),
        )));
  }
}
