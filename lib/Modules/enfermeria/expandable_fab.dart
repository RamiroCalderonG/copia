import 'package:flutter/material.dart';

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:oxschool/components/pdf_viewer_screen.dart';
import 'package:oxschool/constants/Student.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/Modules/enfermeria/new_student_visit.dart';
import 'package:oxschool/reusable_methods/causes_methods.dart';
import 'package:oxschool/reusable_methods/employees_methods.dart';
import 'package:oxschool/reusable_methods/nursery_methods.dart';
import 'package:oxschool/utils/loader_indicator.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpandableFABNursery extends StatefulWidget {
  const ExpandableFABNursery({super.key});

  @override
  State<ExpandableFABNursery> createState() => ExpandableFABNurseryState();
}

class ExpandableFABNurseryState extends State<ExpandableFABNursery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _key = GlobalKey<ExpandableFabState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ExpandableFab(
          key: _key,
          duration: const Duration(milliseconds: 500),
          distance: 100.0,
          type: ExpandableFabType.up,
          pos: ExpandableFabPos.right,
          childrenOffset: const Offset(0, 20),
          fanAngle: 75,
          openButtonBuilder: RotateFloatingActionButtonBuilder(
              child: const Icon(Icons.add),
              fabSize: ExpandableFabSize.regular,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ) //const  CircleBorder(),
              // angle: 3.14 * 2,
              ),
          closeButtonBuilder: FloatingActionButtonBuilder(
            size: 28,
            builder: (BuildContext context, void Function()? onPressed,
                Animation<double> progress) {
              return IconButton(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.check_circle_outline,
                  size: 50,
                ),
              );
            },
          ),
          overlayStyle: ExpandableFabOverlayStyle(
            blur: 5,
          ),
          onOpen: () {
            debugPrint('onOpen');
          },
          afterOpen: () {
            debugPrint('afterOpen');
          },
          onClose: () {
            debugPrint('onClose');
          },
          afterClose: () {
            debugPrint('afterClose');
          },
          children: [
            FloatingActionButton.extended(
              label: Text(
                'Registrar visita de alumno',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(Icons.people),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              tooltip: 'Registrar visita de alumno',
              heroTag: null,
              // child: const Icon(Icons.edit),
              onPressed: () async {
                if (selectedStudent != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await fetchData().whenComplete(
                    () {
                      setState(() {
                        isLoading = false;
                      });
                      showFormDialog(context);
                    },
                  );
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Primero se debe buscar al alumno'),
                          actions: <Widget>[
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
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

                // scaffoldKey.currentState?.showSnackBar(snackBar);
              },
              backgroundColor: Colors.blueAccent,
            ),
            FloatingActionButton.extended(
              label: Text(
                'Agregar medicamento autorizado',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(Icons.edit),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              tooltip: 'Editar información de ficha médica',
              heroTag: null,
              // child: const Icon(Icons.edit),
              onPressed: () {
                const SnackBar snackBar = SnackBar(
                  content: Text("SnackBar"),
                );
              },
              backgroundColor: Colors.blueAccent,
            ),
            FloatingActionButton.extended(
              label: Text(
                'Impresión de fichas',
                style: TextStyle(color: Colors.black),
              ),
              icon: Icon(Icons.print),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              tooltip: 'Impresión de fichas',
              heroTag: null,
              // child: const Icon(Icons.edit),
              onPressed: () {
                // Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyStatefulWidget()));
              },
              backgroundColor: Colors.blueAccent,
            ),
          ],
        ),
        if (isLoading) CustomLoadingIndicator()
      ],
    );
  }

  pw.Document generatePdf() {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Text('Hello, World!', style: pw.TextStyle(fontSize: 20)),
          );
        },
      ),
    );
    return pdf;
  }

  void printPdf() async {
    try {
      setState(() {
        isLoading = true;
      });

      Printing.layoutPdf(onLayout: (PdfPageFormat format) {
        return generatePdf().save();
      });

      // Show a SnackBar to inform the user that the PDF is being processed
      // _scaffoldKey.currentState?.showSnackBar(
      //   SnackBar(
      //     content: Text('Processing PDF...'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

Future fetchData() async {
  causesLst = await getCauses(15);
  painsList = await getPainList('none');
  woundsList = await getWoundsList('none');
  accidentType = await getCauses(14);
  teachersList = await getTeacherByGradeAndGroup(
      selectedStudent.gradoSecuencia,
      selectedStudent.grupo,
      selectedStudent.claUn,
      currentCycle!.claCiclo!,
      currentUser!.employeeNumber!.toString(),
      deviceIp!);
}

void showFormDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Nueva visita a enfermeria'),
        content: NewStudentNurseryVisit(),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancelar'),
            onPressed: () {
              //causesLst.clear();

              Navigator.of(context).pop();

              // selectedStudent = null;
            },
          ),
        ],
      );
    },
  );
}
