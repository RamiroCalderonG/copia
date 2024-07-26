// Function to show an alert dialog for empty field
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

void showEmptyFieldAlertDialog(BuildContext context, String contentText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Campo vacio'),
        content: Text(contentText
            // 'Por favor ingrese un valor que sea válido.'
            ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<int> showConfirmationDialog(
    BuildContext context, String contentText) async {
  Completer<int> completer = Completer<int>();
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(Icons.task_alt),
        title: const Text('Cambios realizados!',
            style: TextStyle(fontFamily: 'Sora')),
        content: Text(contentText
            // 'Por favor ingrese un valor que sea válido.'
            ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              completer.complete(1); // User selected 'Yes'
            },
            // style: ButtonStyle(
            //   backgroundColor:
            //       MaterialStateProperty.all<Color>(Colors.greenAccent),
            // ),
            child: Text('Cerrar',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Roboto',
                      color: const Color(0xFF130C0D),
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      );
    },
  );
  return completer.future;
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
              child: const Text('Ok'),
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
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
              child: Text(
                'No',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      fontFamily: 'Roboto',
                      color: const Color(0xFF130C0D),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(1); // User selected 'Yes'
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.greenAccent),
              ),
              child: Text('Si',
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                        fontFamily: 'Roboto',
                        color: const Color(0xFF130C0D),
                        fontWeight: FontWeight.w500,
                      )),
            ),
          ],
        );
      });
  return completer.future;
}
