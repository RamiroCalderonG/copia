
# ERP Oxschool

<div align="center">
  <img src="assets/images/logoBlancoOx.png" alt="Oxschool Logo" width="200"/>
  
  ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
  ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
  ![Spring Boot](https://img.shields.io/badge/spring-%236DB33F.svg?style=for-the-badge&logo=spring&logoColor=white)
  ![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white)
</div>

Sistema ERP completo para Ox School desarrollado en Dart con Flutter para el frontend y Java Spring Boot para el backend. La aplicación utiliza Dio para las comunicaciones HTTP y está diseñada para funcionar como aplicación de escritorio multiplataforma.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Tecnologías](#-tecnologías)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación](#-instalación)
- [Desarrollo](#-desarrollo)
- [Deployment](#-deployment)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Contribuciones](#-contribuciones)
- [Documentación](#-documentación)
- [Licencia](#-licencia)

## 🌟 Características

- **Gestión Académica Completa**: Manejo de estudiantes, profesores, cursos y calificaciones
- **Interfaz Multiplataforma**: Aplicación nativa para Windows y macOS
- **Arquitectura REST**: Comunicación eficiente con API backend
- **Actualizaciones Automáticas**: Sistema de actualización integrado
- **Interfaz Moderna**: Diseño responsivo con Material Design
- **Seguridad**: Almacenamiento seguro de credenciales
- **Notificaciones**: Sistema de notificaciones en tiempo real

## 🛠 Tecnologías

### Frontend
- **Flutter 3.33.0-1.0.pre.11** - Framework de desarrollo multiplataforma
- **Dart SDK 3.9.0** - Lenguaje de programación
- **Dio** - Cliente HTTP para comunicación con API
- **Flutter Secure Storage** - Almacenamiento seguro de datos

### Backend
- **Java Spring Boot** - Framework backend REST API
- **MySQL/PostgreSQL** - Base de datos (especificar según tu configuración)

### Herramientas de Desarrollo
- **InnoSetup** - Creador de instaladores para Windows
- **Xcode** - Herramientas de desarrollo para macOS


## 💻 Requisitos del Sistema

### Windows
- Windows 10 o superior (64-bit)
- 4 GB RAM mínimo (8 GB recomendado)
- 500 MB de espacio libre en disco
- Conexión a internet para actualizaciones

### macOS
- macOS 10.14 (Mojave) o superior
- 4 GB RAM mínimo (8 GB recomendado)
- 500 MB de espacio libre en disco
- Conexión a internet para actualizaciones

## 📦 Instalación

### Para Desarrolladores

1. **Instalar Flutter SDK**
   ```bash
   # Descargar desde https://docs.flutter.dev/get-started/install
   # O usando Homebrew en macOS:
   brew install --cask flutter
   ```

2. **Instalar Dart SDK**
   ```bash
   # Windows (usando Chocolatey)
   choco install dart-sdk
   
   # macOS (usando Homebrew)
   brew tap dart-lang/dart
   brew install dart
   ```

3. **Clonar el repositorio**
   ```bash
   git clone https://github.com/ericksanr/OXSClientSideREST.git
   cd OXSClientSideREST
   ```

4. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

5. **Ejecutar la aplicación**
   ```bash
   flutter run -d macos  # Para macOS
   flutter run -d windows  # Para Windows
   ```

### Para Usuarios Finales

#### Windows
1. Descargar el archivo `Installer_Windows.exe` desde [Releases](https://github.com/ericksanr/OXSClientSideREST/releases)
2. Ejecutar el instalador como administrador
3. Seguir las instrucciones del asistente de instalación

#### macOS
1. Descargar el archivo `Installer_MacOs.zip` desde [Releases](https://github.com/ericksanr/OXSClientSideREST/releases)
2. Extraer el archivo ZIP
3. Ejecutar `InstallerScritpNew`
4. Seleccionar `oxschool.app` cuando se solicite
5. Configurar permisos ejecutando:
   ```bash
   sudo chmod +x /Users/$USER/oxsUpdaterHelper
   ```


## 🚀 Deployment

### Proceso de Versioning y Deployment

El manejo de versiones para la aplicación de escritorio sigue estos pasos:

1. **Construir el proyecto para ambas plataformas**
2. **Subir nueva versión a GitHub Releases**
3. **Actualizar tabla `app_versions` en la base de datos**

### Build para Windows

1. **Actualizar versión en Runner.rc**
   ```bash
   # Modificar la línea en windows/runner/Runner.rc:
   #define VERSION_AS_NUMBER [NEW_VERSION_NUMBER]
   ```

2. **Construir ejecutable**
   ```bash
   flutter build windows --release
   ```

3. **Crear paquete de distribución**
   - Comprimir archivos generados en `build/windows/runner/Release/`
   - Incluir todos los archivos `.dll` necesarios
   - Incluir carpeta `data` y script `updateHelper.bat`

4. **Crear instalador con InnoSetup**
   - Generar `OxsInstaller.exe` usando InnoSetup
   - Configurar script de instalación apropiado

### Build para macOS

1. **Construir aplicación**
   ```bash
   flutter build macos --release
   ```

2. **Configurar permisos y certificación**
   
   ⚠️ **Importante para macOS**: Debido a las restricciones de Sandbox y Gatekeeper:
   
   - Remover sandbox desde Xcode si es necesario
   - Configurar `oxsUpdaterHelper` en `/Users/CURRENT_USER/`
   - Establecer permisos ejecutables:
     ```bash
     sudo chmod +x /path/to/oxsUpdaterHelper
     ```

3. **Configurar permisos de sistema**
   ```bash
   # Editar sudoers para permitir xattr sin contraseña
   sudo visudo
   
   # Agregar la siguiente línea:
   ALL ALL=(ALL) NOPASSWD: /usr/bin/xattr -dr com.apple.quarantine
   ```
   
   > 💡 **Tip**: En vi/vim, presiona `i` para insertar, luego `Esc` + `:wq` para guardar y salir

### Estructura de GitHub Releases

Cada release debe incluir los siguientes archivos:

| Archivo | Contenido |
|---------|-----------|
| `Installer_MacOs.zip` | `oxschool.app` + `InstallerScritpNew` + `oxsUpdaterHelper` + `update.scpt` |
| `macOs.zip` | Solo `oxschool.app` |
| `windows.zip` | `oxschool.exe` + archivos `.dll` + carpeta `data` + `updateHelper.bat` |
| `Installer_Windows.exe` | Instalador completo (`OxsInstaller.exe`) |

### Herramientas de Actualización

- **Repository Helper**: [oxsUpdaterHelper](https://github.com/ericksanr/oxsUpdaterHelper/tree/main)
- **Funcionalidad**: Permite actualizaciones automáticas sin intervención del usuario
- **Plataformas**: Compatible con Windows y macOS


## 🚀 Desarrollo

### Configuración del Entorno de Desarrollo

1. **Verificar instalación de Flutter**
   ```bash
   flutter doctor
   ```

2. **Configurar IDE (recomendado: VS Code)**
   - Instalar extensión de Flutter
   - Instalar extensión de Dart
   - Configurar debugger

3. **Ejecutar en modo desarrollo**
   ```bash
   # Ejecutar con hot reload
   flutter run -d macos --debug
   
   # Ejecutar con task predefinida
   flutter run
   ```

4. **Configurar backend server**
   ```bash
   # Ejecutar servidor backend (asegúrate de tener Java instalado)
   java -jar backend-server.jar
   ```

### Comandos Útiles

```bash
# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar tests
flutter test

# Generar build de release
flutter build windows --release  # Windows
flutter build macos --release    # macOS

# Analizar código
flutter analyze
```

### Configuración de Base de Datos

Asegúrate de configurar la conexión a la base de datos en el backend:

1. Configurar `application.properties` en el proyecto backend
2. Crear base de datos necesaria
3. Ejecutar migraciones si es necesario


## 📁 Estructura del Proyecto

```
OXSClientSideREST/
├── lib/                      # Código fuente principal
│   ├── core/                # Funcionalidades centrales
│   ├── data/                # Capa de datos y modelos
│   ├── presentation/        # UI y widgets
│   ├── main.dart           # Punto de entrada
│   └── index.dart          # Exportaciones principales
├── assets/                  # Recursos estáticos
│   ├── images/             # Imágenes y logos
│   ├── fonts/              # Fuentes personalizadas
│   ├── audios/             # Archivos de audio
│   └── lottie_animations/  # Animaciones Lottie
├── windows/                # Configuración Windows
├── macos/                  # Configuración macOS
├── ios/                    # Configuración iOS
├── android/                # Configuración Android
├── web/                    # Configuración Web
├── test/                   # Tests unitarios
├── installers/             # Scripts de instalación
└── pubspec.yaml           # Dependencias Flutter
```

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/grade_validation_test.dart

# Ejecutar tests con coverage
flutter test --coverage

# Widget tests
flutter test test/widget_test.dart
```

## 🔧 Configuración

### Variables de Entorno

Crear un archivo `.env` en la raíz del proyecto:

```env
API_BASE_URL=http://localhost:8080/api
API_TIMEOUT=30000
DEBUG_MODE=true
```

### Configuración de Red

La aplicación se conecta por defecto a:
- **Development**: `http://localhost:8080/api`
- **Production**: Configurar según tu servidor

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor:

1. **Fork** el proyecto
2. **Crear** una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abrir** un Pull Request

### Guidelines de Contribución

- Seguir las convenciones de código de Flutter/Dart
- Escribir tests para nuevas funcionalidades
- Actualizar documentación cuando sea necesario
- Usar commits descriptivos siguiendo [Conventional Commits](https://www.conventionalcommits.org/)

### Colaboradores

- [@ericksanr](https://github.com/ericksanr) - Desarrollo principal
- [@RamiroCalderonG](https://github.com/ramirocalderong) - Colaborador

## 📚 Documentación

### Documentación Oficial
- [Dart Documentation](https://dart.dev/docs)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Java 23 Documentation](https://docs.oracle.com/en/java/javase/23/)
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)

### APIs y Paquetes Utilizados
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Material Design](https://material.io/design)

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:

- **Issues**: [GitHub Issues](https://github.com/ericksanr/OXSClientSideREST/issues)
- **Email**: [Tu email de contacto]
- **Documentación**: [Wiki del proyecto](https://github.com/ericksanr/OXSClientSideREST/wiki)

---

<div align="center">
  <p>Desarrollado para Ox School</p>
  <p>© 2024 Ox School. Todos los derechos reservados.</p>
</div>


