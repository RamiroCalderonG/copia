import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

Future<void> generateDisciplinaryReport(
    String cycle, List<dynamic> data, BuildContext context) async {
  final pdf = pw.Document();
  final oxLogo = await rootBundle.load(
    'assets/images/1_OS_color.png',
  );

  final image = pw.MemoryImage(oxLogo.buffer.asUint8List());

  final int totalMenores = data.fold(
      0, (sum, item) => sum + (int.tryParse(item["Menores"].toString()) ?? 0));
  final int totalMayores = data.fold(
      0, (sum, item) => sum + (int.tryParse(item["Mayores"].toString()) ?? 0));
  final int totalReportes = data.fold(
      0, (sum, item) => sum + (int.tryParse(item["Reportes"].toString()) ?? 0));

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.portrait,
      margin: const pw.EdgeInsets.all(20),
      header: (context) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(children: [pw.Image(image, height: 30)]),
          pw.Column(children: [
            pw.Text("Oxford School of English"),
            pw.Text("Relación de Alumnos Indisciplinados")
          ]),
          pw.Column(children: [pw.Text("Ciclo: $cycle ")]),
        ],
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Fecha: ${DateTime.now().toString().substring(0, 19)}',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ),
      build: (context) => [
        pw.SizedBox(height: 8),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1), //Campus
              1: const pw.FlexColumnWidth(1), //Grado
              2: const pw.FlexColumnWidth(1), //Grupo
              3: const pw.FlexColumnWidth(1.5), //Matricula
              4: const pw.FlexColumnWidth(3), //Nombre del Alumno
              for (int i = 5; i <= 7; i++) i: const pw.FlexColumnWidth(1),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              // Table Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Campus',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Grado',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Grupo',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Mat',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Nombre del Alumno',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Menores',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Mayores',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    child: pw.Text(
                      'Totales',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              // Table Rows
              ...data.map((item) {
                return pw.TableRow(children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["claun"] ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["GradoSecuencia"].toString() ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Grupo"] ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Matricula"] ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Alumno"] ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Menores"].toString() ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Mayores"].toString() ?? '',
                      style: pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      item["Reportes"].toString() ?? '',
                      style: pw.TextStyle(
                          fontSize: 7, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ]);
              }).toList(),
              // Footer (totals row)
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(''),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Totales:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      totalMenores.toString(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      totalMayores.toString(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      totalReportes.toString(),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Directory? saveDir;
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      saveDir = downloadsDir;
      final file = File('${saveDir.path}/reporteDisciplina.pdf');

      try {
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF guardado en la carpeta Descargas 🚩🚩',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        showErrorFromBackend(
            context, 'Error al guardar el PDF: ${e.toString()}');
      }
    }
  }
}
