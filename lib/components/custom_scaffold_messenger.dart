import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

dynamic customScaffoldMesg(
    BuildContext context, String message, bool? isError) {
  return SnackBar(
    content: Text(
      message,
      style: FlutterFlowTheme.of(context).labelMedium.override(
            fontFamily: 'Roboto',
            color: const Color(0xFF130C0D),
            fontWeight: FontWeight.w500,
          ),
    ),
    action: SnackBarAction(
        label: 'Cerrar mensaje',
        textColor: FlutterFlowTheme.of(context).info,
        backgroundColor: Colors.black12,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }),
    duration: const Duration(milliseconds: 9000),
    backgroundColor: FlutterFlowTheme.of(context).secondary,
  );
}
