import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/Modules/user/user_attendance_screen.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'cafeteria_user_consumption.dart';

class UserWindow extends StatelessWidget {
  const UserWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FlutterFlowTheme.of(context).primary,
              FlutterFlowTheme.of(context).primary.withOpacity(0.8),
              colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Mi Perfil',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_rounded),
                  tooltip: 'Notificaciones',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              floating: true,
              snap: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(theme, colorScheme, isMobile),
                    const SizedBox(height: 24),
                    _buildProfileInfo(theme, colorScheme, isMobile),
                    const SizedBox(height: 24),
                    _buildActionButtons(theme, colorScheme, context, isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      ThemeData theme, ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 8,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isMobile ? 60 : 80,
                backgroundColor: Colors.transparent,
                child: Text(
                  currentUser!.employeeName!.initials,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser!.employeeName!.toTitleCase,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Empleado #${currentUser!.employeeNumber}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(
      ThemeData theme, ColorScheme colorScheme, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              theme,
              colorScheme,
              'Nombre Completo',
              currentUser!.employeeName!.toTitleCase,
              Icons.person_rounded,
              isMobile,
            ),
            // const SizedBox(height: 5),
            // _buildInfoField(
            //   theme,
            //   colorScheme,
            //   'Número de Empleado',
            //   currentUser!.employeeNumber.toString(),
            //   Icons.badge_rounded,
            //   isMobile,
            // ),
            const SizedBox(height: 5),
            _buildInfoField(
              theme,
              colorScheme,
              'Campus',
              currentUser!.claUn!.toTitleCase,
              Icons.location_city_rounded,
              isMobile,
            ),
            const SizedBox(height: 5),
            _buildInfoField(
              theme,
              colorScheme,
              'Departamento',
              currentUser!.work_area!.toTitleCase,
              Icons.business_center_rounded,
              isMobile,
            ),
            const SizedBox(height: 5),
            _buildInfoField(
              theme,
              colorScheme,
              'Rol',
              currentUser!.role!.toTitleCase,
              Icons.face_rounded,
              isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    ColorScheme colorScheme,
    BuildContext context,
    bool isMobile,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.apps_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acciones Rápidas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isMobile) ...[
              _buildActionCard(
                theme,
                colorScheme,
                'Recibo de Nómina',
                'Consultar recibo (Próximamente)',
                Icons.attach_money_rounded,
                () {},
                Colors.green,
                true,
              ),
              const SizedBox(height: 5),
              _buildActionCard(
                theme,
                colorScheme,
                'Consumos de Cafetería',
                'Ver historial de consumos',
                Icons.restaurant_rounded,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CafeteriaUserConsumption(),
                    ),
                  );
                },
                Colors.orange,
                false,
              ),
              const SizedBox(height: 5),
              _buildActionCard(
                theme,
                colorScheme,
                'Cambiar Contraseña',
                'Actualizar credenciales de acceso',
                Icons.security_rounded,
                () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UpdateUserPasswordScreen();
                    },
                  );
                },
                Colors.blue,
                false,
              ),
              const SizedBox(height: 5),
              _buildActionCard(
                theme,
                colorScheme,
                'Evaluaciones de desempeño',
                'Consultar historial de evaluaciones(Proximamente)',
                Icons.attach_money_rounded,
                () {},
                Colors.green,
                true,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      theme,
                      colorScheme,
                      'Recibo de Nómina',
                      'Consultar recibo (Próximamente)',
                      Icons.attach_money_rounded,
                      () {},
                      Colors.green,
                      true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCard(
                      theme,
                      colorScheme,
                      'Consumos de Cafetería',
                      'Ver historial de consumos',
                      Icons.restaurant_rounded,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CafeteriaUserConsumption(),
                          ),
                        );
                      },
                      Colors.orange,
                      false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCard(
                      theme,
                      colorScheme,
                      'Evaluaciones de desempeño',
                      'Consultar historial de evaluaciones (Próximamente)',
                      Icons.grade,
                      () {},
                      Colors.blueAccent,
                      true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      theme,
                      colorScheme,
                      'Historial de Asistencia',
                      'Consultar historial de asistencia (Próximamente)',
                      Icons.watch_later_rounded,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const UserAttendanceHistoryScreen(),
                          ),
                        );
                      },
                      Colors.purple,
                      false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionCard(
                      theme,
                      colorScheme,
                      'Prestamos y Créditos',
                      'Consultar historial de préstamos y créditos (Próximamente)',
                      Icons.monetization_on,
                      () {
                        // TODO: Implementar acción para préstamos y créditos
                      },
                      Colors.teal,
                      true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildActionCard(
                theme,
                colorScheme,
                'Cambiar Contraseña',
                'Actualizar credenciales de acceso',
                Icons.security_rounded,
                () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UpdateUserPasswordScreen();
                    },
                  );
                },
                Colors.blue,
                false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color accentColor,
    bool isDisabled,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDisabled
                ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                : accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled
                  ? colorScheme.outline.withOpacity(0.2)
                  : accentColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? colorScheme.onSurfaceVariant.withOpacity(0.2)
                      : accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color:
                      isDisabled ? colorScheme.onSurfaceVariant : accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDisabled
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDisabled
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: accentColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateUserPasswordScreen extends StatefulWidget {
  const UpdateUserPasswordScreen({super.key});

  @override
  State<UpdateUserPasswordScreen> createState() =>
      _UpdateUserPasswordScreenState();
}

class _UpdateUserPasswordScreenState extends State<UpdateUserPasswordScreen> {
  final TextEditingController _newPassword = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPassword.dispose();
    super.dispose();
  }

  Future<dynamic> updateUserPasswordFn(String newPassword) async {
    var response = await updateUserPassword(newPassword);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.security_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cambiar Contraseña',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingresa tu nueva contraseña para actualizar tus credenciales de acceso.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPassword,
            obscureText: _obscureText,
            autofocus: true,
            autocorrect: false,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Nueva Contraseña',
              hintText: 'Mínimo 8 caracteres',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _newPassword.clear();
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  if (_newPassword.text.length < 8) {
                    showErrorFromBackend(context,
                        'La contraseña debe tener al menos 8 caracteres');
                    return;
                  }
                  if (_newPassword.text.startsWith(' ') ||
                      _newPassword.text.endsWith(' ') ||
                      _newPassword.text.contains(' ')) {
                    showErrorFromBackend(context,
                        'Su contraseña no puede contener espacios en blanco');
                    return;
                  }

                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    updateUserPasswordFn(_newPassword.text.trim())
                        .whenComplete(() {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                      showConfirmationDialog(
                          context, 'Éxito', 'Contraseña cambiada con éxito');
                    });
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    insertErrorLog(
                        e.toString(), 'updateUserPassword() @user_view_screen');
                    showErrorFromBackend(context, e.toString());
                  }
                },
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_isLoading ? 'Guardando...' : 'Cambiar'),
        ),
      ],
    );
  }
}
