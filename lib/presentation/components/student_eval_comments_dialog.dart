import 'package:flutter/material.dart';

import '../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../core/reusable_methods/academic_functions.dart';
import '../../data/services/backend/api_requests/api_calls_list_dio.dart';

class StudentEvalCommentDialog extends StatefulWidget {
  final String studentName;
  final List<Map<String, dynamic>> comments;
  final String subjectName;
  const StudentEvalCommentDialog(
      {super.key,
      required this.studentName,
      required this.comments,
      required this.subjectName});

  @override
  State<StudentEvalCommentDialog> createState() =>
      _StudentEvalCommentDialogState();
}

class _StudentEvalCommentDialogState extends State<StudentEvalCommentDialog> {
  List<Map<String, dynamic>>? filteredComments;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filteredComments =
        filterCommentsBySubject(widget.comments, widget.subjectName);
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        'Asigna comentarios\nAlumno: ${widget.studentName} \nMateria: ${widget.subjectName} '),
                  )))
        ],
      ),
      titleTextStyle: TextStyle(
          fontFamily: 'Sora',
          fontSize: 20,
          color: FlutterFlowTheme.of(context).primaryText),
      content: SingleChildScrollView(
          child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: filteredComments!.map((comment) {
            return StatefulBuilder(builder: (context, setState) {
              return Column(
                children: [
                  ListTile(
                    title: Text(comment[
                        'commentName']), // Assuming 'comment' instead of 'comentname'
                    trailing: Checkbox(
                        value: comment['active'],
                        onChanged: (newValue) async {
                          var studentRateId = comment['student_rate'];
                          var commentId = comment['comment'];
                          var activevalue = newValue;

                          await putStudentEvaluationsComments(
                              studentRateId, commentId, activevalue!);
                          setState(() => comment['active'] = newValue!);
                        }),
                  ),
                  const Divider(),
                ],
              );
            });
          }).toList(),
        ),
      )),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
