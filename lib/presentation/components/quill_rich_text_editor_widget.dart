import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

/// A widget that provides rich text editing capabilities using Flutter Quill
class QuillRichTextEditorWidget extends StatefulWidget {
  final String? initialContent;
  final Function(String) onContentChanged; // JSON string
  final String? hintText;
  final int? maxLines;
  final TextStyle? textStyle;
  final bool readOnly;

  const QuillRichTextEditorWidget({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.hintText,
    this.maxLines,
    this.textStyle,
    this.readOnly = false,
  });

  @override
  State<QuillRichTextEditorWidget> createState() =>
      _QuillRichTextEditorWidgetState();
}

class _QuillRichTextEditorWidgetState extends State<QuillRichTextEditorWidget> {
  late QuillController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Initialize controller with existing content or empty document
    Document document;
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        // Try to parse as Quill Delta JSON
        final deltaJson = jsonDecode(widget.initialContent!);
        document = Document.fromJson(deltaJson);
      } catch (e) {
        // If parsing fails, create document with plain text
        document = Document()..insert(0, widget.initialContent!);
      }
    } else {
      document = Document();
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Listen to content changes
    _controller.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onContentChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    // Convert the document to JSON and notify parent
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);
    widget.onContentChanged(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quill Toolbar
        if (!widget.readOnly) ...[
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _controller,
                ),
                // Add custom native bridge buttons
                // _buildNativeBridgeButtons(context),
              ],
            ),
          ),
        ],

        // Quill Editor
        Container(
          constraints: BoxConstraints(
            minHeight: widget.readOnly ? 50 : 120,
            maxHeight: widget.maxLines != null ? widget.maxLines! * 24.0 : 300,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            borderRadius: widget.readOnly
                ? BorderRadius.circular(8)
                : const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: QuillEditor(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: ScrollController(),
          ),
        ),

        // Content info (for debugging/info)
        if (!widget.readOnly) ...[
          const SizedBox(height: 8),
          Text(
            'Content will be saved as JSON format',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}
