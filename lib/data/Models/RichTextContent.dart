class RichTextContent {
  List<RichTextSpan> spans;

  RichTextContent({
    List<RichTextSpan>? spans,
  }) : spans = spans ?? [];

  factory RichTextContent.fromJson(Map<String, dynamic> json) {
    return RichTextContent(
      spans: json['spans'] != null
          ? (json['spans'] as List)
              .map((span) => RichTextSpan.fromJson(span))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spans': spans.map((span) => span.toJson()).toList(),
    };
  }

  /// Add a span with text and style
  void addSpan(String text, Map<String, dynamic> style) {
    spans.add(RichTextSpan(text: text, style: style));
  }

  /// Add plain text without any styling
  void addPlainText(String text) {
    spans.add(RichTextSpan(text: text, style: {}));
  }

  /// Get the text content as plain text (concatenating all spans)
  String get textContent {
    return spans.map((span) => span.text ?? '').join();
  }

  /// Check if this content has rich formatting
  bool get hasRichContent {
    return spans.any((span) => span.style.isNotEmpty);
  }

  /// Check if the content is empty
  bool get isEmpty {
    return spans.isEmpty ||
        spans.every((span) => (span.text ?? '').trim().isEmpty);
  }

  /// Check if the content is not empty
  bool get isNotEmpty {
    return !isEmpty;
  }
}

class RichTextSpan {
  String? text;
  Map<String, dynamic> style;

  RichTextSpan({
    this.text,
    Map<String, dynamic>? style,
  }) : style = style ?? {};

  factory RichTextSpan.fromJson(Map<String, dynamic> json) {
    return RichTextSpan(
      text: json['text'],
      style:
          json['style'] != null ? Map<String, dynamic>.from(json['style']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'style': style,
    };
  }

  /// Check if this span has any styling
  bool get hasStyle {
    return style.isNotEmpty;
  }

  /// Check if this span is bold
  bool get isBold {
    return style['bold'] == true || style['fontWeight'] == 'bold';
  }

  /// Check if this span is italic
  bool get isItalic {
    return style['italic'] == true || style['fontStyle'] == 'italic';
  }

  /// Check if this span is underlined
  bool get isUnderlined {
    return style['underline'] == true || style['textDecoration'] == 'underline';
  }

  /// Get the color of this span
  String? get color {
    return style['color']?.toString();
  }

  /// Get the font size of this span
  double? get fontSize {
    final size = style['fontSize'];
    if (size is num) {
      return size.toDouble();
    }
    if (size is String) {
      return double.tryParse(size);
    }
    return null;
  }

  /// Get the font family of this span
  String? get fontFamily {
    return style['fontFamily']?.toString();
  }
}
