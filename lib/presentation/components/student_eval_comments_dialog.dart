import 'package:flutter/material.dart';

import '../../core/config/flutter_flow/flutter_flow_theme.dart';
import '../../core/reusable_methods/academic_functions.dart';
import '../../data/services/backend/api_requests/api_calls_list.dart';

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
  Widget build(BuildContext context) {
    filteredComments =
        filterCommentsBySubject(widget.comments, widget.subjectName);
    return AlertDialog(
      title: Text(
          'Asigna comentarios\nAlumno: ${widget.studentName} \nMateria: ${widget.subjectName}'),
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
                  const Divider(),
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
                  )
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
