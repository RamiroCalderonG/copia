import 'package:flutter/material.dart';

class CustomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomSaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Guardar'),
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomCancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade300),
      ),
      onPressed: onPressed,
      child: const Text('Cancelar'),
    );
  }
}
