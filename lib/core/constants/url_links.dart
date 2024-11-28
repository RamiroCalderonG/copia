import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> oxlinks = [
  'https://oxschool.edu.mx/index.aspx',
  'https://hs.oxschool.edu.mx/',
  'https://oxschool.edu.mx/index.aspx?seccion=calendario',
  'https://oxschool.edu.mx/index.aspx?seccion=aulavirtualacceso',
  'https://oxschool.edu.mx/index.aspx?seccion=noticias',
  'https://oxschool.edu.mx/index.aspx?seccion=cafeteria'
];

final List<String> gridMainWindowIcons = [
  'assets/images/instalaciones.png',
  'assets/images/instalaciones.png',
  'assets/images/calendario.png',
  'assets/images/aulaVirtual.png',
  'assets/images/news.png',
  'assets/images/cafe.png',
];

final List<Color> gridMainWindowColors = [
  const Color.fromRGBO(23, 76, 147, 1),
  const Color.fromRGBO(246, 146, 51, 1),
  const Color.fromRGBO(235, 48, 69, 1),
  const Color.fromRGBO(23, 76, 147, 1),
  const Color.fromRGBO(246, 146, 51, 1),
  const Color.fromRGBO(235, 48, 69, 1)
];

final List<Color> gridDarkColorsMainWindow = [
  const Color.fromRGBO(62, 120, 178, 1),
  const Color.fromRGBO(222, 158, 54, 1),
  const Color.fromRGBO(227, 101, 91, 1),
  const Color.fromRGBO(62, 120, 178, 1),
  const Color.fromRGBO(222, 158, 54, 1),
  const Color.fromRGBO(227, 101, 91, 1),
];

final List<String> mainWindowGridTitles = [
  'Ox School',
  'Ox High School',
  'Calendario de eventos',
  'Aula Virtual',
  'Noticias',
  'Cafetería'
];

Future<void> launchUrlDirection(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
