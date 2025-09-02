import 'package:flutter/material.dart';
import '../../data/Models/RichTextContent.dart';

/// A widget that provides rich text editing capabilities
class RichTextEditorWidget extends StatefulWidget {
  final RichTextContent? initialContent;
  final Function(RichTextContent) onContentChanged;
  final String? hintText;
  final int? maxLines;
  final TextStyle? textStyle;

  const RichTextEditorWidget({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.hintText,
    this.maxLines,
    this.textStyle,
  });

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  // Rich text formatting state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  Color _selectedColor = Colors.black;
  double _selectedFontSize = 14.0;
  String _selectedFontFamily = 'Roboto';

  // Selection state
  List<RichTextSpan> _spans = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Initialize with existing content or empty
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      _spans = List.from(widget.initialContent!.spans);
      _textController = TextEditingController(text: _getPlainText());
    } else {
      _textController = TextEditingController();
      _spans = [];
    }

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getPlainText() {
    return _spans.map((span) => span.text).join();
  }

  void _onTextChanged() {
    _updateSpansFromText();
  }

  void _updateSpansFromText() {
    final text = _textController.text;
    if (text.isEmpty) {
      _spans.clear();
    } else {
      // For now, create a single span with current formatting
      // In a more advanced implementation, you'd preserve existing formatting
      _spans = [
        RichTextSpan(
          text: text,
          style: _getCurrentStyle(),
        )
      ];
    }
    _notifyContentChanged();
  }

  Map<String, dynamic> _getCurrentStyle() {
    return {
      'bold': _isBold,
      'italic': _isItalic,
      'underline': _isUnderline,
      'color': '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}',
      'fontSize': _selectedFontSize,
      'fontFamily': _selectedFontFamily,
    };
  }

  void _notifyContentChanged() {
    final content = RichTextContent(spans: _spans);
    widget.onContentChanged(content);
  }

  void _applyFormatting() {
    if (_textController.text.isEmpty) return;

    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      // Apply to all text if no selection
      _spans = [
        RichTextSpan(
          text: _textController.text,
          style: _getCurrentStyle(),
        )
      ];
    } else {
      // Apply to selected text
      final selectedText = _textController.text.substring(
        selection.start,
        selection.end,
      );

      // This is a simplified implementation
      // In practice, you'd want to split existing spans and merge styles
      _spans = [
        if (selection.start > 0)
          RichTextSpan(
            text: _textController.text.substring(0, selection.start),
            style: {},
          ),
        RichTextSpan(
          text: selectedText,
          style: _getCurrentStyle(),
        ),
        if (selection.end < _textController.text.length)
          RichTextSpan(
            text: _textController.text.substring(selection.end),
            style: {},
          ),
      ];
    }

    _notifyContentChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Formatting toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Bold button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isBold = !_isBold;
                    });
                    _applyFormatting();
                  },
                  icon: Icon(Icons.format_bold),
                  color: _isBold
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  tooltip: 'Bold',
                ),

                // Italic button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isItalic = !_isItalic;
                    });
                    _applyFormatting();
                  },
                  icon: Icon(Icons.format_italic),
                  color: _isItalic
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  tooltip: 'Italic',
                ),

                // Underline button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isUnderline = !_isUnderline;
                    });
                    _applyFormatting();
                  },
                  icon: Icon(Icons.format_underlined),
                  color: _isUnderline
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  tooltip: 'Underline',
                ),

                const VerticalDivider(width: 1),

                // Color picker
                IconButton(
                  onPressed: () => _showColorPicker(context),
                  icon: Icon(Icons.palette),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Text Color',
                ),

                // Font size selector
                PopupMenuButton<double>(
                  initialValue: _selectedFontSize,
                  onSelected: (size) {
                    setState(() {
                      _selectedFontSize = size;
                    });
                    _applyFormatting();
                  },
                  itemBuilder: (context) =>
                      [12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
                          .map((size) => PopupMenuItem(
                                value: size,
                                child: Text('${size.toInt()}pt'),
                              ))
                          .toList(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_size,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${_selectedFontSize.toInt()}'),
                      Icon(Icons.arrow_drop_down,
                          color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Text editor
        Container(
          constraints: BoxConstraints(
            minHeight: 120,
            maxHeight: widget.maxLines != null ? widget.maxLines! * 24.0 : 240,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            style: widget.textStyle ?? theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Enter your message...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        // Preview area
        if (_spans.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Preview:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: _buildPreview(theme, colorScheme),
          ),
        ],
      ],
    );
  }

  Widget _buildPreview(ThemeData theme, ColorScheme colorScheme) {
    if (_spans.isEmpty) {
      return Text(
        'No content',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final spans = _spans.map((span) {
      return TextSpan(
        text: span.text,
        style: _buildTextStyleFromSpan(span, theme, colorScheme),
      );
    }).toList();

    return RichText(
      text: TextSpan(
        children: spans,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
      ),
    );
  }

  TextStyle _buildTextStyleFromSpan(
      RichTextSpan span, ThemeData theme, ColorScheme colorScheme) {
    TextStyle baseStyle =
        widget.textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();

    // Apply bold
    if (span.style['bold'] == true) {
      baseStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    }

    // Apply italic
    if (span.style['italic'] == true) {
      baseStyle = baseStyle.copyWith(fontStyle: FontStyle.italic);
    }

    // Apply underline
    if (span.style['underline'] == true) {
      baseStyle = baseStyle.copyWith(decoration: TextDecoration.underline);
    }

    // Apply color
    if (span.style['color'] != null &&
        span.style['color'].toString().isNotEmpty) {
      final color = _parseColor(span.style['color'].toString());
      if (color != null) {
        baseStyle = baseStyle.copyWith(color: color);
      }
    }

    // Apply font size
    if (span.style['fontSize'] != null) {
      final fontSize = span.style['fontSize'];
      if (fontSize is num && fontSize > 0) {
        baseStyle = baseStyle.copyWith(fontSize: fontSize.toDouble());
      }
    }

    // Apply font family
    if (span.style['fontFamily'] != null &&
        span.style['fontFamily'].toString().isNotEmpty) {
      baseStyle =
          baseStyle.copyWith(fontFamily: span.style['fontFamily'].toString());
    }

    return baseStyle;
  }

  Color? _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        colorStr = colorStr.substring(1);
      }
      if (colorStr.length == 6) {
        colorStr = 'FF$colorStr'; // Add alpha
      }
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      return null;
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Text Color'),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _predefinedColors.length,
            itemBuilder: (context, index) {
              final color = _predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  _applyFormatting();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedColor == color
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withOpacity(0.3),
                      width: _selectedColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static final List<Color> _predefinedColors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.grey,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.cyan,
    Colors.deepPurple,
    Colors.lime,
    Colors.yellow,
  ];
}
