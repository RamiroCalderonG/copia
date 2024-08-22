import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

// TODO: PENDING TO USE IT AS FUNCTION TO GENERATE  PDF INSIDE THE APP IN A DYNAMIC WAY

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Future<Uint8List> generatePdf() async {
    var logo = await networkImage(
        'https://oxschool.edu.mx/img/logo-oxford-school.png');

    final pdf = pw.Document();

    final emoji = await PdfGoogleFonts.notoColorEmoji();
    final font = await PdfGoogleFonts.soraRegular();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              'Hello 🐒💁👌🎍😍🦊👨 world! (PDF DE PRUEBA DE IMPRESION, PENDIENTE ARROJAR INFORMACION)',
              style: pw.TextStyle(
                fontFallback: [emoji],
                fontSize: 12,
              ),
            ),
          ); // Center
        }));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Image(pw.MemoryImage(imageBytes)),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(200),
                  1: const pw.FixedColumnWidth(200),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Header 1',
                        style: pw.TextStyle(fontSize: 12, font: font)),
                    pw.Text('Header 2',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Row 1, Col 1',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text('Row 1, Col 2'),
                  ]),
                  pw.TableRow(children: [
                    pw.Text('Row 2, Col 1'),
                    pw.Text('Row 2, Col 2'),
                  ]),
                ],
              ),
            ],
          );
        }));

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw
                  .CrossAxisAlignment.center, // Align the text to start of the
              children: [
                pw.Expanded(child: pw.Image(logo)),
                pw.Expanded(
                    child: pw.Text('Hello World!',
                        style: pw.TextStyle(font: font))),
              ]);
          // pw.Center(
          //   child: pw.Text(
          //     "Texto de ejemplo",
          //     style: const pw.TextStyle(fontSize: 25),
          //   ),
          // ); // Center
        }));

    var image =
        await networkImage('https://oxschool.edu.mx/img/consulta-header.jpg');

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          ); // Center
        }));

    final output = await getTemporaryDirectory();
    debugPrint("${output.path}/example.pdf");
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF View'),
      ),
      body: PdfPreview(
        actions: [
          IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.aws))
        ],
        canChangeOrientation: false,
        build: (context) => generatePdf(),
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          subtitle: Text('Subtitle $index'),
          leading: const Icon(Icons.star),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            if (kDebugMode) {
              print('Tapped on Item $index');
            }
          },
        );
      },
    );
  }
}
