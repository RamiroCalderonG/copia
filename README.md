
# ERP Oxschool

Migración de sistema ERP para multiplataforma.







## Documentation

* Front End:  
* Backend: REST API Servr API Java SpringBoot


## Instalacion en cliente
- Para Windows
  Una vez con archivo .exe se crea el instalador con el uso de InnoSetup

- Para MacOS
  *Pendiente crear script que ubique archivos y permisos necesarios que se ejecute con sudo*

### Versioning
Para el manejo de versiones el procedimiento para aplciacion de escritorio es el siguiente:
* Se contruye el proyecto para Windows y MacOS, posteriormente se carga en Github la nueva version como un release y en la tabla app_versions se crea un nuevo registro con la nueva version

Pasos para Windows
- Modificar Runner.rc con la version a contruir
  - Modificar linea :
   ```bash
   define VERSION_AS_NUMBER [NEW_VERSION_NUMBER]
  ```
  
- Construir .exe
    ```bash
  flutter build windows --release
    ```
  
- Comprimir archivos generados en zip junto con script 
- Cargar en Release de Github 

**NOTA:**


Pasos para MacOS
- Construir .app
     ```bash
  flutter build windows --release
    ```
  
- Comprimir archivo .app en un archivo .zip
- Cargar en Release de Github

**NOTA:**
Debido al SandBox y Gatekeeper de MacOS el archivo .app se elimina el sandbox desde Xcode y asì mismo se creó un ejecutable Comand Line Tools "oxsUpdaterHelper" y este se debe ubicar en */Users/CURRENT_USER/*
Y para que este pueda trabajar correctamente se debe incluir los siguientes permisos 
```bash
  sudo chmod +x /path/to/UpdateHelper 
```

-Asì mismo se debe editar visudo para que permita el uso de xattr como sudo sin pedir contraseña:
1.-
```bash
  sudo visudo
```
2.- Agregar : 
```bash
  ALL ALL=(ALL) NOPASSWD: /usr/bin/xattr -dr com.apple.quarantine
```

- Para insertar presionar i y posteriormente agregar la linea, luego presionar CTRL+C y luego :qw

##TODO 🚀
*PENDIENTE DE AGREGAR PROCESO EN UN SCRIPT AL MOMENTO DE HACER LA INSTALACION*


**Updater Helper** [oxsUpdaterHelper Repo](https://github.com/ericksanr/oxsUpdaterHelper/tree/main)





## Deployment

1- Para ejecutar este proyecto es necesario instalar Dart SDK
https://dart.dev/get-dart

- Windows
```bash
  choco install dart-sdk
```
2- Instalar Flutter SDK
https://docs.flutter.dev/get-started/install


3.- Instalar backend server
```bash
  java -jar [FILE_LOCATION]
```

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`API_KEY` Pending to update

`ANOTHER_API_KEY` Pending to update

## Tech Stack

**Client:** Flutter, Dart

**Server:** Java Springboot


## Versioning
  **Dart SDK: 3.9.0 (build 3.9.0-100.2.beta)**
  **Flutter: 3.33.0-1.0.pre.11 • channel main**
  


## Documentation
[Dart Docs:](https://dart.dev/docs)
[Java 23 Docs](https://docs.oracle.com/en/java/javase/23/)
[Flutter Docs:](https://docs.flutter.dev/)


## Contributions

- [@RamiroCalderonG](https://github.com/ramirocalderong)


