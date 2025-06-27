import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

import 'complaints.dart';
import 'evaluate_dept.dart';
import 'evaluate_service.dart';
import 'improvement_project.dart';
import 'ticket_requests_dashboard/processes_services.dart';

class ServicesTicketHistory extends StatefulWidget {
  const ServicesTicketHistory({super.key});

  @override
  State<ServicesTicketHistory> createState() => _ServicesTicketHistoryState();
}

class _ServicesTicketHistoryState extends State<ServicesTicketHistory>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Servicios y Tickets',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              floating: true,
              snap: true,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTabBar(theme, colorScheme),
                  _buildTabBarView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.labelMedium,
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorPadding: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(2),
          tabs: [
            _buildTab(
              Icons.assignment_rounded,
              'Tickets',
              'Estado de tickets',
            ),
            _buildTab(
              Icons.analytics_rounded,
              'Evaluación',
              'Departamentos',
            ),
            _buildTab(
              Icons.rate_review_rounded,
              'Evaluar',
              'Servicios',
            ),
            _buildTab(
              Icons.feedback_rounded,
              'Quejas',
              'Reportes',
            ),
            _buildTab(
              Icons.trending_up_rounded,
              'Mejoras',
              'Proyectos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String title, String subtitle) {
    return Tab(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.8, // Increased height for more content space
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: TabBarView(
            controller: _tabController,
            children: const [
              Processes(),
              EvaluateDept(),
              EvaluateServices(),
              Complaints(),
              ImprovementProject(),
            ],
          ),
        ),
      ),
    );
  }
}
