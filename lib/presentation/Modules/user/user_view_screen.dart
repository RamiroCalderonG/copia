import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/reusable_methods/user_functions.dart';
// import 'package:oxschool/data/Models/User.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';

import 'cafeteria_user_consumption.dart';

class UserWindow extends StatelessWidget {
  const UserWindow({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Wrap(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Padding(padding: EdgeInsets.all(10), child: Center(
                    child: Center(
                      child: CircleAvatar(
                    radius: 100,
                    child: Center(
                      child: Text(currentUser!.employeeName!.initials, 
                      style: TextStyle(fontFamily: 'Sora', fontSize: 20)),
                    ) 
                    ,
                  ),
                    ),
                  ),),
                  
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
                                child: TextFormField(
                                  initialValue:
                                      currentUser!.employeeName!,
                                  style: TextStyle(color: Colors.white),
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text(
                                      'Nombre',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
                                child: TextFormField(
                                  // controller: TextEditingController(
                                  //     text: '${currentUser!.employeeNumber}'),
                                  style: TextStyle(color: Colors.white),
                                  initialValue:
                                      currentUser!.employeeNumber.toString(),
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
                                child: TextFormField(
                                  initialValue: currentUser!.claUn!.toTitleCase,
                                  // controller: TextEditingController(
                                  //     text: currentUser!.claUn!.toTitleCase),
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
                                                'Consulta  recibo nómina (Proximamente)')),
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
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return UpdateUserPasswordScreen();
                                                  });
                                            },
                                            icon: const Icon(Icons.create),
                                            label: const Text(
                                                'Cambiar contraseña')),
                                      ]))
                            ] else ...[
                              // For smaller screens, use full width
                              TextField(
                                controller: TextEditingController(
                                    text:
                                        '${currentUser!.employeeName?.toTitleCase}'),
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
                                          tooltip:
                                              'Consulta  recibo nómina (Proximamente)',
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        IconButton.outlined(
                                          color: Colors.white,
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CafeteriaUserConsumption()));
                                          },
                                          icon: const Icon(Icons.fastfood),
                                          tooltip: 'Consumo de cafetería',
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        IconButton.outlined(
                                          color: Colors.white,
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return UpdateUserPasswordScreen();
                                                });
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
    return AlertDialog(
      title: const Text(
        'Cambiar mi contraseña',
        style: TextStyle(fontFamily: 'Sora'),
      ),
      content: TextField(
        obscureText: _obscureText,
        autofocus: true,
        autocorrect: false,
        maxLength: 20,
        controller: _newPassword,
        decoration: InputDecoration(
          hintText: "Nueva Contraseña",
          icon: const Icon(Icons.password),
          suffix: IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
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
                showErrorFromBackend(
                    context, 'La contraseña debe tener al menos 8 caracteres');
              }
              if (_newPassword.text.startsWith(' ') ||
                  _newPassword.text.endsWith(' ') ||
                  _newPassword.text.contains(' ')) {
                showErrorFromBackend(context,
                    'Su contraseña no puede contener espacios en blanco');
              } else {
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var response = updateUserPasswordFn(_newPassword.text.trim())
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
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Cambiar'))
      ],
    );
  }
}
