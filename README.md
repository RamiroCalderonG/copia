
# 🎓 ERP Oxschool

<p align="center">
  <img src="assets/images/logoRedondoOx.png" alt="Oxschool Logo" width="200"/>
</p>

<p align="center">
  <strong>Sistema ERP para Ox School desarrollado en Dart con Flutter, usando Dio para conexión REST API</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.33.0--1.0.pre.11-blue?logo=flutter" alt="Flutter Version"/>
  <img src="https://img.shields.io/badge/Dart-3.9.0-blue?logo=dart" alt="Dart Version"/>
  <img src="https://img.shields.io/badge/Java-SpringBoot-green?logo=spring" alt="Java SpringBoot"/>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Web-lightgrey" alt="Platform Support"/>
</p>

## 📚 Documentation

- **Front End:** Flutter Application with Dio HTTP Client
- **Backend:** REST API Server - Java SpringBoot

## 📦 Instalación en cliente
### 🖥️ Para Windows
Una vez generado el archivo `.exe`, se crea el instalador usando **InnoSetup**

### 🍎 Para macOS
1. Ejecutar `InstallerScritpNew` 
2. Seleccionar `oxschool.app` 
3. Seleccionar `update.scpt` 
4. Seleccionar `oxsUpdaterHelper`

## 🚀 Deployment
Para el manejo de versiones, el procedimiento para aplicación de escritorio es el siguiente:

1. Se construye el proyecto para Windows y macOS
2. Se carga en GitHub la nueva versión como un release
3. En la tabla `app_versions` se crea un nuevo registro con la nueva versión

### 🖥️ Pasos para Windows

1. **Modificar versión en Runner.rc**
   ```bash
   define VERSION_AS_NUMBER [NEW_VERSION_NUMBER]
   ```

2. **Construir ejecutable**
   ```bash
   flutter build windows --release
   ```

3. **Preparar release**
   - Comprimir archivos generados en zip junto con script
   - Cargar en Release de GitHub

### 🍎 Pasos para macOS

1. **Construir aplicación**
   ```bash
   flutter build macos --release
   ```

2. **Preparar release**
   - Comprimir archivo `.app` en un archivo `.zip`
   - Cargar en Release de GitHub

### ⚠️ Notas importantes para macOS

Debido al **SandBox** y **Gatekeeper** de macOS:

- El archivo `.app` se debe configurar sin sandbox desde Xcode
- Se creó un ejecutable Command Line Tools `oxsUpdaterHelper` 
- Debe ubicarse en `/Users/CURRENT_USER/`

#### Permisos requeridos:
```bash
sudo chmod +x /path/to/UpdateHelper 
```

#### Configuración de sudoers:
1. Editar sudoers:
   ```bash
   sudo visudo
   ```

2. Agregar la siguiente línea:
   ```bash
   ALL ALL=(ALL) NOPASSWD: /usr/bin/xattr -dr com.apple.quarantine
   ```

> **Tip:** Para insertar presionar `i`, agregar la línea, luego `Ctrl+C` y `:wq`

#### 🔗 Repositorio del Helper
[**oxsUpdaterHelper Repository**](https://github.com/ericksanr/oxsUpdaterHelper/tree/main)

### 📦 Estructura de GitHub Releases
| Archivo | Contenido |
|---------|-----------|
| `Installer_MacOs.zip` | oxschool.app, InstallerScritpNew, oxsUpdaterHelper, update.scpt |
| `macOs.zip` | oxschool.app |
| `windows.zip` | oxschool.exe + archivos .dll + carpeta data + updateHelper.bat |
| `Installer_Windows.exe` | Instalador (OxsInstaller.exe) |

## 💻 Development

### ⚙️ Prerrequisitos

#### 1. Instalar Dart SDK
- **Sitio oficial:** https://dart.dev/get-dart
- **Windows (Chocolatey):**
  ```bash
  choco install dart-sdk
  ```

#### 2. Instalar Flutter SDK
- **Guía oficial:** https://docs.flutter.dev/get-started/install

#### 3. Backend Server
```bash
java -jar [FILE_LOCATION]
```

### 🏃‍♂️ Ejecutar el proyecto
```bash
flutter pub get
flutter run
```

## 🛠️ Tech Stack

| Categoría | Tecnología | Versión |
|-----------|------------|---------|
| **Frontend** | Flutter | 3.33.0-1.0.pre.11 |
| **Language** | Dart | 3.9.0 (build 3.9.0-100.2.beta) |
| **Backend** | Java SpringBoot | - |
| **HTTP Client** | Dio | - |
| **Platforms** | Windows, macOS, Web | - |

## 📖 Documentation

| Recurso | Enlace |
|---------|--------|
| 🎯 **Dart Docs** | https://dart.dev/docs |
| ☕ **Java 23 Docs** | https://docs.oracle.com/en/java/javase/23/ |
| 💙 **Flutter Docs** | https://docs.flutter.dev/ |

## 🤝 Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/ramirocalderong">
        <img src="https://github.com/ramirocalderong.png" width="100px;" alt="Ramiro Calderon"/><br />
        <sub><b>Ramiro Calderón G</b></sub>
      </a>
    </td>
  </tr>
</table>

---

<p align="center">
  Made with ❤️ by the Oxschool Team
</p>


