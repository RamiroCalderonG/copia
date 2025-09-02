import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/data/Models/Notification.dart' as NotificationModel;
import 'package:oxschool/data/services/notification_service.dart';
import 'package:oxschool/presentation/screens/news_view_screen.dart';
import 'package:oxschool/presentation/components/quill_content_viewer.dart';

class NewsWidget extends StatefulWidget {
  const NewsWidget({super.key});

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  final NotificationService _notificationService = NotificationService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<List<NotificationModel.Notification>>(
      stream: _notificationService.notificationStream,
      builder: (context, snapshot) {
        final activeNews = _notificationService.activeNews;

        if (activeNews.isEmpty) {
          return _buildEmptyState(theme, colorScheme);
        }

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
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, colorScheme, activeNews.length),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildNewsCarousel(activeNews, theme, colorScheme),
                ),
                if (activeNews.length > 1)
                  _buildPageIndicator(activeNews.length, colorScheme),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.newspaper_outlined,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Noticias y Avisos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$newsCount noticia${newsCount != 1 ? 's' : ''}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NewsViewScreen(),
              ),
            );
          },
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Ver todas'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _notificationService.refresh(),
          icon: Icon(
            Icons.refresh,
            color: colorScheme.primary,
            size: 20,
          ),
          tooltip: 'Actualizar noticias',
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(32, 32),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
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
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper_outlined,
              color: colorScheme.outline,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay noticias disponibles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => _notificationService.refresh(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Actualizar'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCarousel(List<NotificationModel.Notification> news,
      ThemeData theme, ColorScheme colorScheme) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: news.length,
      itemBuilder: (context, index) {
        final notification = news[index];
        return _buildNewsCard(notification, theme, colorScheme);
      },
    );
  }

  Widget _buildNewsCard(NotificationModel.Notification notification,
      ThemeData theme, ColorScheme colorScheme) {
    final timeAgo =
        _getTimeAgo(notification.creationDateTime ?? DateTime.now());
    final isExpiring = _isExpiringSoon(notification);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showNewsDetail(notification, theme, colorScheme),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpiring
                    ? colorScheme.error.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title?.toTitleCase ?? '',
                        style: theme.textTheme.titleSmall?.copyWith(
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Expira pronto',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: QuillContentViewer(
                    quillDeltaJson: notification.content,
                    fallbackText: notification.message ?? '',
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    isExpandable: false,
                  ),
                ),
                const SizedBox(height: 8),
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
                    Icon(
                      Icons.touch_app,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Toca para detalles',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                if ((notification.expires ?? false) &&
                    notification.expirationDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Expira: ${notification.formattedExpirationDate}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isExpiring
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int itemCount, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          itemCount,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ),
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

  void _showNewsDetail(NotificationModel.Notification notification,
      ThemeData theme, ColorScheme colorScheme) {
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
                isExpandable: true,
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
            label: const Text('Ver todas las noticias'),
          ),
        ],
      ),
    );
  }
}
