import 'package:flutter/material.dart';

class NoDataAvailble extends StatelessWidget {
  const NoDataAvailble({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Center(
        child:
            Text('No se tiene información disponible, intente volver a cargar'),
      ),
    );
  }
}
