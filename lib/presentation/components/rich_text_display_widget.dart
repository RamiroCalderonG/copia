import 'package:flutter/material.dart';
import '../../data/Models/RichTextContent.dart';

/// A widget that displays rich text content using spans
class RichTextDisplayWidget extends StatelessWidget {
  final RichTextContent? richContent;
  final String? fallbackText;
  final TextStyle? textStyle;
  final double? maxHeight;
  final bool isExpanded;
  final int? maxLines;
  final TextOverflow? overflow;

  const RichTextDisplayWidget({
    super.key,
    this.richContent,
    this.fallbackText,
    this.textStyle,
    this.maxHeight,
    this.isExpanded = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If we have rich content, display it
    if (richContent?.isNotEmpty == true) {
      return _buildSpanContent(theme, colorScheme);
    }

    // Otherwise, use fallback text
    return _buildFallbackContent(theme);
  }

  Widget _buildSpanContent(ThemeData theme, ColorScheme colorScheme) {
    if (richContent!.spans.isEmpty) {
      return _buildFallbackContent(theme);
    }

    final spans = richContent!.spans.map((span) {
      return TextSpan(
        text: span.text,
        style: _buildTextStyleFromSpan(span, theme, colorScheme),
      );
    }).toList();

    Widget richTextWidget = RichText(
      text: TextSpan(
        children: spans,
        style: textStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
      ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );

    if (maxHeight != null && !isExpanded) {
      return Container(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(
          child: richTextWidget,
        ),
      );
    }

    return richTextWidget;
  }

  TextStyle _buildTextStyleFromSpan(
      RichTextSpan span, ThemeData theme, ColorScheme colorScheme) {
    TextStyle baseStyle =
        textStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();

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

  Color? _parseColor(String colorString) {
    try {
      // Remove # if present
      String cleanColor = colorString.replaceAll('#', '');

      // Parse hex color
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      } else if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }
    } catch (e) {
      // Ignore color parsing errors
    }
    return null;
  }

  Widget _buildFallbackContent(ThemeData theme) {
    final text = fallbackText ?? '';
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget textWidget = Text(
      text,
      style: textStyle ??
          theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );

    if (maxHeight != null && !isExpanded) {
      return Container(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: SingleChildScrollView(
          child: textWidget,
        ),
      );
    }

    return textWidget;
  }
}

/// A widget that displays rich text with an expand/collapse functionality
class ExpandableRichTextWidget extends StatefulWidget {
  final RichTextContent? richContent;
  final String? fallbackText;
  final TextStyle? textStyle;
  final double maxCollapsedHeight;
  final String expandText;
  final String collapseText;

  const ExpandableRichTextWidget({
    super.key,
    this.richContent,
    this.fallbackText,
    this.textStyle,
    this.maxCollapsedHeight = 100.0,
    this.expandText = 'Ver más',
    this.collapseText = 'Ver menos',
  });

  @override
  State<ExpandableRichTextWidget> createState() =>
      _ExpandableRichTextWidgetState();
}

class _ExpandableRichTextWidgetState extends State<ExpandableRichTextWidget> {
  bool _isExpanded = false;
  bool _needsExpansion = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // First, build the content to check if it needs expansion
            final content = RichTextDisplayWidget(
              richContent: widget.richContent,
              fallbackText: widget.fallbackText,
              textStyle: widget.textStyle,
              maxHeight: _isExpanded ? null : widget.maxCollapsedHeight,
              isExpanded: _isExpanded,
            );

            // Use a simple check - if we have content that might overflow
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_needsExpansion && mounted) {
                setState(() {
                  _needsExpansion = _hasSignificantContent();
                });
              }
            });

            return content;
          },
        ),
        if (_needsExpansion) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? widget.collapseText : widget.expandText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _hasSignificantContent() {
    if (widget.richContent?.isNotEmpty == true) {
      final textContent = widget.richContent!.textContent;
      return textContent.length > 200; // Rough estimate
    }

    if (widget.fallbackText != null) {
      return widget.fallbackText!.length > 200;
    }

    return false;
  }
}
