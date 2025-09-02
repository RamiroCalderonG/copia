import 'RichTextContent.dart';

class Notification {
  int? id;
  String? title;
  String? message;
  String? creationDate;
  int? createdBy;
  bool? isActive;
  bool? expires;
  String? expirationDate;
  RichTextContent? content;

  Notification({
    this.id,
    this.title,
    this.message,
    this.creationDate,
    this.createdBy,
    this.isActive,
    this.expires,
    this.expirationDate,
    this.content,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['header'],
      message: json['body'],
      creationDate: json['creationDate']?.toString(),
      createdBy: json['created_by'],
      isActive: json['active'],
      expires: json['expires'],
      expirationDate: json['expiration_date']?.toString(),
      content: json['content'] != null
          ? RichTextContent.fromJson(json['content'])
          : null,
    );
  }

  // Helper method to parse string date to DateTime for comparisons
  DateTime? _parseStringDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date string: $dateString - $e');
      return null;
    }
  }

  // Utility method to get creation date as DateTime for calculations
  DateTime? get creationDateTime => _parseStringDate(creationDate);

  // Utility method to get expiration date as DateTime for calculations
  DateTime? get expirationDateTime => _parseStringDate(expirationDate);

  // Utility method to format date as "2025-09-01" (returns the string as is if already in correct format)
  String? get formattedCreationDate {
    if (creationDate == null) return null;

    // If it's already in YYYY-MM-DD format, return as is
    if (creationDate!.length == 10 && creationDate!.contains('-')) {
      return creationDate;
    }

    // Try to parse and reformat
    final dateTime = _parseStringDate(creationDate);
    if (dateTime == null) return creationDate;

    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Utility method to format expiration date as "2025-09-01"
  String? get formattedExpirationDate {
    if (expirationDate == null) return null;

    // If it's already in YYYY-MM-DD format, return as is
    if (expirationDate!.length == 10 && expirationDate!.contains('-')) {
      return expirationDate;
    }

    // Try to parse and reformat
    final dateTime = _parseStringDate(expirationDate);
    if (dateTime == null) return expirationDate;

    return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Check if notification is expired
  bool get isExpired {
    if (!(expires ?? false) || expirationDate == null) return false;

    final expDateTime = _parseStringDate(expirationDate);
    if (expDateTime == null) return false;

    return DateTime.now().isAfter(expDateTime);
  }

  // Check if notification expires soon (within 2 days)
  bool get expiresSoon {
    if (!(expires ?? false) || expirationDate == null) return false;

    final expDateTime = _parseStringDate(expirationDate);
    if (expDateTime == null) return false;

    final now = DateTime.now();
    final daysUntilExpiration = expDateTime.difference(now).inDays;
    return daysUntilExpiration <= 2 && daysUntilExpiration >= 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Header': title,
      'body': message,
      'creation_date': creationDate,
      'created_by': createdBy,
      'is_active': isActive,
      'expires': expires,
      'expiration_date': expirationDate,
      'content': content?.toJson(),
    };
  }
}
