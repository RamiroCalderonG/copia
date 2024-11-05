// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:file_saver/file_saver.dart'; // Ensure you have the correct import for FileSaver
// import 'package:flutter/material.dart';
// import 'package:pluto_grid/pluto_grid.dart';
// import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
// import 'package:flutter/services.dart';

// class PlutoGridHeader extends StatefulWidget {
//   const PlutoGridHeader({
//     required this.stateManager,
//     super.key,
//   });

//   final PlutoGridStateManager stateManager;

//   @override
//   State<PlutoGridHeader> createState() => _PlutoGridHeaderState();
// }

// class _PlutoGridHeaderState extends State<PlutoGridHeader> {
//   void _printToPdfAndShareOrSave() async {
//     if (widget.stateManager.rows.isEmpty) return;

//     final themeData = pluto_grid_export.ThemeData.withFont(
//       base: pluto_grid_export.Font.ttf(
//         await rootBundle.load('assets/fonts/SoraFont/static/Sora-Regular.ttf'),
//       ),
//       bold: pluto_grid_export.Font.ttf(
//         await rootBundle.load('assets/fonts/SoraFont/static/Sora-Regular.ttf'),
//       ),
//     );

//     var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
//       title: "PDF",
//       creator: "Ox School",
//       format: pluto_grid_export.PdfPageFormat.a4.portrait,
//       themeData: themeData,
//     );

//     await pluto_grid_export.Printing.sharePdf(
//       bytes: await plutoGridPdfExport.export(widget.stateManager),
//       filename: plutoGridPdfExport.getFilename(),
//     );
//   }

//   void _defaultExportGridAsCSV() async {
//     if (widget.stateManager.rows.isEmpty) return;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return ExportDialog(stateManager: widget.stateManager);
//       },
//     );
//   }

//   void _defaultExportGridAsCSVCompatibleWithExcel() async {
//     if (widget.stateManager.rows.isEmpty) return;

//     String title = "pluto_grid_export";
//     var exportCSV =
//         pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
//     var exported =
//         Uint8List.fromList(const Utf8Encoder().convert('\u{FEFF}$exportCSV'));

//     await FileSaver.instance.saveFile(
//       name: "$title.csv",
//       bytes: exported,
//       ext: ".csv",
//       mimeType: MimeType.csv,
//     );
//   }

//   void _defaultExportGridAsCSVFakeExcel() async {
//     if (widget.stateManager.rows.isEmpty) return;

//     String title = "pluto_grid_export";
//     var exportCSV =
//         pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
//     var exported =
//         Uint8List.fromList(const Utf8Encoder().convert('\u{FEFF}$exportCSV'));

//     await FileSaver.instance.saveFile(
//       name: "$title.xls",
//       bytes: exported,
//       ext: ".xls",
//       mimeType: MimeType.csv,
//     );
//   }

//   void _defaultExportGridAsCSVWithSemicolon() async {
//     if (widget.stateManager.rows.isEmpty) return;

//     String title = "pluto_grid_export";
//     var exported = Uint8List.fromList(const Utf8Encoder().convert(
//       pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager,
//           fieldDelimiter: ";"),
//     ));

//     await FileSaver.instance.saveFile(
//       name: "$title.csv",
//       bytes: exported,
//       ext: ".csv",
//       mimeType: MimeType.csv,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SizedBox(
//         height: widget.stateManager.headerHeight,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Wrap(
//             spacing: 10,
//             children: [
//               ElevatedButton(
//                 onPressed: _printToPdfAndShareOrSave,
//                 child: const Text("Print to PDF and Share"),
//               ),
//               ElevatedButton(
//                 onPressed: _defaultExportGridAsCSV,
//                 child: const Text("Export to CSV"),
//               ),
//               ElevatedButton(
//                 onPressed: _defaultExportGridAsCSVWithSemicolon,
//                 child: const Text("Export to CSV with Semicolon ';'"),
//               ),
//               ElevatedButton(
//                 onPressed: _defaultExportGridAsCSVCompatibleWithExcel,
//                 child: const Text("UTF-8 CSV compatible with MS Excel"),
//               ),
//               ElevatedButton(
//                 onPressed: _defaultExportGridAsCSVFakeExcel,
//                 child: const Text("Fake MS Excel .xls export"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ExportDialog extends StatefulWidget {
//   final PlutoGridStateManager stateManager;

//   const ExportDialog({required this.stateManager});

//   @override
//   _ExportDialogState createState() => _ExportDialogState();
// }

// class _ExportDialogState extends State<ExportDialog> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _exportGridAsCSV();
//   }

//   Future<void> _exportGridAsCSV() async {
//     try {
//       String title = "grid_export";
//       var exported = Uint8List.fromList(
//         const Utf8Encoder().convert(
//           pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager),
//         ),
//       );

//       String? directoryPath = await FilePicker.platform.getDirectoryPath();

//       if (directoryPath != null) {
//         String filePath = '$directoryPath/$title.csv';
//         File file = File(filePath);
//         await file.writeAsBytes(exported);
//         print('File saved to $filePath');
//       }
//     } catch (e) {
//       print('Error saving file: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: _isLoading
//             ? const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(width: 20),
//                   Text("Exporting ..."),
//                 ],
//               )
//             : Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                       "Download complete. Check the selected directory!"),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text("Close"),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

/*
import 'dart:convert';

import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridHeader extends StatefulWidget {
  const PlutoGridHeader({
    required this.stateManager,
    super.key,
  });

  final PlutoGridStateManager stateManager;

  @override
  State<PlutoGridHeader> createState() => _PlutoGridHeaderState();
}

class _PlutoGridHeaderState extends State<PlutoGridHeader> {
  void _printToPdfAndShareOrSave() async {
    // var excel_grid_export;
    final themeData = pluto_grid_export.ThemeData.withFont(
      base: pluto_grid_export.Font.ttf(
        await rootBundle.load('assets/fonts/SoraFont/static/Sora-Regular.ttf'),
      ),
      bold: pluto_grid_export.Font.ttf(
        await rootBundle.load('assets/fonts/SoraFont/static/Sora-Regular.ttf'),
      ),
    );

    var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
      title: "PDF",
      creator: "Ox School",
      format: pluto_grid_export.PdfPageFormat.a4.portrait,
      themeData: themeData,
    );

    await pluto_grid_export.Printing.sharePdf(
        bytes: await plutoGridPdfExport.export(widget.stateManager),
        filename: plutoGridPdfExport.getFilename());
  }

  // This doesn't works properly in systems different from Windows.
  // Disabled for now
  // void _printToPdfWithDialog() async {
  //   var originalFormat = PdfPageFormat.a4.landscape;
  //
  //   var plutoGridDefaultPdfExport = PlutoGridDefaultPdfExport(
  //       title: "Pluto Grid Sample pdf print",
  //       creator: "Pluto Grid Rocks!",
  //       format: originalFormat);
  //
  //   await Printing.layoutPdf(
  //       format: originalFormat,
  //       name: plutoGridDefaultPdfExport.getFilename(),
  //       onLayout: (PdfPageFormat format) async {
  //         // Update format onLayout
  //         plutoGridDefaultPdfExport.format = format;
  //         return plutoGridDefaultPdfExport.export(widget.stateManager);
  //       });
  // }

  void _defaultExportGridAsCSV() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExportDialog(stateManager: widget.stateManager);
      },
    );
  }

  // void _defaultExportGridAsCSV() async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return const Dialog(
  //         child: Padding(
  //           padding: EdgeInsets.all(20.0),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircularProgressIndicator(),
  //               SizedBox(width: 20),
  //               Text("Exporting ..."),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     String title = "grid_export";
  //     // var pluto_grid_export;
  //     var exported = const Utf8Encoder().convert(
  //         pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager));
  //     await FileSaver.instance.saveFile(
  //       name: title,
  //       bytes: exported,
  //       ext: ".csv",
  //     );
  //   } finally {
  //     // ignore: use_build_context_synchronously
  //     // Navigator.of(context).pop(); // Close the dialog
  //   }
  //   // String title = "pluto_grid_export";
  //   // // var pluto_grid_export;
  //   // var exported = const Utf8Encoder().convert(
  //   //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager));
  //   // await FileSaver.instance.saveFile(
  //   //   name: "$title.csv",
  //   //   bytes: exported,
  //   //   ext: ".csv",
  //   // );
  // }

  void _defaultExportGridAsCSVCompatibleWithExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVFakeExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.xls", exported, ".xls");
  }

  // void _exportGridAsTSV() async {
  //   String title = "pluto_grid_export";
  //   var exported = const Utf8Encoder().convert(PlutoGridExport.exportCSV(
  //     widget.stateManager,
  //     fieldDelimiter: "\t",
  //   ));
  //   await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  // }

  void _defaultExportGridAsCSVWithSemicolon() async {
    // String title = "pluto_grid_export";
    // var exported =
    //     const Utf8Encoder().convert(pluto_grid_export.PlutoGridExport.exportCSV(
    //   widget.stateManager,
    //   fieldDelimiter: ";",
    // ));
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: widget.stateManager.headerHeight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                  onPressed: _printToPdfAndShareOrSave,
                  child: const Text("Print to PDF and Share")),

              // TODO This works only under Windows, disabled for now
              // ElevatedButton(
              //     onPressed: _printToPdfWithDialog,
              //     child: const Text("Print PDF with dialog (Windows only)")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSV,
                  child: const Text("Export to CSV")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVWithSemicolon,
                  child: const Text("Export to CSV with Semicolon ';'")),
              // ElevatedButton(
              //     onPressed: _exportGridAsTSV,
              //     child: const Text("Export to TSV (tab separated)")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVCompatibleWithExcel,
                  child: const Text("UTF-8 CSV compatible with MS Excel")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVFakeExcel,
                  child: const Text("Fake MS Excel .xls export")),
            ],
          ),
        ),
      ),
    );
  }
}

class ExportDialog extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  const ExportDialog({required this.stateManager});

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _exportGridAsCSV();
  }

  Future<void> _exportGridAsCSV() async {
    try {
      String title = "grid_export";
      var exported = const Utf8Encoder().convert(
          pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager));
      await FileSaver.instance.saveFile(
        name: title,
        bytes: exported,
        ext: ".csv",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Exporting ..."),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "Descarga realizada, revisar carpeta de descargas!"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              ),
      ),
    );
  }
}*/
