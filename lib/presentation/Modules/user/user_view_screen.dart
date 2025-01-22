import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'cafeteria_user_consumption.dart';

class UserWindow extends StatefulWidget {
  const UserWindow({super.key});

  @override
  State<UserWindow> createState() => _UserWindowState();
}

class _UserWindowState extends State<UserWindow> {
  late Future<User> userFuture; // Future to hold the user data
  final TextEditingController _newPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _largerScreenUserDisplay();
  }

  Widget _largerScreenUserDisplay() {
    return Scaffold(
        appBar: AppBar(
          title:
              const Text('Mi  perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
              tooltip: 'Notificaciones',
            )
          ],
        ),
        body: Stack(
          children: [
            // Background with blur effect
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background-header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // Rounded container at the top
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  CircleAvatar(
                    radius: 100,
                    // backgroundImage:
                    //     AssetImage('assets/images/logoRedondoOx.png'),
                    child: Text(currentUser!.employeeName!),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (MediaQuery.of(context).size.width > 600) ...[
                              SizedBox(
                                width: 400,
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${currentUser!.employeeName}'),
                                  style: TextStyle(color: Colors.white),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text(
                                      'Nombre',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    // labelText: 'Nombre',
                                    icon:
                                        Icon(Icons.person, color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width:
                                    400, // Set a fixed width for the TextFields
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${currentUser!.employeeNumber}'),
                                  style: TextStyle(color: Colors.white),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text(
                                      'Número de empleado',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    // labelText: 'Numero de empleado',
                                    icon: Icon(Icons.numbers,
                                        color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width:
                                    400, // Set a fixed width for the TextFields
                                child: TextField(
                                  controller: TextEditingController(
                                      text: '${currentUser!.claUn}'),
                                  style: TextStyle(color: Colors.white),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text(
                                      'Campus',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    icon:
                                        Icon(Icons.house, color: Colors.white),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        ElevatedButton.icon(
                                            style: const ButtonStyle(
                                                // backgroundColor:
                                                // MaterialStatePropertyAll<Color>(Colors.green),
                                                ),
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.attach_money_outlined),
                                            label: const Text(
                                                'Consulta  recibo nomina')),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CafeteriaUserConsumption()));
                                            },
                                            icon: const Icon(Icons.fastfood),
                                            label: const Text(
                                                'Consumos de cafetería')),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        ElevatedButton.icon(
                                            style: const ButtonStyle(
                                                // backgroundColor:
                                                //     MaterialStatePropertyAll<Color>(Colors.orange),
                                                ),
                                            onPressed: () {
                                              _changeMyPassword(context);
                                            },
                                            icon: const Icon(Icons.create),
                                            label: const Text(
                                                'Cambiar contraseña')),
                                      ]))
                            ] else ...[
                              // For smaller screens, use full width
                              TextField(
                                controller: TextEditingController(
                                    text: '${currentUser!.employeeName}'),
                                style: TextStyle(color: Colors.white),
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    'Nombre',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  icon: Icon(Icons.person, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: TextEditingController(
                                    text: '${currentUser!.employeeNumber}'),
                                style: TextStyle(color: Colors.white),
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    'Número de empleado',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  icon:
                                      Icon(Icons.numbers, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              TextField(
                                controller: TextEditingController(
                                    text: '${currentUser!.claUn}'),
                                style: TextStyle(color: Colors.white),
                                readOnly: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    'Campus',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  icon: Icon(Icons.house, color: Colors.white),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Row(
                                      // mainAxisAlignment:
                                      // MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        IconButton.outlined(
                                          color: Colors.white,
                                          onPressed: () {},
                                          icon: const Icon(
                                              Icons.attach_money_outlined),
                                          tooltip: 'Consulta  recibo nómina',
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        IconButton.outlined(
                                          color: Colors.white,
                                          onPressed: () {},
                                          icon: const Icon(Icons.fastfood),
                                          tooltip: 'Consumo de cafetería',
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        IconButton.outlined(
                                          color: Colors.white,
                                          onPressed: () {
                                            _changeMyPassword(context);
                                          },
                                          icon: const Icon(Icons.create),
                                          tooltip: 'Cambiar contraseña',
                                        )
                                      ])),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  dynamic _updateUserPasswordFn(String newPassword) {
    var response = updateUserPassword(newPassword);
    return response;
  }

  Future<void> _changeMyPassword(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Cambiar mi contraseña',
              style: TextStyle(fontFamily: 'Sora'),
            ),
            content: TextField(
              // obscureText: true,
              controller: _newPassword,
              decoration: const InputDecoration(
                  hintText: "Nueva Contraseña",
                  // helperText:
                  //     "1 mayuscula, caracteres especiales, minimo 8 caracteres",
                  icon: Icon(Icons.password)),
            ),
            actions: <Widget>[
              TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    _newPassword.clear();
                    Navigator.pop(context);
                  }),
              TextButton(
                  onPressed: () {
                    if (_newPassword.text.length < 8) {
                      showErrorFromBackend(context,
                          'La contraseña debe tener al menos 8 caracteres');
                    }
                    if (_newPassword.text.startsWith(' ') ||
                        _newPassword.text.endsWith(' ') ||
                        _newPassword.text.contains(' ')) {
                      showErrorFromBackend(context,
                          'Su contraseña no puede contener espacios en blanco');
                    } else {
                      bool response = _updateUserPasswordFn(_newPassword.text);
                      if (response) {
                        _newPassword.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Contraseña cambiada con éxito'),
                          backgroundColor: Colors.green,
                        ));
                      } else {
                        showErrorFromBackend(
                            context, 'Error al cambiar contraseña');
                      }
                    }
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }
}
