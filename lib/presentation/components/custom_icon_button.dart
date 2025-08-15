import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon? icon;
  final String tooltip;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoButton(onPressed: onPressed, child: Text(tooltip))
        : ElevatedButton.icon(
            onPressed: onPressed, icon: icon, label: Text(tooltip));
  }
}

class AddItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      tooltip: 'Nuevo ',
    );
  }
}

class SaveItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.save),
      tooltip: 'Guardar',
    );
  }
}

class EditItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.edit),
      tooltip: 'Editar registro',
    );
  }
}

class DeleteItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.delete),
      tooltip: 'Eliminar registro',
    );
  }
}

class RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RefreshButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh),
      tooltip: 'Actualizar',
    );
  }
}

class PrintButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PrintButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.print),
      tooltip: 'Imprimir',
    );
  }
}

class ExportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.file_download),
      tooltip: 'Exportar',
    );
  }
}

class ExcelActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExcelActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: Icon(Icons.file_present),
      tooltip: 'Excel',
    );
  }
}

class CancelActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.cancel),
      tooltip: 'Cancelar',
    );
  }
}

class ShowHistoryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShowHistoryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.history),
      tooltip: 'Historial',
    );
  }
}
