import 'package:flutter/material.dart';

class CustomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomSaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Guardar'),
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomCancelButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade300),
      ),
      onPressed: onPressed,
      child: Text('Cancelar'),
    );
  }
}
