import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as pw show AssetImage;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:oxschool/data/Models/Fodac60Item.dart';

class Fodac59Report {
  static const double pageMargin = 30;

  /// Export data to PDF format
  static Future<Uint8List> exportToPdf(
    List<Fodac60Item> data,
    List<String> columns,
    bool pdfLandscape,
    bool useStudentReportCards,
  ) async {
    try {
      if (useStudentReportCards) {
        return await _generateStudentReportCardsPdf(data);
      }

      // Original table-based PDF generation
      final pdf = pw.Document();
      const rowsPerPage = 15;
      final pageFormat =
          pdfLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

      for (int startIndex = 0;
          startIndex < data.length;
          startIndex += rowsPerPage) {
        final endIndex = (startIndex + rowsPerPage > data.length)
            ? data.length
            : startIndex + rowsPerPage;
        final pageData = data.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(pageMargin),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue200),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'FO-DAC-59 - Reporte Académico',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  // Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    columnWidths: _getColumnWidths(
                        columns, pageFormat.availableWidth - 2 * pageMargin),
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.grey100),
                        children: columns
                            .map((column) => pw.Container(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    _getColumnDisplayName(column),
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      // Data rows
                      ...pageData.map((item) => pw.TableRow(
                            children: columns
                                .map((column) => pw.Container(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: pw.Text(
                                        _getColumnValue(item, column),
                                        style: const pw.TextStyle(fontSize: 7),
                                      ),
                                    ))
                                .toList(),
                          )),
                    ],
                  ),
                  pw.Spacer(),
                  // Footer
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'Página ${(startIndex ~/ rowsPerPage) + 1} de ${((data.length - 1) ~/ rowsPerPage) + 1}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      return await pdf.save();
    } catch (e) {
      print('Error in exportToPdf: $e');
      rethrow;
    }
  }

  /// Generate student report cards PDF
  static Future<Uint8List> _generateStudentReportCardsPdf(
      List<Fodac60Item> data) async {
    print('🎯 Iniciando generación de tarjetas de reporte de estudiantes');
    print('📊 Total de elementos a procesar: ${data.length}');

    final pdf = pw.Document();

    // Group students by nombreGrupo
    final Map<String, List<Fodac60Item>> groupedData =
        <String, List<Fodac60Item>>{};

    for (final item in data) {
      final groupKey =
          item.nombreGrupo.isNotEmpty ? item.nombreGrupo : 'Sin Grupo';
      if (!groupedData.containsKey(groupKey)) {
        groupedData[groupKey] = [];
      }
      groupedData[groupKey]!.add(item);
    }

    print('📚 Grupos encontrados: ${groupedData.keys.length}');
    for (final entry in groupedData.entries) {
      print('   - ${entry.key}: ${entry.value.length} estudiantes');
    }

    // Generate report cards for each group
    for (final entry in groupedData.entries) {
      final groupName = entry.key;
      final students = entry.value;

      print('🏫 Procesando grupo: $groupName (${students.length} estudiantes)');

      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        print(
            '👨‍🎓 Generando tarjeta para: ${student.nombre} (${i + 1}/${students.length})');

        try {
          final pageWidget = await _buildStudentReportPage(student, groupName);
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.all(20),
              build: (pw.Context context) => pageWidget,
            ),
          );
        } catch (e) {
          print('❌ Error generando página para ${student.nombre}: $e');
        }
      }
    }

    print('✅ PDF generado exitosamente');
    return await pdf.save();
  }

  /// Build individual student report page
  static Future<pw.Widget> _buildStudentReportPage(
      Fodac60Item student, String groupName) async {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        await _buildPdfHeader(student),
        pw.SizedBox(height: 20),
        _buildStudentInfoSection(student, groupName),
        pw.SizedBox(height: 20),
        _buildAcademicSections(student),
      ],
    );
  }

  /// Build PDF header
  static Future<pw.Widget> _buildPdfHeader(Fodac60Item student) async {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo placeholder
              pw.Container(
                width: 50,
                height: 50,
                decoration: pw.BoxDecoration(
                    // image: pw.DecorationImage(
                    //   image: pw.MemoryImage(
                    //     (await rootBundle.load('assets/images/oxford_logo.png'))
                    //         .buffer
                    //         .asUint8List(),
                    //   ),
                    //   fit: pw.BoxFit.cover,
                    // ),
                    ),
              ),
              // pw.SizedBox(width: 15),
            ],
          ),
        ),
        // Left side - Logo and name
        pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Oxford School of English',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                // pw.SizedBox(height: 2),
                pw.SizedBox(height: 2),
                pw.Text(
                  student.telCampus,
                  style: pw.TextStyle(
                    fontSize: 8,
                    // color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  student.dirCampus,
                  style: pw.TextStyle(
                    fontSize: 8,
                    // color: PdfColors.blue,
                  ),
                ),
                pw.Text(
                  student.claCiclo,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            )),
        pw.Expanded(
            child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              student.regSepCampus,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.black,
              ),
            ),
          ],
        )),
      ],
    );
  }

  /// Build student information section
  static pw.Widget _buildStudentInfoSection(
      Fodac60Item student, String groupName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        border:
            pw.Border.all(color: PdfColors.black, style: pw.BorderStyle.solid),
      ),
      child: pw.Column(
        children: [
          // Student information row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Alumno: ${student.nombre}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                'Matrícula: ${student.matricula}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                'Gdo: ${student.nomGrado}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.black,
                ),
              ),
              pw.Text(
                'Gpo: ${student.grupo}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Grade header row
          pw.Row(
            children: [
              // Subject name column (wider)
              pw.Expanded(
                flex: 3,
                child: pw.Container(),
              ),
              // Cal column
              pw.Expanded(
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                  child: pw.Text(
                    'Cal',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Month columns
              ...[
                'Sep',
                'Oct',
                'Nov',
                'Dic',
                'Ene',
                'Feb',
                'Abr',
                'May',
                'Jun',
                'Prom.'
              ].map(
                (month) => pw.Expanded(
                  child: pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 0.5),
                    ),
                    child: pw.Text(
                      month,
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build academic sections
  static pw.Widget _buildAcademicSections(Fodac60Item student) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Academic subjects with the exact format from the image
          _buildAcademicSection('1° DESARROLLO COGNOSCITIVO', [
            {'name': 'LENGUAJE', 'grade': 'B'},
            {'name': 'NÚMEROS', 'grade': 'B'},
            {'name': 'NATURALEZA', 'grade': 'B'},
            {'name': 'ESPAÑOL', 'grade': 'B'},
            {'name': 'ESTIMULACIÓN TEMPRANA', 'grade': 'B'},
          ]),

          _buildAcademicSection('2° ADAPTABILIDAD EMOCIONAL Y SOCIAL', [
            {'name': 'EXPRESA SUS SENTIMIENTOS', 'grade': 'A'},
            {'name': 'PARTICIPA EN CANTOS Y JUEGOS', 'grade': 'A'},
            {'name': 'CONVIVE CON SUS COMPAÑEROS', 'grade': 'A'},
            {'name': 'ESCUCHA CON ATENCIÓN A OTROS', 'grade': 'B'},
            {'name': 'COORDINACIÓN MOTRIZ', 'grade': 'A'},
          ]),

          _buildAcademicSection('3° DISCIPLINA', [
            {'name': 'SIGUE INSTRUCCIONES', 'grade': 'B'},
            {'name': 'CUMPLE CON EL UNIFORME', 'grade': 'A'},
          ]),

          _buildAcademicSection('PUNTUALIDAD Y ASISTENCIA', [
            {'name': 'AUSENCIAS', 'grade': 'B'},
            {'name': 'DÍAS TARDE', 'grade': ''},
          ]),

          pw.Spacer(),

          // Bottom section with observations and signatures
          _buildBottomSection(student),
        ],
      ),
    );
  }

  /// Build individual academic section
  static pw.Widget _buildAcademicSection(
      String title, List<Map<String, dynamic>> subjects) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
            ),
          ),

          // Subject rows
          ...subjects.map((subject) => _buildSubjectRow(subject)),
        ],
      ),
    );
  }

  /// Build individual subject row
  static pw.Widget _buildSubjectRow(Map<String, dynamic> subject) {
    return pw.Row(
      children: [
        // Subject name
        pw.Expanded(
          flex: 3,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Text(
              subject['name'] ?? '',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ),

        // Grade level indicator
        pw.Container(
          width: 30,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.5),
          ),
          child: pw.Text(
            subject['grade'] ?? '',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),

        // Monthly grade columns (10 months)
        ...List.generate(
          10,
          (index) => pw.Container(
            width: 25,
            padding: const pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Text(
              '', // Empty for now, can be filled with actual grades
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),

        // Average column
        pw.Container(
          width: 25,
          padding: const pw.EdgeInsets.all(2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.5),
          ),
          child: pw.Text(
            '',
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build bottom section with observations and signatures
  static pw.Widget _buildBottomSection(Fodac60Item student) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Observations section
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              height: 80,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Observaciones:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  // Lines for observations
                  for (int i = 0; i < 4; i++) ...[
                    pw.Container(
                      width: double.infinity,
                      height: 1,
                      color: PdfColors.grey,
                    ),
                    pw.SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

          pw.SizedBox(width: 20),

          // Right side with rating legend and signatures
          pw.Expanded(
            child: pw.Column(
              children: [
                // Rating legend
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    'A= Muy Bien  B= Bien  C=Corrección ND= No Domina',
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 20),

                // Coordinator signature with green line
                pw.Column(
                  children: [
                    pw.Container(
                      width: 120,
                      height: 2,
                      color: PdfColors.green,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Coordinadora',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 15),

                // Director signature with purple line
                pw.Column(
                  children: [
                    pw.Container(
                      width: 120,
                      height: 2,
                      color: PdfColors.purple,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Director(a)',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Form number
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'FO-DAC-59',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get column widths for table
  static Map<int, pw.TableColumnWidth> _getColumnWidths(
      List<String> columns, double availableWidth) {
    final Map<int, pw.TableColumnWidth> widths = {};
    final double columnWidth = availableWidth / columns.length;

    for (int i = 0; i < columns.length; i++) {
      widths[i] = pw.FixedColumnWidth(columnWidth);
    }

    return widths;
  }

  /// Get column display name
  static String _getColumnDisplayName(String column) {
    final Map<String, String> displayNames = {
      'numeroControl': 'Matrícula',
      'nombres': 'Nombres',
      'apellidos': 'Apellidos',
      'nombreGrupo': 'Grupo',
      'nivel': 'Nivel',
      'turno': 'Turno',
      'cal1Mat': 'Cal1 Mat',
      'cal2Mat': 'Cal2 Mat',
      'cal3Mat': 'Cal3 Mat',
      'promedioMat': 'Prom Mat',
      'cal1Esp': 'Cal1 Esp',
      'cal2Esp': 'Cal2 Esp',
      'cal3Esp': 'Cal3 Esp',
      'promedioEsp': 'Prom Esp',
      'cal1Ing': 'Cal1 Ing',
      'cal2Ing': 'Cal2 Ing',
      'cal3Ing': 'Cal3 Ing',
      'promedioIng': 'Prom Ing',
      'cal1Qui': 'Cal1 Qui',
      'cal2Qui': 'Cal2 Qui',
      'cal3Qui': 'Cal3 Qui',
      'promedioQui': 'Prom Qui',
      'cal1His': 'Cal1 His',
      'cal2His': 'Cal2 His',
      'cal3His': 'Cal3 His',
      'promedioHis': 'Prom His',
      'cal1Geo': 'Cal1 Geo',
      'cal2Geo': 'Cal2 Geo',
      'cal3Geo': 'Cal3 Geo',
      'promedioGeo': 'Prom Geo',
      'cal1Fil': 'Cal1 Fil',
      'cal2Fil': 'Cal2 Fil',
      'cal3Fil': 'Cal3 Fil',
      'promedioFil': 'Prom Fil',
      'cal1Fis': 'Cal1 Fis',
      'cal2Fis': 'Cal2 Fis',
      'cal3Fis': 'Cal3 Fis',
      'promedioFis': 'Prom Fis',
      'cal1Bio': 'Cal1 Bio',
      'cal2Bio': 'Cal2 Bio',
      'cal3Bio': 'Cal3 Bio',
      'promedioBio': 'Prom Bio',
      'promedioGeneral': 'Prom Gral',
    };

    return displayNames[column] ?? column;
  }

  /// Get column value
  static String _getColumnValue(Fodac60Item item, String column) {
    switch (column) {
      case 'numeroControl':
        return item.matricula;
      case 'nombres':
        return item.nombre;
      case 'apellidos':
        return '';
      case 'nombreGrupo':
        return item.nombreGrupo;
      case 'nivel':
        return item.nomGrado;
      case 'turno':
        return '';
      case 'cal1Mat':
        return item.calif1.toString();
      case 'cal2Mat':
        return item.calif2.toString();
      case 'cal3Mat':
        return item.calif3.toString();
      case 'promedioMat':
        return item.promedioCal.toString();
      case 'cal1Esp':
        return item.calif4.toString();
      case 'cal2Esp':
        return item.calif5.toString();
      case 'cal3Esp':
        return item.calif6.toString();
      case 'promedioEsp':
        return item.promedioCal.toString();
      case 'cal1Ing':
        return item.calif7.toString();
      case 'cal2Ing':
        return item.calif8.toString();
      case 'cal3Ing':
        return item.calif9.toString();
      case 'promedioIng':
        return item.promedioCal.toString();
      case 'cal1Qui':
        return item.calif10.toString();
      case 'cal2Qui':
        return '';
      case 'cal3Qui':
        return '';
      case 'promedioQui':
        return item.promedioCal.toString();
      case 'cal1His':
        return '';
      case 'cal2His':
        return '';
      case 'cal3His':
        return '';
      case 'promedioHis':
        return '';
      case 'cal1Geo':
        return '';
      case 'cal2Geo':
        return '';
      case 'cal3Geo':
        return '';
      case 'promedioGeo':
        return '';
      case 'cal1Fil':
        return '';
      case 'cal2Fil':
        return '';
      case 'cal3Fil':
        return '';
      case 'promedioFil':
        return '';
      case 'cal1Fis':
        return '';
      case 'cal2Fis':
        return '';
      case 'cal3Fis':
        return '';
      case 'promedioFis':
        return '';
      case 'cal1Bio':
        return '';
      case 'cal2Bio':
        return '';
      case 'cal3Bio':
        return '';
      case 'promedioBio':
        return '';
      case 'promedioGeneral':
        return item.promedioCal.toString();
      default:
        return '';
    }
  }

  /// Print report method
  static Future<void> printReport(
    List<Fodac60Item> data,
    List<String> columns,
    bool pdfLandscape,
    bool useStudentReportCards,
    Function(String) onStatusUpdate,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      onStatusUpdate('Preparando impresión...');

      // Generate PDF bytes for printing
      final Uint8List pdfBytes =
          await exportToPdf(data, columns, pdfLandscape, useStudentReportCards);

      onStatusUpdate('Enviando a impresora...');

      // Use the printing package to print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'FO-DAC-59_Reporte_${DateTime.now().millisecondsSinceEpoch}',
        format: pdfLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
      );

      onStatusUpdate('Documento enviado a impresora exitosamente');
      onSuccess('Documento enviado a impresora exitosamente');
    } catch (e) {
      onStatusUpdate('Error al imprimir: $e');
      if (e is pw.TooManyPagesException) {
        onError(
            'El documento es demasiado grande para imprimir. Intenta reducir el número de columnas o filas.');
      } else {
        onError('Error al imprimir: $e');
      }
      print('Error in printReport: $e');
    }
  }
}
