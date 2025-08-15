import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oxschool/data/Models/EmployeePerformanceEvaluation.dart';

class EvaluationDataExporter {
  static Future<void> exportToCSV(
    BuildContext context,
    List<EmployeePerformanceEvaluation> evaluations,
  ) async {
    try {
      final csvData = _generateCSV(evaluations);

      // Copy to clipboard (since we can't directly save files in Flutter web)
      await Clipboard.setData(ClipboardData(text: csvData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'CSV data copied to clipboard! You can paste it into a spreadsheet application.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> exportToJSON(
    BuildContext context,
    List<EmployeePerformanceEvaluation> evaluations,
  ) async {
    try {
      final jsonData = _generateJSON(evaluations);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonData));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'JSON data copied to clipboard!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static String _generateCSV(List<EmployeePerformanceEvaluation> evaluations) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln([
      'Evaluation ID',
      'Employee Name',
      'Department',
      'Position',
      'Period',
      'Status',
      'Evaluation Date',
      'Due Date',
      'Overall Score',
      'Technical Skills',
      'Communication Skills',
      'Teamwork',
      'Leadership',
      'Problem Solving',
      'Reliability',
      'Initiative',
      'Quality of Work',
      'Strengths',
      'Areas for Improvement',
      'Development Plan',
      'Comments',
      'Created At',
    ].map((field) => '"$field"').join(','));

    // CSV Data
    for (final eval in evaluations) {
      buffer.writeln([
        eval.evaluationId ?? '',
        eval.employeeName ?? '',
        eval.department ?? '',
        eval.position ?? '',
        eval.period ?? '',
        eval.status ?? '',
        eval.evaluationDate?.toIso8601String() ?? '',
        eval.dueDate?.toIso8601String() ?? '',
        eval.overallScore?.toString() ?? '',
        eval.technicalSkills?.toString() ?? '',
        eval.communicationSkills?.toString() ?? '',
        eval.teamwork?.toString() ?? '',
        eval.leadership?.toString() ?? '',
        eval.problemSolving?.toString() ?? '',
        eval.reliability?.toString() ?? '',
        eval.initiative?.toString() ?? '',
        eval.qualityOfWork?.toString() ?? '',
        _escapeCSVField(eval.strengths ?? ''),
        _escapeCSVField(eval.areasForImprovement ?? ''),
        _escapeCSVField(eval.developmentPlan ?? ''),
        _escapeCSVField(eval.comments ?? ''),
        eval.createdAt?.toIso8601String() ?? '',
      ].map((field) => '"$field"').join(','));
    }

    return buffer.toString();
  }

  static String _generateJSON(List<EmployeePerformanceEvaluation> evaluations) {
    final List<Map<String, dynamic>> jsonList =
        evaluations.map((eval) => eval.toJson()).toList();

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'evaluations': jsonList,
      'exportDate': DateTime.now().toIso8601String(),
      'totalRecords': evaluations.length,
    });
  }

  static String _escapeCSVField(String field) {
    // Escape quotes and handle multiline text
    return field
        .replaceAll('"', '""')
        .replaceAll('\n', ' ')
        .replaceAll('\r', '');
  }

  static void showExportDialog(
    BuildContext context,
    List<EmployeePerformanceEvaluation> evaluations,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Evaluation Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose export format:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        exportToCSV(context, evaluations);
                      },
                      icon: const Icon(Icons.table_chart),
                      label: const Text('CSV'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        exportToJSON(context, evaluations);
                      },
                      icon: const Icon(Icons.code),
                      label: const Text('JSON'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
