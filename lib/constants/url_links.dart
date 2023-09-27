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
  'assets/images/menu.png',
];

final List<Color> gridMainWindowColors = [
  Color.fromRGBO(23, 76, 147, 1),
  Color.fromRGBO(246, 146, 51, 1),
  Color.fromRGBO(235, 48, 69, 1),
  Color.fromRGBO(23, 76, 147, 1),
  Color.fromRGBO(246, 146, 51, 1),
  Color.fromRGBO(235, 48, 69, 1)
];

final List<String> mainWindowGridTitles = [
  'Ox School',
  'Ox High School',
  'Calendario de eventos',
  'Aula Virtual',
  'Noticias',
  'Cafetería'
];

Future<void> launchUrlDirection(_url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
