// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_super_parameters, avoid_function_literals_in_foreach_calls

import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/user_consts.dart';

import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/core/utils/device_information.dart';
import 'package:oxschool/core/utils/temp_data.dart';
import 'package:oxschool/data/services/backend/validate_user_permissions.dart';
import 'package:oxschool/data/services/notification_service.dart';
import 'package:oxschool/presentation/Modules/user/user_view_screen.dart';
import 'package:oxschool/presentation/Modules/admin/create_notification.dart';
import 'package:get/get.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:oxschool/presentation/components/expanded_news_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/reusable_methods/logger_actions.dart';
import '../services_ticket/processes/create_service_ticket.dart';
import '../../../core/constants/screens.dart';
import '../../components/quality_dialogs.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class MainWindowWidget extends StatefulWidget {
  const MainWindowWidget({super.key});

  @override
  _MainWindowWidgetState createState() => _MainWindowWidgetState();
}

// var _selectedPageIndex = 0;
// late PageController _pageController;

class _MainWindowWidgetState extends State<MainWindowWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isHovered = false;

  //late MainWindowModel _model;

  @override
  void dispose() {
    //_model.dispose();
    currentUser?.clear();
    eventsList?.clear();
    deviceData.clear();

    // Stop notification service
    NotificationService().stopAutoFetch();

    // clearUserData();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //_model = createModel(context, () => MainWindowModel());
    saveUserRoleToSharedPref();

    // Initialize notification service for auto-fetching news
    NotificationService().initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    insertAlertLog('USER LOGED IN: ${currentUser!.employeeNumber.toString()}');
  }

  void saveUserRoleToSharedPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var isUserAdmin = verifyUserAdmin(currentUser!); //Retrives user role

    await prefs.setBool('isUserAdmin', isUserAdmin);
    currentUser!.userRole!.roleModuleRelationships =
        await fetchEventsByRole(currentUser!.userRole!.roleID);
  }

  final ExpansionTileController controller =
      ExpansionTileController(); //Controller for ExpansionTile

  @override
  Widget build(BuildContext context) {
    Get.put(Controller());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: colorScheme.surface,
        drawer: _createDrawer(context),
        // floatingActionButton: _buildAdminFAB(context),
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
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, _) => [
              _buildAppHeader(context),
            ],
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildWelcomeSection(theme, colorScheme),
                          const SizedBox(height: 16),
                          Flexible(
                            flex: 3,
                            child: const ExpandedNewsSection(),
                          ),
                          const SizedBox(height: 16),
                          _buildFooterText(context),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, ColorScheme colorScheme) {
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
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.secondaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentUser?.employeeName?.trimRight().capitalize}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserWindow(),
                    ));
                  },
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('Mi Perfil'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No. de empleado: ${currentUser?.employeeNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      automaticallyImplyLeading: false,
      toolbarHeight: 80.0,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return constraints.maxWidth < 600
              ? _buildSmallScreenAppBar(context)
              : _buildLargeScreenAppBar(context);
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
                onPressed: () async {
                  scaffoldKey.currentState!.openDrawer();
                },
                tooltip: 'Menú de navegación',
              ),
            ),
            title: Row(
              children: [
                // Icon(
                //   Icons.dashboard_outlined,
                //   color: colorScheme.primary,
                //   size: 20,
                // ),
                // const SizedBox(width: 8),
                // Text(
                //   'Página Principal',
                //   style: theme.textTheme.titleMedium?.copyWith(
                //     fontWeight: FontWeight.w600,
                //     color: colorScheme.onSurface,
                //   ),
                // ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: () {
                    bool? isEnabled =
                        canRoleConsumeEvent("Crear ticket de servicio");
                    if (isEnabled != null && isEnabled == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateServiceTicket(),
                        ),
                      );
                    } else {
                      showInformationDialog(context, 'Error',
                          'No cuenta con permisos, consulte con el administrador');
                    }
                  },
                  icon: const Icon(Icons.support_agent, size: 18),
                  label: const Text('Crear Ticket de servicio'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallScreenAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              getLogoAssetPath(context),
              height: 32,
              filterQuality: FilterQuality.high,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${currentUser?.employeeName?.trimRight().capitalize}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  getLogoAssetPath(context),
                  height: 40,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   'Ox School',
                    //   style: theme.textTheme.titleMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //     color: colorScheme.primary,
                    //   ),
                    // ),
                    // Text(
                    //   'ERP Ox School',
                    //   style: theme.textTheme.bodySmall?.copyWith(
                    //     color: colorScheme.onSurfaceVariant,
                    //   ),
                    // ),
                  ],
                ),
                // const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Disciplina, Moralidad, Trabajo y Eficiencia',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return const SizedBox
        .shrink(); // Empty widget since we moved the text to app bar
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return constraints.maxWidth < 600
              ? _buildSmallScreenBottomBar(context)
              : _buildLargeScreenBottomBar(context);
        },
      ),
    );
  }

  Widget _buildSmallScreenBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildBottomBarButton(
              context,
              'Misión',
              Icons.flag_outlined,
              () => showMision(context),
            ),
            const SizedBox(width: 8),
            _buildBottomBarButton(
              context,
              'Visión',
              Icons.visibility_outlined,
              () => showVision(context),
            ),
            const SizedBox(width: 8),
            _buildBottomBarButton(
              context,
              'Política de Calidad',
              Icons.verified_outlined,
              () => qualityPolitic(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildBottomBarButton(
              context,
              'Misión',
              Icons.flag_outlined,
              () => showMision(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBottomBarButton(
              context,
              'Visión',
              Icons.visibility_outlined,
              () => showVision(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBottomBarButton(
              context,
              'Política de Calidad',
              Icons.verified_outlined,
              () => qualityPolitic(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  // Widget? _buildAdminFAB(BuildContext context) {
  //   // Check if user is admin
  //   final isAdmin = verifyUserAdmin(currentUser!);
  //   if (!isAdmin) return null;

  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;

  //   return FloatingActionButton.extended(
  //     onPressed: () async {
  //       final result = await Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => const CreateNotificationScreen(),
  //         ),
  //       );

  //       // If notification was created successfully, refresh the notifications
  //       if (result == true) {
  //         NotificationService().fetchNotifications();
  //       }
  //     },
  //     backgroundColor: colorScheme.primary,
  //     foregroundColor: colorScheme.onPrimary,
  //     elevation: 4,
  //     icon: const Icon(Icons.add_alert),
  //     label: const Text('Create Notification'),
  //     tooltip: 'Create a new notification',
  //   );
  // }

  Widget _createDrawer(BuildContext context) {
    final controller = ScrollController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 1,
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: <Widget>[
            // Modern Header
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.secondaryContainer.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_circle,
                          color: colorScheme.onPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser!.employeeName!.toTitleCase,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ID: ${currentUser!.employeeNumber}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MyExpansionTileList(),
            ),

            const SizedBox(height: 16),

            // Logout Section
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                  'Cerrar sesión',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: colorScheme.error,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.error,
                ),
                onTap: () async {
                  insertActionIntoLog('User logged out',
                      currentUser!.employeeNumber.toString());
                  logOutCurrentUser(currentUser!).whenComplete(() async {});
                  context.goNamed(
                    '_initialize',
                    extra: <String, dynamic>{
                      kTransitionInfoKey: const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.leftToRight,
                      ),
                    },
                  );
                  clearUserData();
                  clearTempData();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Material3HoverCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;
  final int index;

  const Material3HoverCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap,
    required this.index,
  });

  @override
  _Material3HoverCardState createState() => _Material3HoverCardState();
}

class _Material3HoverCardState extends State<Material3HoverCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCardColor(int index, ColorScheme colorScheme) {
    final colors = [
      const Color.fromRGBO(23, 76, 147, 1),
      const Color.fromRGBO(246, 146, 51, 1),
      const Color.fromRGBO(235, 48, 69, 1),
      // colorScheme.primaryContainer,
      // // colorScheme.secondaryContainer,
      // colorScheme.tertiaryContainer,
      // colorScheme.surfaceContainerHighest,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = _getCardColor(widget.index, colorScheme);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: _elevationAnimation.value,
                color: cardColor,
                surfaceTintColor: colorScheme.surfaceTint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isHovered
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.outlineVariant,
                    width: isHovered ? 2 : 1,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? colorScheme.primary
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isHovered
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _getIconForService(widget.title),
                          size: 40,
                          color: isHovered
                              ? colorScheme.onSurface
                              : colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Title text
                      Flexible(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isHovered
                                ? FlutterFlowTheme.of(context).info
                                : FlutterFlowTheme.of(context)
                                    .hoverCardTextColor,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Hover indicator (only show if there's space)
                      if (isHovered) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Abrir',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForService(String title) {
    switch (title.toLowerCase()) {
      case 'calificaciones':
        return Icons.grade_outlined;
      case 'calendario':
        return Icons.calendar_today_outlined;
      case 'aula virtual':
        return Icons.wb_cloudy_outlined;
      case 'noticias':
        return Icons.newspaper_outlined;
      case 'cafetería':
        return Icons.restaurant_outlined;
      case 'instalaciones':
        return Icons.location_city_outlined;
      case 'ox school':
        return Icons.school_outlined;
      case 'ox high school':
        return Icons.school_outlined;
      default:
        return Icons.apps_outlined;
    }
  }
}

class MyExpansionTileList extends StatefulWidget {
  // BuildContext context;
  //final List<dynamic> elementList;
  //final List<String> modulesList;

  const MyExpansionTileList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DrawerState();
}

class Controller extends GetxController {
  var title = "Dashboard".obs;
}

class _DrawerState extends State<MyExpansionTileList> {
  final Controller c = Get.find();

  List<Widget> _getChildren() {
    List<Widget> children = [];

    // Iterate through uniqueItems to create ExpansionTiles
    uniqueItems.forEach((moduleMap) {
      String moduleName = moduleMap.keys.first;
      List<String> screens = moduleMap[moduleName]!;

      List<Widget> screensMenuChildren = [];

      // Create ListTile for each screen
      screens.forEach((screen) {
        screensMenuChildren.add(
          ListTile(
            title: Text(
              screen,
              style: const TextStyle(fontFamily: 'Sora', fontSize: 15),
            ),
            trailing: Icon(
              Icons.arrow_right_sharp,
              size: 15,
            ),
            onTap: () {
              // Find the appropriate route from accessRoutes
              var route = accessRoutes.firstWhere(
                (element) => element.containsKey(screen),
                orElse: () => {},
              );

              if (route.isNotEmpty) {
                context.pushNamed(
                  route[screen]!,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                    ),
                  },
                );
              }
            },
          ),
        );
      });

      // Create ExpansionTile for the current module
      children.add(
        ExpansionTile(
          title: Text(
            moduleName,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[moduleName],
          children: screensMenuChildren,
        ),
      );
    });

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getChildren(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}


/*

class _DrawerState extends State<MyExpansionTileList> {
  final Controller c = Get.find();
  List<Widget> _getChildren() {
    List<Widget> children = [];
    List<Widget> screensMenuChildren = [];

//TODO: CONTINUE HERE!!
    currentUser!.userRole!.moduleScreenList!.forEach((module) {
      currentUser!.userRole!.screenEventList!.forEach((screen) {
      screensMenuChildren.add(ListTile(
        title: Text(screen.entries.first.key, style: const TextStyle(fontFamily: 'Sora', fontSize: 15), ),
         onTap: () {
          //String? route = accessRoutes[screen];
          Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => accessRoutes as Widget));
      }
      ),
     
      );
    });
      children.add(
        ExpansionTile(
          title: Text(
            module.entries.first.key, 
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[module],
          children: screensMenuChildren,
          
        ),
      );
      
    },);
    
/* 
    // Iterate over modulesMap to create ExpansionTiles for each module
    modulesList.forEach((module) {
      
      screens.forEach((screen) {
        screensMenuChildren.add(ListTile(
          title: Text(
            screen,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 15),
          ),
          onTap: () {
            String moduleKey = screen;
            // ignore: unused_local_variable
            String? moduleValue;

            modulesMapped.forEach((k, v) {
              if (k == moduleKey) {
                moduleValue = v;
              }
            });
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => pageRoutes[screen]));

            // print('Selected screen: $screen');
          },
          leading: const Icon(
            Icons.arrow_right_sharp,
            size: 10,
          ),
        ));
      });

      children.add(
        ExpansionTile(
          title: Text(
            module,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 18),
          ),
          leading: moduleIcons[module],
          children: screensMenuChildren,
        ),
      );
    }); */

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _getChildren(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

*/