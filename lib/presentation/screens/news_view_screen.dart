import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/Models/Notification.dart' as NotificationModel;
import 'package:oxschool/data/services/notification_service.dart';
import 'package:oxschool/presentation/components/quill_content_viewer.dart';

class NewsViewScreen extends StatefulWidget {
  const NewsViewScreen({super.key});

  @override
  State<NewsViewScreen> createState() => _NewsViewScreenState();
}

class _NewsViewScreenState extends State<NewsViewScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Noticias y Avisos',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _notificationService.refresh(),
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Actualizar noticias',
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel.Notification>>(
        stream: _notificationService.notificationStream,
        builder: (context, snapshot) {
          final activeNews = _notificationService.activeNews;

          if (activeNews.isEmpty) {
            return _buildEmptyState(colorScheme);
          }

          return RefreshIndicator(
            onRefresh: () => _notificationService.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeNews.length,
              itemBuilder: (context, index) {
                final notification = activeNews[index];
                return _buildNewsCard(notification, theme, colorScheme, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay noticias disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo para actualizar',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _notificationService.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar ahora'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(
    NotificationModel.Notification notification,
    ThemeData theme,
    ColorScheme colorScheme,
    int index,
  ) {
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);
    final isHighPriority = (notification.priority ?? 1) >= 2; // HIGH or URGENT

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpiring
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showNewsDetail(notification),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: notification.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      notification.typeIcon,
                      color: notification.typeColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isHighPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: notification.priorityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            notification.priorityIcon,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.priorityLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              QuillContentViewer(
                quillDeltaJson: notification.content,
                fallbackText: notification.message ?? '',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (isExpiring)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            color: colorScheme.onErrorContainer,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expira pronto',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if ((notification.expires ?? false) &&
                  notification.expirationDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isExpiring
                          ? colorScheme.errorContainer.withOpacity(0.5)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: isExpiring
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expira: ${notification.formattedExpirationDate}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isExpiring
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewsDetail(NotificationModel.Notification notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title?.toTitleCase ?? '',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/1_OS_color.png',
              height: 24,
              fit: BoxFit.contain,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Publicado $timeAgo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              QuillContentViewer(
                quillDeltaJson: notification.content,
                fallbackText: notification.message ?? '',
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),
              if ((notification.expires ?? false) &&
                  notification.expirationDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isExpiring
                          ? colorScheme.errorContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isExpiring ? Icons.warning : Icons.schedule,
                          size: 16,
                          color: isExpiring
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isExpiring
                                ? '⚠️ Este aviso expira pronto: ${notification.formattedExpirationDate}'
                                : 'Válido hasta: ${notification.formattedExpirationDate}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isExpiring
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays != 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours != 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''}';
    } else {
      return 'ahora';
    }
  }

  bool _isExpiringSoon(NotificationModel.Notification notification) {
    return notification.expiresSoon;
  }
}
