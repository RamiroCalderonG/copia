// Function to show an alert dialog for empty field
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';

void showEmptyFieldAlertDialog(BuildContext context, String contentText) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.warning_rounded,
            color: colorScheme.onErrorContainer,
            size: 24,
          ),
        ),
        title: Text(
          'Campo vacío',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          contentText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<int> showConfirmationDialog(
    //TO GET A CONFIRMATION FROM THE USER
    BuildContext context,
    String titleText,
    String contentText) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  Completer<int> completer = Completer<int>();
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: colorScheme.onSecondaryContainer,
            size: 24,
          ),
        ),
        title: Text(
          titleText,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          contentText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              completer.complete(0); // User selected 'No'
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              completer.complete(1); // User selected 'Yes'
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
  return completer.future;
}

Future<int> showSuccessWithConfirmationDialog(
    //Display a confirmation dialog that will wait for the user to click ok to close and continue with the app
    BuildContext context,
    String titleText,
    String contentText) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  Completer<int> completer = Completer<int>();
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        title: Text(
          titleText,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          contentText,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              completer.complete(1); // User selected 'Yes'
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
  return completer.future;
}

//To display error from backend
void showErrorFromBackend(BuildContext context, String errorMessage) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 24,
          ),
        ),
        title: Text(
          'Error',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          errorMessage,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}

void showSuccessDialog(
    BuildContext context, String header, String bodyMessage) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          title: Text(
            header,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            bodyMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar'),
            )
          ],
        );
      });
}

//To display information
void showInformationDialog(
    BuildContext context, String header, String bodyMessage) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            header,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            bodyMessage,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar'),
            )
          ],
        );
      });
}

//To display loading indicator
void showIsLoadingAlertDialog(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            'Por favor espere',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Center(
            child: CustomLoadingIndicator(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   child: Text('Cerrar',
            //       style: TextStyle(
            //         fontFamily: 'Sora',
            //         // backgroundColor: Colors.blue[50],
            //       )),
            // )
          ],
        );
      });
}

Future<int> showDeleteConfirmationAlertDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  Completer<int> completer = Completer<int>();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.onErrorContainer,
              size: 24,
            ),
          ),
          title: Text(
            "Eliminar",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            "¿Está seguro de eliminar este elemento?",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(0); // User selected 'No'
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(1); // User selected 'Yes'
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sí'),
            ),
          ],
        );
      });
  return completer.future;
}
