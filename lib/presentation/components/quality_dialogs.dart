import 'package:flutter/material.dart';

Future<void> showMision(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          iconColor: Colors.green[100],
          title: const Text('Nuestra Misión'),
          content: const Text(
            'Desarrollar integralmente a los alumnos con una formación internacional de excelencia y una educación de calidad, a través de la atención oportuna de las necesidades de los alumnos y maximizando el potencial individual logrando su realización personal y sirviendo a su comunidad.',
            // softWrap: true,
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<void> showVision(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nuestra Visión'),
          content: const Text(
            'Ser la institución líder en el idioma inglés con programas académicos competitivos, enfocados en el desarrollo integral de habilidades para el futuro en nuestros alumnos, que sean capaces de solucionar problemas reales con ideas innovadoras y de beneficio para la sociedad, procurando el balance entre las áreas física, mental y social.',
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

Future<void> qualityPolitic(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Política de Calidad'),
          content: const Text(
            'Favorecemos el desarrollo integral de nuestros alumnos en las áreas Matemática, Científica, Tecnológica, Intelectual, Física, Artística, Moral y Social con un dominio del idioma Inglés. Mejoramos continuamente nuestro Sistema Educativo a través de la definición y seguimiento a objetivos, la revisión del programa académico, el aseguramiento de la competencia personal así como la provisión de infraestructura y recursos, tomando en cuenta nuestra interacción con las partes interesadas. Con todo lo anterior cubrimos las expectativas académicas de alumnos, padres de familia y comunidad.',
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
