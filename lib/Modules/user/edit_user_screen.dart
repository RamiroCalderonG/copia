import 'package:flutter/material.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/temp/users_temp_data.dart';

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
                                    title: Text('Confirm Registration'),
                                    content: Text(
                                        'Are you sure you want to register?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          //TODO : PENDING TO ADD API CALL
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          // Proceed with registration logic here
                                          String email = _emailController.text;
                                          String password =
                                              _passwordController.text;
                                          print(
                                              'Email: $email, Password: $password');
                                        },
                                        child: Text('Register'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Text('Register'),
                          ),
                        ],
                      ),
                    ));

                // Container(
                //     margin: EdgeInsets.all(10),
                //     child: SingleChildScrollView(
                //       child: Column(
                //         children: [
                //           Row(
                //             children: [
                //               Expanded(
                //                   child: TextFormField(
                //                 decoration: InputDecoration(
                //                     labelText: "Nombre del ususario"),
                //               )),
                //               SizedBox(width: 40),
                //               Expanded(
                //                   child: TextFormField(
                //                 decoration: InputDecoration(labelText: "Email"),
                //               ))
                //             ],
                //           ),
                //           Row(
                //             children: [Expanded(child: TextFormField())],
                //           )
                //         ],
                //       ),
                //     ));
              } else {
                return Placeholder();
              }
            },
          ),
        )
      ],
    );
  }
}
