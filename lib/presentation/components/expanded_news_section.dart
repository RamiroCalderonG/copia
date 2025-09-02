import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/Models/Notification.dart' as NotificationModel;
import 'package:oxschool/data/services/notification_service.dart';
import 'package:oxschool/presentation/screens/news_view_screen.dart';
import 'package:oxschool/presentation/components/rich_text_display_widget.dart';

class ExpandedNewsSection extends StatefulWidget {
  const ExpandedNewsSection({super.key});

  @override
  State<ExpandedNewsSection> createState() => _ExpandedNewsSectionState();
}

class _ExpandedNewsSectionState extends State<ExpandedNewsSection> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Service is already initialized in main window, just log the current state
    print(
        'ExpandedNewsSection: Current notifications count: ${_notificationService.notifications.length}');
    print(
        'ExpandedNewsSection: Active news count: ${_notificationService.activeNews.length}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<List<NotificationModel.Notification>>(
      stream: _notificationService.notificationStream,
      builder: (context, snapshot) {
        print(
            'ExpandedNewsSection StreamBuilder: hasData=${snapshot.hasData}, connectionState=${snapshot.connectionState}');
        if (snapshot.hasData) {
          print(
              'ExpandedNewsSection StreamBuilder: snapshot data length=${snapshot.data?.length}');
        }

        final activeNews = _notificationService.activeNews;
        print(
            'ExpandedNewsSection StreamBuilder: activeNews length=${activeNews.length}');

        return Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, colorScheme, activeNews.length),
                const SizedBox(height: 16),
                if (activeNews.isEmpty)
                  Expanded(child: _buildEmptyState(theme, colorScheme))
                else
                  Expanded(
                      child: _buildNewsList(activeNews, theme, colorScheme)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, int newsCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Noticias y Avisos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Mantente informado con las últimas novedades',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: newsCount > 0
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            newsCount > 0
                ? '$newsCount noticia${newsCount != 1 ? 's' : ''}'
                : 'Sin noticias',
            style: theme.textTheme.labelSmall?.copyWith(
              color: newsCount > 0
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurfaceVariant,
          ),
          onSelected: (value) {
            switch (value) {
              case 'refresh':
                _notificationService.refresh();
                break;
              case 'view_all':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewsViewScreen(),
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                  const Text('Actualizar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'view_all',
              child: Row(
                children: [
                  Icon(Icons.open_in_new,
                      size: 20, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                  const Text('Ver todas'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
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
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las noticias y avisos importantes aparecerán aquí.\nRevisa más tarde o actualiza para ver contenido nuevo.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              print('ExpandedNewsSection: Manual refresh from empty state');
              await _notificationService.fetchNotifications();
              setState(() {}); // Force rebuild
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar noticias'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _notificationService.refresh(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<NotificationModel.Notification> news,
      ThemeData theme, ColorScheme colorScheme) {
    if (news.length == 1) {
      return _buildSingleNewsCard(news.first, theme, colorScheme);
    } else if (news.length <= 3) {
      return _buildMultipleNewsCards(news, theme, colorScheme);
    } else {
      return _buildScrollableNewsList(news, theme, colorScheme);
    }
  }

  Widget _buildSingleNewsCard(NotificationModel.Notification notification,
      ThemeData theme, ColorScheme colorScheme) {
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpiring
              ? colorScheme.error.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showNewsDetail(notification, theme, colorScheme),
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
                        color: isExpiring
                            ? colorScheme.errorContainer
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isExpiring ? Icons.warning : Icons.announcement,
                        color: isExpiring
                            ? colorScheme.onErrorContainer
                            : colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title?.toTitleCase ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isExpiring)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Urgente',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RichTextDisplayWidget(
                    richContent: notification.content,
                    fallbackText: notification.message ?? '',
                    textStyle: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Toca para ver más detalles',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
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
      ),
    );
  }

  Widget _buildMultipleNewsCards(List<NotificationModel.Notification> news,
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: news.length,
            itemBuilder: (context, index) {
              final notification = news[index];
              return _buildCompactNewsCard(
                  notification, theme, colorScheme, index < news.length - 1);
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewsViewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Ver todas las noticias'),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableNewsList(List<NotificationModel.Notification> news,
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: news.length > 5 ? 5 : news.length,
            itemBuilder: (context, index) {
              final notification = news[index];
              return _buildCompactNewsCard(
                  notification, theme, colorScheme, index < 4);
            },
          ),
        ),
        if (news.length > 5)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hay ${news.length - 5} noticias más disponibles',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewsViewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Ver todas las noticias'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNewsCard(NotificationModel.Notification notification,
      ThemeData theme, ColorScheme colorScheme, bool showDivider) {
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showNewsDetail(notification, theme, colorScheme),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isExpiring
                          ? colorScheme.errorContainer
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isExpiring ? Icons.warning : Icons.announcement,
                      color: isExpiring
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (notification.title ?? '').toTitleCase,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isExpiring)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Urgente',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onError,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichTextDisplayWidget(
                          richContent: notification.content,
                          fallbackText: notification.message!,
                          textStyle: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
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
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colorScheme.outlineVariant,
          ),
      ],
    );
  }

  void _showNewsDetail(NotificationModel.Notification notification,
      ThemeData theme, ColorScheme colorScheme) {
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          notification.title?.toTitleCase ?? '',
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
              Text(
                notification.message ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
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
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewsViewScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Ver todas'),
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
