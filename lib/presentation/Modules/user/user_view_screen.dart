import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/login_view/login_view_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/core/reusable_methods/temp_data_functions.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/presentation/Modules/user/user_attendance_screen.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'cafeteria_user_consumption.dart';

// Password strength enum for password validation
enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong,
}

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
              surfaceTintColor: Colors.white,
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
                  icon: const Icon(Icons.notifications_rounded,
                      color: Colors.white),
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
              /*
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                /*
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                ), 
                */
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              */
              child: CircleAvatar(
                radius: isMobile ? 60 : 70,
                backgroundColor: Colors.transparent,
                child: currentUser!.userPicture != null
                    ? ClipOval(
                        child: Image.memory(
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error,
                              color: Colors.red,
                            );
                          },
                          currentUser!.userPicture!,
                          width: (isMobile ? 120 : 130),
                          height: (isMobile ? 120 : 130),
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text(
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildInfoField(
                  theme,
                  colorScheme,
                  'Nombre Completo',
                  currentUser!.employeeName!.toTitleCase,
                  Icons.person_rounded,
                  isMobile,
                ),
                /* _buildInfoField(
                  theme,
                  colorScheme,
                  'Email',
                  currentUser!.userEmail!,
                  Icons.email_rounded,
                  isMobile,
                ), */
                _buildInfoField(
                  theme,
                  colorScheme,
                  'Campus',
                  currentUser!.claUn!.toTitleCase,
                  Icons.location_city_rounded,
                  isMobile,
                ),
                _buildInfoField(
                  theme,
                  colorScheme,
                  'Departamento',
                  currentUser!.work_area!.toTitleCase,
                  Icons.business_center_rounded,
                  isMobile,
                ),
                _buildInfoField(
                  theme,
                  colorScheme,
                  'Rol',
                  currentUser!.role.toTitleCase,
                  Icons.face_rounded,
                  isMobile,
                ),
              ],
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
    final widget = Container(
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

    // On mobile, return the widget as is. On larger screens, constrain the width.
    if (isMobile) {
      return widget;
    } else {
      return SizedBox(
        width:
            300, // Fixed width for larger screens to create consistent columns
        child: widget,
      );
    }
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
                      'Consultar historial de asistencia',
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
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isLoggingOut = false; // New state for logout process

  @override
  void initState() {
    super.initState();
    // Add listener to rebuild when password changes for strength indicator
    _newPassword.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _newPassword.dispose();
    super.dispose();
  }

  // Password strength calculator
  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score >= 4) return PasswordStrength.strong;
    if (score >= 3) return PasswordStrength.good;
    return PasswordStrength.fair;
  }

  // Optimized validation method
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (value.startsWith(' ') || value.endsWith(' ') || value.contains(' ')) {
      return 'La contraseña no puede contener espacios en blanco';
    }
    if (value.length > 20) {
      return 'La contraseña no puede exceder 20 caracteres';
    }
    return null;
  }

  // Optimized update function with better error handling and state management
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update password first
      await updateUserPassword(_newPassword.text.trim());

      if (!mounted) return;

      // Set logout state before showing dialog
      setState(() {
        _isLoading = false;
        _isLoggingOut = true;
      });

      // Show success dialog and handle user confirmation
      await _showSuccessAndLogout();
    } catch (e) {
      insertErrorLog(e.toString(), 'updateUserPassword() @user_view_screen');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorFromBackend(context, e.toString());
      }
    }
  }

  // Optimized function to show success dialog and handle logout
  Future<void> _showSuccessAndLogout() async {
    try {
      // Close the password dialog first
      if (mounted) Navigator.pop(context);

      SnackBar snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Contraseña Actualizada!! 👍, por favor inicia sesión nuevamente.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Sora',
          ),
        ),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      context.goNamed(
        '_initialize',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.leftToRight,
          ),
        },
      );

      await _performSecureLogout();
    } catch (e) {
      insertErrorLog(e.toString(), '_showSuccessAndLogout() @user_view_screen');
      // Ensure logout happens even if dialog fails
      await _performSecureLogout();
    }
  }

  // Optimized secure logout with proper error handling and cleanup
  Future<void> _performSecureLogout() async {
    try {
      // Log the action for audit trail
      insertActionIntoLog(
        'User logged out after password change',
        currentUser?.employeeNumber?.toString() ?? 'Unknown',
      );

      // Perform backend logout with timeout
      if (currentUser != null) {
        await Future.any([
          logOutCurrentUser(currentUser!),
          Future.delayed(const Duration(seconds: 5)), // 5-second timeout
        ]);
      }

      // Clear all local data regardless of backend response
      await _clearAllUserData();
    } catch (e) {
      insertErrorLog(e.toString(), '_performSecureLogout() @user_view_screen');

      // Even if logout fails, ensure data is cleared and user is redirected
      await _clearAllUserData();

      if (mounted) {
        context.goNamed('_initialize');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // Optimized data clearing with proper error handling
  Future<void> _clearAllUserData() async {
    try {
      // Clear global user data
      clearUserData();
      clearTempData();

      // Clear SharedPreferences with error handling
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      insertErrorLog(e.toString(), '_clearAllUserData() @user_view_screen');
      // Continue even if clearing fails - better to have some data left than block the logout
    }
  }

  // Helper method to get appropriate button text based on current state
  String _getButtonText() {
    if (_isLoggingOut) return 'Cerrando sesión...';
    if (_isLoading) return 'Guardando...';
    return 'Cambiar';
  }

  // Password strength indicator widget
  Widget _buildPasswordStrengthIndicator() {
    final strength = _getPasswordStrength(_newPassword.text);
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getStrengthColor() {
      switch (strength) {
        case PasswordStrength.weak:
          return Colors.red;
        case PasswordStrength.fair:
          return Colors.orange;
        case PasswordStrength.good:
          return Colors.blue;
        case PasswordStrength.strong:
          return Colors.green;
        case PasswordStrength.none:
          return colorScheme.outline;
      }
    }

    String getStrengthText() {
      switch (strength) {
        case PasswordStrength.weak:
          return 'Débil';
        case PasswordStrength.fair:
          return 'Regular';
        case PasswordStrength.good:
          return 'Buena';
        case PasswordStrength.strong:
          return 'Fuerte';
        case PasswordStrength.none:
          return '';
      }
    }

    double getStrengthValue() {
      switch (strength) {
        case PasswordStrength.weak:
          return 0.25;
        case PasswordStrength.fair:
          return 0.5;
        case PasswordStrength.good:
          return 0.75;
        case PasswordStrength.strong:
          return 1.0;
        case PasswordStrength.none:
          return 0.0;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: getStrengthValue(),
                  backgroundColor: colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                getStrengthText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: getStrengthColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
          Expanded(
            child: Text(
              'Cambiar Contraseña',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoggingOut
                  ? 'Cerrando sesión de forma segura...'
                  : 'Ingresa tu nueva contraseña para actualizar tus credenciales de acceso.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _isLoggingOut
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: _isLoggingOut ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPassword,
              obscureText: _obscureText,
              autofocus: true,
              autocorrect: false,
              maxLength: 20,
              enabled:
                  !(_isLoading || _isLoggingOut), // Disable during operations
              validator: _validatePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!(_isLoading || _isLoggingOut)) {
                  _updatePassword();
                }
              },
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  onPressed: (_isLoading || _isLoggingOut)
                      ? null
                      : () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  tooltip: _obscureText
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                counterText: '', // Hide character counter for cleaner look
              ),
            ),
            _buildPasswordStrengthIndicator(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isLoading || _isLoggingOut)
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: (_isLoading || _isLoggingOut) ? null : _updatePassword,
          icon: (_isLoading || _isLoggingOut)
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(_getButtonText()),
        ),
      ],
    );
  }
}
