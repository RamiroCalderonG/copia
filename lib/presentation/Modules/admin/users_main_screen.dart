// ignore_for_file: prefer_typing_uninitialized_variables


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';

import 'package:oxschool/core/reusable_methods/device_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/data/Models/Role.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/presentation/Modules/user/create_user.dart';
import 'package:oxschool/presentation/Modules/user/roles_screen.dart';
import 'package:oxschool/presentation/Modules/admin/users_table_view.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/reusable_functions.dart';
import 'package:oxschool/data/datasources/temp/users_temp_data.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import '../../../data/services/backend/api_requests/api_calls_list_dio.dart';
import '../../../core/reusable_methods/temp_data_functions.dart';
import '../../../core/reusable_methods/user_functions.dart';

class UsersMainScreen extends StatefulWidget {
  const UsersMainScreen({super.key});

  @override
  State<UsersMainScreen> createState() => _UsersMainScreenState();
}

class _UsersMainScreenState extends State<UsersMainScreen> {
  bool isUserAdmin = verifyUserAdmin(currentUser!);
  bool confirmation = false;
  Key _key = UniqueKey();
  late Future<dynamic> loadingCOntroller;
  bool isLoading = true;
  bool isDeviceMobile = false;

  void _restartScreen() async {
    _key = UniqueKey();
    loadingCOntroller = refreshButton();
    //await refreshButton();
    // setState(() {
    //   refreshButton();
    // });
  }

  Future<dynamic> refreshButton() async {
    isDeviceMobile = await isCurrentDeviceMobile();
    setState(() {
      isLoading = true;
      listOfUsersForGrid.clear();
      userRows.clear();
    });
    try {
      await getUsers().then((response) {
        if (response != null) {
          List<dynamic> jsonList = response.data; //json.decode(response);
          setState(() {
            usersTrinaRowList = userRows;
            for (var item in jsonList) {
              User newUser = User.usersSimplifiedList(item);
              listOfUsersForGrid.add(newUser);
            }
          });
          return response;
          // listOfUsersForGrid = parseUsersFromJSON(jsonList);
        } else {
          if (kDebugMode) {
            insertErrorLog(
                'Cant fetch data from server, getUsers()', 'users_main_screen');
            print('Cant fetch  data from server');
          }
        }
        return response;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        insertErrorLog(e.toString(), 'UsersMainScreen() , refreshButton');
        showErrorFromBackend(context, e.toString());
      });
    }
    setState(() {
      isLoading = false;
      // isSateManagerActive = true;
    });
  }

  @override
  void initState() {
    isLoading = false;
    loadingCOntroller = refreshButton();
    super.initState();
  }

  @override
  void dispose() {
    tmpRolesList.clear();
    userRows.clear();
    // listOfUsersForGrid.clear();
    isLoading = false;
    areaList.clear();
    listOfUsersForGrid.clear();
    userRows.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _key,
      backgroundColor: colorScheme.surface,
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
        child: FutureBuilder(
          future: loadingCOntroller,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(theme, snapshot.error.toString());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(theme);
            } else {
              return _buildMainContent(theme, colorScheme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar usuarios',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _restartScreen,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando usuarios...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          backgroundColor:
              FlutterFlowTheme.of(context).primary, //Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Administración de Usuarios',
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            if (!isDeviceMobile) ...[
              _buildActionButton(
                theme,
                icon: Icons.verified_user_rounded,
                label: 'Roles',
                onPressed: _navigateToRoles,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                theme,
                icon: Icons.person_add_rounded,
                label: 'Nuevo Usuario',
                onPressed: _createNewUser,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                theme,
                icon: Icons.refresh_rounded,
                label: 'Actualizar',
                onPressed: _restartScreen,
              ),
              const SizedBox(width: 8),
            ],
          ],
          floating: true,
          snap: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lista de Usuarios',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // const Spacer(),
                        if (isDeviceMobile) ...[
                          IconButton.filledTonal(
                            onPressed: _navigateToRoles,
                            icon: const Icon(Icons.verified_user_rounded),
                            tooltip: 'Administrar Roles',
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _createNewUser,
                            icon: const Icon(Icons.person_add_rounded),
                            tooltip: 'Nuevo Usuario',
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            onPressed: _restartScreen,
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Actualizar',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    // const Divider(),
                    // const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 240,
                      child: const UsersTableView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  void _navigateToRoles() {
    try {
      getEventsTempList().whenComplete(() async {
        await getRolesTempList().whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RolesAndProfilesScreen(),
            ),
          );
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      insertErrorLog(e.toString(), 'UsersMainScreen()');
      showErrorFromBackend(context, e.toString());
    }
  }

  void _createNewUser() async {
    try {
      campuseList.clear();
      areaList.clear();
      await getAllCampuse().then((response) async {
        await getWorkDepartmentList();
        await getRolesList().then((onValue) async {
          tmpRolesList = onValue.data; //jsonDecode(onValue.body);
          for (var item in tmpRolesList) {
            Role newRole = Role.fromJson(item);
            tmpRoleObjectslist.add(newRole);
          }
          setState(() {
            buildNewUserScreen(context);
          });
        });
      }).onError((error, stacktrace) {
        insertErrorLog(error.toString(), stacktrace.toString());
      });
    } catch (e) {
      insertErrorLog(e.toString(), 'users_main_screen createNewUser');
      setState(() {
        isLoading = false;
        showErrorFromBackend(context, e.toString());
      });
    }
  }
}

void buildNewUserScreen(BuildContext context) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Crear Nuevo Usuario',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.1),
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerLow,
                ],
              ),
            ),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: NewUserScreen(),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
