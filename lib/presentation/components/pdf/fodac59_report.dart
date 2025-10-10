import 'dart:typed_data';
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

    // Group by unique students (matricula) to ensure one page per student
    final Map<String, List<Fodac60Item>> studentData =
        <String, List<Fodac60Item>>{};

    for (final item in data) {
      final studentKey =
          item.matricula.isNotEmpty ? item.matricula : 'Sin Matrícula';
      if (!studentData.containsKey(studentKey)) {
        studentData[studentKey] = [];
      }
      studentData[studentKey]!.add(item);
    }

    print('� Estudiantes únicos encontrados: ${studentData.keys.length}');
    for (final entry in studentData.entries) {
      print('   - Matrícula ${entry.key}: ${entry.value.length} materias');
    }

    // Generate one page per unique student
    for (final entry in studentData.entries) {
      final studentMatricula = entry.key;
      final studentSubjects = entry.value;

      // Use the first record to get student info (all records have same student info)
      final studentInfo = studentSubjects.first;

      print(
          '� Generando página para: ${studentInfo.nombre} (Matrícula: $studentMatricula)');

      try {
        final pageWidget =
            await _buildStudentReportPage(studentInfo, studentSubjects);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) => pageWidget,
          ),
        );
      } catch (e) {
        print('❌ Error generando página para ${studentInfo.nombre}: $e');
      }
    }

    print('✅ PDF generado exitosamente');
    return await pdf.save();
  }

  /// Build individual student report page
  static Future<pw.Widget> _buildStudentReportPage(
      Fodac60Item studentInfo, List<Fodac60Item> studentSubjects) async {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        await _buildPdfHeader(studentInfo),
        pw.SizedBox(height: 20),
        _buildStudentInfoSection(studentInfo, studentInfo.nombreGrupo),
        pw.SizedBox(height: 20),
        _buildAcademicSections(studentInfo, studentSubjects),
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
                  image: pw.DecorationImage(
                    image: pw.MemoryImage(
                      (await rootBundle.load('assets/images/oxford_logo.png'))
                          .buffer
                          .asUint8List(),
                    ),
                    fit: pw.BoxFit.cover,
                  ),
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
              'Incorporado a la SEP No.',
              style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.black,
                  fontWeight: pw.FontWeight.bold),
            ),
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
    return pw.Column(
      children: [
        pw.Container(
          padding:
              const pw.EdgeInsets.only(right: 12, left: 12, top: 8, bottom: 8),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(
                color: PdfColors.black, style: pw.BorderStyle.solid),
          ),
          child:
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
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          children: [
            // Subject name column header (wider) - matches subject row flex: 3
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 18, // Shorter rectangular height
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(2),
                margin: const pw.EdgeInsets.only(right: 4),
                // decoration: pw.BoxDecoration(
                //   border: pw.Border.all(color: PdfColors.black, width: 0.5),
                //   borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                // ),
                // child: pw.Text(
                //   'MATERIA',
                //   style: pw.TextStyle(
                //     fontSize: 8,
                //     fontWeight: pw.FontWeight.bold,
                //   ),
                // ),
              ),
            ),

            // Month columns - each with fixed width: 30 (more rectangular)
            ...[
              'Sep',
              'Oct',
              'Nov',
              'Dic',
              'Ene',
              'Feb',
              'Mar',
              'Abr',
              'May',
              'Jun'
            ].map(
              (month) => pw.Container(
                width: 30, // Wider for better rectangular shape
                height: 18, // Shorter rectangular height
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(2),
                margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Text(
                  month,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Average column header
            pw.Container(
              width: 30, // Match other columns
              height: 18, // Shorter rectangular height
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(2),
              margin: const pw.EdgeInsets.only(left: 1),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                'Prom',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build academic sections
  static pw.Widget _buildAcademicSections(
      Fodac60Item student, List<Fodac60Item> studentSubjects) {
    // Group subjects by nombreGrupo
    final Map<String, List<Fodac60Item>> subjectsByGroup =
        <String, List<Fodac60Item>>{};

    for (final subject in studentSubjects) {
      final groupKey = subject.nombreGrupo.isNotEmpty
          ? subject.nombreGrupo
          : 'MATERIAS GENERALES';
      if (!subjectsByGroup.containsKey(groupKey)) {
        subjectsByGroup[groupKey] = [];
      }
      subjectsByGroup[groupKey]!.add(subject);
    }

    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Build sections dynamically based on student's actual subjects grouped by nombreGrupo
          ...subjectsByGroup.entries.map((entry) {
            final groupName = entry.key;
            final subjects = entry.value;

            // Convert subjects to the format expected by _buildAcademicSection
            final subjectList = subjects.map((subject) {
              // Use the letter grade (CalifNC) values - using promedioCalC as the average grade
              String grade =
                  subject.promedioCalC.isNotEmpty ? subject.promedioCalC : '';

              return {
                'name': subject.nommateria.toUpperCase(),
                'grade': grade,
                'subject': subject, // Keep reference to full subject data
              };
            }).toList();

            return _buildAcademicSection(groupName.toUpperCase(), subjectList);
          }),

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
            width: null, // Remove infinite width - let it expand naturally
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            // decoration: pw.BoxDecoration(
            //   color: PdfColors.grey300,
            //   border: pw.Border.all(color: PdfColors.black, width: 0.5),
            // ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                fontStyle: pw.FontStyle.italic,
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
    final Fodac60Item? subjectData = subject['subject'] as Fodac60Item?;

    // Prepare month grades - mapping CalifC values to correct months
    // Sep, Oct, Nov, Dic, Ene, Feb, Mar, Abr, May, Jun
    final List<String> monthGrades = [];
    if (subjectData != null) {
      monthGrades.addAll([
        subjectData.calif1C.isNotEmpty ? subjectData.calif1C : '', // Sep
        subjectData.calif2C.isNotEmpty ? subjectData.calif2C : '', // Oct
        subjectData.calif3C.isNotEmpty ? subjectData.calif3C : '', // Nov
        subjectData.calif4C.isNotEmpty ? subjectData.calif4C : '', // Dic
        subjectData.calif5C.isNotEmpty ? subjectData.calif5C : '', // Ene
        subjectData.calif6C.isNotEmpty ? subjectData.calif6C : '', // Feb
        subjectData.calif7C.isNotEmpty ? subjectData.calif7C : '', // Mar
        subjectData.calif8C.isNotEmpty ? subjectData.calif8C : '', // Abr
        subjectData.calif9C.isNotEmpty ? subjectData.calif9C : '', // May
        subjectData.calif10C.isNotEmpty ? subjectData.calif10C : '', // Jun
      ]);
    }

    // Ensure we have exactly 10 months worth of data
    while (monthGrades.length < 10) {
      monthGrades.add('');
    }

    return pw.Container(
      height: 18, // Shorter rectangular height to match header
      child: pw.Row(
        children: [
          // Subject name
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              height: 17, // Shorter rectangular height
              padding: const pw.EdgeInsets.all(2),
              margin: const pw.EdgeInsets.only(right: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                subject['name'] ?? '',
                style: const pw.TextStyle(fontSize: 10),
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            ),
          ),

          // Monthly grade columns (10 months: Sep through Jun)
          ...monthGrades.map(
            (grade) => pw.Container(
              width: 30, // Wider for rectangular shape
              height: 17, // Shorter rectangular height
              margin: const pw.EdgeInsets.symmetric(horizontal: 1),
              padding: const pw.EdgeInsets.all(2),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 0.5),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                grade,
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),

          // Average column (Prom)
          pw.Container(
            width: 30, // Match other grade columns
            height: 18, // Shorter rectangular height
            margin: const pw.EdgeInsets.only(left: 1),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              subjectData?.promedioCalC ?? '',
              style: pw.TextStyle(
                fontSize: 10,
                // fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom section with observations and signatures
  static pw.Widget _buildBottomSection(Fodac60Item student) {
    return pw.Column(children: [
      // First row: Observations section (full width)
      pw.Container(
        width: null, // Full width respecting page margins
        height: 80,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black),
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
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
                width: null, // Full width of container
                height: 1,
                color: PdfColors.grey,
              ),
              pw.SizedBox(height: 8),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 10),
      // Second row: Two containers side by side
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              // width: 250,
              height: 40,
              child: pw.Text(
                'A= Muy Bien  B= Bien  C=Corrección ND= No Domina',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: // Right container: Signatures and form number
                pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              // width: 250,
              height: 40,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      // Coordinator signature
                      pw.Column(
                        children: [
                          pw.Text(
                            'Coordinadora',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(student.nombreCoordinadora.trim(),
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 8,
                                // fontWeight: pw.FontWeight.bold,
                              )),
                        ],
                      ),
                      // Director signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Director(a)',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(student.nombreDirectora.trim(),
                              style: pw.TextStyle(
                                fontSize: 8,
                                // fontWeight: pw.FontWeight.bold,
                              )),
                        ],
                      ),
                    ],
                  ),
                  // Form number
                ],
              ),
            ),
          )
        ],
      ),
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
    ]);
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
