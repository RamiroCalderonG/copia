import 'package:flutter/material.dart';

class CustomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomSaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (Theme.of(context).brightness == Brightness.dark) {
              return Colors.white;
            } else {
              return Colors.white; // or any color for light mode
            }
          }),
        ),
        onPressed: onPressed,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.save,
              color: Colors.blue,
            ),
            Text('Guardar', style: TextStyle(color: Colors.blue)),
          ],
        ));
  }
}

class CustomCancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomCancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (Theme.of(context).brightness == Brightness.dark) {
              return Colors.white;
            } else {
              return Colors.white; // or any color for light mode
            }
          }),
        ),
        onPressed: onPressed,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
            ),
            Text(
              'Cancelar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ));
  }
}
