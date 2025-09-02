import 'package:flutter/material.dart';

class Notification {
  int? id;
  String? title;
  String? message;
  String? creationDate;
  int? createdBy;
  bool? isActive;
  bool? expires;
  String? expirationDate;
  String? content; // Quill Delta JSON string
  int? priority;
  int? type;

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
    this.priority,
    this.type,
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
      content:
          json['content']?.toString(), // Store as string (Quill Delta JSON)
      priority: json['priority'],
      type: json['type'],
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

  // Priority utility methods
  String get priorityLabel {
    switch (priority) {
      case 0:
        return 'LOW';
      case 1:
        return 'NORMAL';
      case 2:
        return 'HIGH';
      case 3:
        return 'URGENT';
      default:
        return 'NORMAL';
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case 0: // LOW
        return Icons.keyboard_arrow_down;
      case 1: // NORMAL
        return Icons.remove;
      case 2: // HIGH
        return Icons.keyboard_arrow_up;
      case 3: // URGENT
        return Icons.warning;
      default:
        return Icons.remove;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 0: // LOW
        return Colors.green;
      case 1: // NORMAL
        return Colors.blue;
      case 2: // HIGH
        return Colors.orange;
      case 3: // URGENT
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Type utility methods
  String get typeLabel {
    switch (type) {
      case 1:
        return 'ANUNCIO';
      case 2:
        return 'ALERTA';
      case 3:
        return 'INFO';
      case 4:
        return 'ADVERTENCIA';
      default:
        return 'ANUNCIO';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 1: // ANUNCIO
        return Icons.announcement;
      case 2: // ALERTA
        return Icons.warning_amber;
      case 3: // INFO
        return Icons.info;
      case 4: // ADVERTENCIA
        return Icons.error_outline;
      default:
        return Icons.announcement;
    }
  }

  Color get typeColor {
    switch (type) {
      case 1: // ANUNCIO
        return Colors.blue;
      case 2: // ALERTA
        return Colors.orange;
      case 3: // INFO
        return Colors.teal;
      case 4: // ADVERTENCIA
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Priority comparison for sorting
  // Higher priority numbers should come first (URGENT = 3, HIGH = 2, etc.)
  int comparePriority(Notification other) {
    final thisPriority = priority ?? 1;
    final otherPriority = other.priority ?? 1;
    return otherPriority
        .compareTo(thisPriority); // Reverse for descending order
  }

  // Complete comparison for sorting: priority first, then creation date
  int compareTo(Notification other) {
    // First compare by priority (higher priority first)
    final priorityComparison = comparePriority(other);
    if (priorityComparison != 0) return priorityComparison;

    // If priorities are equal, compare by creation date (newer first)
    final thisDate = creationDateTime ?? DateTime.now();
    final otherDate = other.creationDateTime ?? DateTime.now();
    return otherDate.compareTo(thisDate);
  }

  // Static method to sort a list of notifications by priority and date
  static List<Notification> sortByPriority(List<Notification> notifications) {
    final sortedList = List<Notification>.from(notifications);
    sortedList.sort((a, b) => a.compareTo(b));
    return sortedList;
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
      'content': content, // Already a string (Quill Delta JSON)
    };
  }
}
