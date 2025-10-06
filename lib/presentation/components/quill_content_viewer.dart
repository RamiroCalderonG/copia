import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

/// A widget that displays Quill Delta content in read-only mode
class QuillContentViewer extends StatefulWidget {
  final String? quillDeltaJson;
  final String? fallbackText;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isExpandable;

  const QuillContentViewer({
    super.key,
    this.quillDeltaJson,
    this.fallbackText,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.isExpandable = true,
  });

  @override
  State<QuillContentViewer> createState() => _QuillContentViewerState();
}

class _QuillContentViewerState extends State<QuillContentViewer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have Quill Delta content, display it
    if (widget.quillDeltaJson != null && widget.quillDeltaJson!.isNotEmpty) {
      return _buildQuillContent(context);
    }

    // Otherwise, use fallback text
    return _buildFallbackContent(context);
  }

  Widget _buildQuillContent(BuildContext context) {
    try {
      // Parse the Quill Delta JSON
      final deltaJson = json.decode(widget.quillDeltaJson!);
      final document = Document.fromJson(deltaJson);

      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Allow text selection and link clicks by setting readOnly to false
      // We'll prevent actual editing through other means
      controller.readOnly = false;

      // Create a focus node that allows text selection
      final focusNode = FocusNode();
      focusNode.canRequestFocus = true;

      // Check if the document contains only plain text (no formatting)
      final plainText = document.toPlainText();
      final hasOnlyText = _containsOnlyPlainText(document);

      // Calculate height for content only
      final contentMaxHeight = _isExpanded
          ? 600.0 // Use a reasonable maximum instead of infinity
          : (widget.maxLines != null
              ? (widget.maxLines! * 24.0).toDouble()
              : 120.0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
              minHeight: 50,
              maxHeight: contentMaxHeight,
            ),
            child: SingleChildScrollView(
              child: hasOnlyText
                  ? SelectableText(
                      plainText,
                      style: widget.textStyle ??
                          Theme.of(context).textTheme.bodyMedium,
                      maxLines: _isExpanded ? null : widget.maxLines,
                    )
                  : IgnorePointer(
                      ignoring:
                          false, // Allow all interactions including selection and links
                      child: QuillEditor(
                        controller: controller,
                        focusNode: focusNode,
                        scrollController: ScrollController(),
                      ),
                    ),
            ),
          ),
          if (widget.isExpandable)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                      child: Text(
                        _isExpanded ? 'Mostrar menos' : 'Mostrar más',
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } catch (e) {
      // If parsing fails, fall back to plain text
      return _buildFallbackContent(context);
    }
  }

  Widget _buildFallbackContent(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = widget.fallbackText ?? 'Content not available';

    return GestureDetector(
      onTap: widget.isExpandable
          ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: widget.textStyle ??
                theme.textTheme.bodyMedium ??
                const TextStyle(),
            child: Text(
              displayText,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow:
                  _isExpanded ? null : (widget.overflow ?? TextOverflow.clip),
            ),
          ),
          if (widget.isExpandable && displayText.length > 100)
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ) ??
                        const TextStyle(),
                    child: Text(
                      _isExpanded ? 'Mostrar menos' : 'Mostrar más',
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Check if the document contains only plain text without any formatting
  bool _containsOnlyPlainText(Document document) {
    // Convert document to operations and check for any formatting
    final delta = document.toDelta();
    for (final operation in delta.operations) {
      if (operation.attributes != null && operation.attributes!.isNotEmpty) {
        // Check if it has any formatting attributes other than basic ones
        final attrs = operation.attributes!;
        // Allow basic attributes but consider complex ones as formatted
        if (attrs.containsKey('link') ||
            attrs.containsKey('bold') ||
            attrs.containsKey('italic') ||
            attrs.containsKey('underline') ||
            attrs.containsKey('color') ||
            attrs.containsKey('background') ||
            attrs.containsKey('header') ||
            attrs.containsKey('list')) {
          return false; // Has formatting, use QuillEditor
        }
      }
    }
    return true; // Plain text only, can use SelectableText
  }
}
