import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_util.dart';
import 'package:oxschool/temp/users_temp_data.dart';
import 'package:oxschool/utils/loader_indicator.dart';

import '../../backend/api_requests/api_calls_list.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  var isActive;
  var genre;
  var password;
  Map<String, dynamic> dataToUpdate = {};
  var _userNameUpdated = <String, dynamic>{};
  var _emailUpdated = <String, dynamic>{};
  var _passwordUpdated = <String, dynamic>{};
  bool isloading = false;

  bool _obscureText = true;

  @override
  void initState() {
    _emailController.text = tempSelectedUsr!.userEmail.toString();
    _nameController.text = tempSelectedUsr!.employeeName.toString();
    super.initState();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                  child: Text(
                                'Nombre y correo del ususario',
                                style: TextStyle(
                                    fontFamily: 'Sora', color: Colors.grey),
                              ))
                            ],
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre del usuario',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo no puede estar vacío';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _passwordUpdated = {'nombre_gafete': value};
                                  dataToUpdate
                                      .addEntries(_passwordUpdated.entries);
                                },
                              )),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: _validateEmail,
                                  onChanged: (value) {
                                    _passwordUpdated = {'user_email': value};
                                    dataToUpdate
                                        .addEntries(_passwordUpdated.entries);
                                  },
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                      labelText: 'Nueva contraseña',
                                      border: OutlineInputBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        child: Icon(_obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                      )),
                                  obscureText: _obscureText,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingrese una contraseña';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _passwordUpdated = {'user_password': value};
                                    dataToUpdate
                                        .addEntries(_passwordUpdated.entries);
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 46.0),
                          Row(
                            children: [
                              Text(
                                'Datos personales del ususario',
                                style: TextStyle(
                                    fontFamily: 'Sora', color: Colors.grey),
                              )
                            ],
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              // Expanded(
                              //   child:

                              //   ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirmación'),
                                    content: Text('¿Realiar cambios?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          context.goNamed(
                                            'UDashboard',
                                            extra: <String, dynamic>{
                                              kTransitionInfoKey:
                                                  TransitionInfo(
                                                hasTransition: true,
                                                transitionType:
                                                    PageTransitionType
                                                        .leftToRight,
                                              ),
                                            },
                                          );
                                        },
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (dataToUpdate.isEmpty) {
                                            return showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text('Error'),
                                                      content: Text(
                                                          'No se detectó ningun cambio'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('Ok'))
                                                      ],
                                                    ));
                                          } else {
                                            try {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              setState(() {
                                                isloading = true;
                                              });
                                              var response = await editUser(
                                                  dataToUpdate,
                                                  tempSelectedUsr!
                                                      .employeeNumber
                                                      .toString());
                                              if (response == 200) {
                                                setState(() {
                                                  isloading = false;
                                                });

                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                          icon:
                                                              Icon(Icons.done),
                                                          iconColor: Colors
                                                              .greenAccent,
                                                          title: Text('Exito'),
                                                          content: Text(
                                                              'Usuario actualizado exitosamente'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  'Cerrar'),
                                                            )
                                                          ],
                                                        ));
                                              }
                                            } catch (e) {
                                              setState(() {
                                                isloading = false;
                                              });
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        icon: Icon(Icons.error),
                                                        iconColor:
                                                            Colors.redAccent,
                                                        title: Text('Error'),
                                                        content:
                                                            Text(e.toString()),
                                                      ));
                                            }
                                            // setState(() {
                                            //   isloading = false;
                                            // });
                                            // Navigator.of(context).pop();
                                          }

                                          //TODO : PENDING TO ADD API CALL
                                          // Navigator.of(context).pop();}
                                          // Navigator.of(context).pop();
                                          // // Proceed with registration logic here
                                          // String email = _emailController.text;
                                          // String password =
                                          //     _passwordController.text;
                                          // print(
                                          //     'Email: $email, Password: $password');
                                        },
                                        child: Text('Register'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Text('Actualizar'),
                          ),
                        ],
                      ),
                    ));
              } else {
                return Placeholder();
              }
            },
          ),
        ),
        if (isloading) CustomLoadingIndicator()
      ],
    );
  }
}
