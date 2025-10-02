import 'dart:async';
import 'dart:convert';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Notification.dart' as NotificationModel;
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel.Notification> _notifications = [];
  final StreamController<List<NotificationModel.Notification>>
      _notificationController =
      StreamController<List<NotificationModel.Notification>>.broadcast();

  Timer? _fetchTimer;
  bool _isInitialized = false;

  // Stream to listen for notification updates
  Stream<List<NotificationModel.Notification>> get notificationStream =>
      _notificationController.stream;

  // Get current notifications
  List<NotificationModel.Notification> get notifications =>
      List.unmodifiable(_notifications);

  // Get active news (non-expired notifications)
  List<NotificationModel.Notification> get activeNews {
    final now = DateTime.now();
    return _notifications.where((notification) {
      // Check if notification is active
      if (!(notification.isActive ?? false)) return false;

      // Check if notification has expired
      if ((notification.expires ?? false) &&
          notification.expirationDate != null) {
        final expirationDate = DateTime.tryParse(notification.expirationDate!);
        if (expirationDate == null) return false;

        // Include notifications that expire today or later
        final expirationDateOnly = DateTime(
            expirationDate.year, expirationDate.month, expirationDate.day);
        final todayOnly = DateTime(now.year, now.month, now.day);
        return expirationDateOnly.isAfter(todayOnly) ||
            expirationDateOnly.isAtSameMomentAs(todayOnly);
      }

      return true;
    }).toList();
  }

  /// Initialize the notification service and start auto-fetching
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    await fetchNotifications();
    _startAutoFetch();

    insertActionIntoLog('NotificationService initialized', 'SYSTEM');
  }

  /// Fetch notifications from the server
  Future<void> fetchNotifications() async {
    try {
      // print('NotificationService: Starting to fetch notifications...');
      final response = await getActiveNotifications();
      // print('NotificationService: Received response: $response');

      if (response != null) {
        _notifications.clear();

        // Parse the response based on its type
        List<dynamic> notificationData;
        if (response is String) {
          notificationData = json.decode(response);
        } else if (response is List) {
          notificationData = response;
        } else if (response is Map && response.containsKey('data')) {
          notificationData = response['data'];
        } else {
          notificationData = [response];
        }

        // print(
        //     'NotificationService: Parsed notification data: $notificationData');

        // Convert to Notification objects
        for (final item in notificationData) {
          try {
            final notification = NotificationModel.Notification.fromJson(item);
            _notifications.add(notification);
            // print(
            //     'NotificationService: Added notification: ${notification.title}');
          } catch (e) {
            print('NotificationService: Error parsing notification: $e');
            insertErrorLog(
                e.toString(), 'Parse notification: ${item.toString()}');
          }
        }

        // Sort notifications by priority first, then by creation date (newest first)
        // Using the new sorting method from Notification model
        _notifications.sort((a, b) => a.compareTo(b));

        // print(
        //     'NotificationService: Total notifications: ${_notifications.length}');
        // print('NotificationService: Active news: ${activeNews.length}');

        // Notify listeners
        _notificationController.add(_notifications);

        insertActionIntoLog('Fetched ${_notifications.length} notifications',
            'NotificationService');
      } else {
        print('NotificationService: Response was null');
      }
    } catch (e) {
      print('NotificationService: Error fetching notifications: $e');
      insertErrorLog(e.toString(), 'NotificationService.fetchNotifications()');
    }
  }

  /// Start auto-fetching notifications every 5 minutes
  void _startAutoFetch() {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(const Duration(minutes: 120), (timer) {
      fetchNotifications();
    });
  }

  /// Stop auto-fetching
  void stopAutoFetch() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
  }

  /// Refresh notifications manually
  Future<void> refresh() async {
    await fetchNotifications();
  }

  /// Mark a notification as read (if needed for future implementation)
  void markAsRead(String notificationId) {
    // Implementation for marking as read can be added later
    insertActionIntoLog('Notification marked as read: $notificationId', 'USER');
  }

  /// Get notifications count
  int get notificationCount => _notifications.length;

  /// Get active news count
  int get activeNewsCount => activeNews.length;

  /// Dispose resources
  void dispose() {
    _fetchTimer?.cancel();
    _notificationController.close();
    _isInitialized = false;
  }
}
