import 'package:flutter/material.dart';
import 'package:oxschool/data/Models/Notification.dart' as NotificationModel;
import 'package:oxschool/data/services/notification_service.dart';
import 'package:oxschool/presentation/components/rich_text_display_widget.dart';

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
        title: const Text('Noticias y Avisos'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        actions: [
          IconButton(
            onPressed: () => _notificationService.refresh(),
            icon: const Icon(Icons.refresh),
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
          Icon(
            Icons.newspaper_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay noticias disponibles',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Desliza hacia abajo para actualizar',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
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
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                          ],
                        ),
                      ],
                    ),
                  ),
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
                      child: Text(
                        'Expira pronto',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ExpandableRichTextWidget(
                richContent: notification.content,
                fallbackText: notification.message,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxCollapsedHeight: 80.0,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    'Toca para ver detalles',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: colorScheme.primary,
                  ),
                ],
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
        title: Text(
          notification.title ?? '',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
              RichTextDisplayWidget(
                richContent: notification.content,
                fallbackText: notification.message,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
                isExpanded: true,
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
