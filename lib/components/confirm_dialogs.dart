// Function to show an alert dialog for empty field
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

void showEmptyFieldAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Campo vacio'),
        content: const Text('Por favor ingrese un valor que sea válido.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void showErrorFromBackend(BuildContext context, String errorMessage) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            )
          ],
        );
      });
}

Future<int> showDeleteConfirmationAlertDialog(BuildContext context) async {
  Completer<int> completer = Completer<int>();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Eliminar",
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: const Text("¿Está seguro de eliminar este elemento?",
              style: TextStyle(fontFamily: 'Sora')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(0); // User selected 'No'
              },
              child: Text(
                'No',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Roboto',
                      color: Color(0xFF130C0D),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(1); // User selected 'Yes'
              },
              child: Text('Si',
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        fontFamily: 'Roboto',
                        color: Color(0xFF130C0D),
                        fontWeight: FontWeight.w500,
                      )),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.greenAccent),
              ),
            ),
          ],
        );
      });
  return completer.future;
}
