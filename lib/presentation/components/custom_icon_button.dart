import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String tooltip;

  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: onPressed, icon: icon, label: Text(tooltip));

    // IconButton.outlined(
    //   onPressed: onPressed,
    //   icon: icon,
    //   tooltip: tooltip,
    // );
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
      tooltip: 'Agregar registro',
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
