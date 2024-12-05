import 'package:flutter/material.dart';
import 'package:oxschool/core/constants/user_consts.dart';
import 'package:oxschool/core/reusable_methods/translate_messages.dart';
import 'package:oxschool/core/utils/device_information.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';
import 'package:oxschool/presentation/components/confirm_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  var deviceIp;
  bool isLoading = false;
  //bool displaySecondScren = false;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _tokenFieldController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordVerifierController =
      TextEditingController();
  String deviceData = '';
  final PageController _pageController = PageController();
  bool _isPasswordVisible = false;
  bool _isPasswordVerifierVisible = false;

  @override
  void initState() {
    loadingStart();
    super.initState();
  }

  @override
  void dispose() {
    isLoading = false;
    _textFieldController.clear();
    //displaySecondScren = false;
    super.dispose();
  }

  loadingStart() async {
    deviceIp = await getDeviceIP();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? device = prefs.getString('device');
    deviceData = device ?? '';
  }

  // dynamic sendRecoveryTokenFunction(String email, String device) async {
  //   try {
  //     return await sendRecoveryToken(email, device.toString());
  //   } catch (e) {
  //     return FormatException(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
      ),
      body: Padding(
          padding: EdgeInsets.only(left: 100, right: 100),
          child: PageView(
            controller: _pageController,
            children: [
              // First Step: Email Input
              _buildEmailInputStep(),
              // Second Step: Token Input
              _buildTokenInputStep(),
              // Third Step: Placeholder
              _buildPasswordInput(),
            ],
          )),
    );
  }

  Widget _buildEmailInputStep() {
    return
        // Center(
        // child:
        Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text(
          'Instrucciones: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.start,
        ),
        Text(
          '1.- Ingrese su correo y presione enviar.',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.start,
        ),
        Text(
          '2.- Revise su correo electrónico para obtener un token de recuperación de contraseña.',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.start,
        ),
        Text(
          '3.- Ingrese el token y su nueva contraseña.',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 30),
        isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [const CircularProgressIndicator()],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      flex: 4,
                      child: TextFormField(
                        autofocus: true,
                        maxLength: 40,
                        controller: _textFieldController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          helperText: 'Ingrese su correo electrónico',
                          icon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingrese un correo válido';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) async {
                          setState(() {
                            isLoading = true; // Start loading animation
                          });
                          if (_textFieldController.text.isNotEmpty) {
                            var response = await sendRecoveryToken(
                                _textFieldController.text, deviceData);
                            if (response.statusCode != 200) {
                              setState(() {
                                isLoading = false;
                              });
                              showErrorFromBackend(context, response.body);
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          } else {
                            // Show error dialog for empty email
                            _showErrorDialog(
                                "Por favor, ingrese un email válido");
                          }
                        },
                      )),
                  const SizedBox(width: 20),
                  Flexible(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null // Disable the button when loading
                          : () async {
                              setState(() {
                                isLoading = true; // Start loading animation
                              });
                              if (_textFieldController.text.isNotEmpty) {
                                var response = await sendRecoveryToken(
                                    _textFieldController.text, deviceData);
                                if (response.statusCode != 200) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showErrorFromBackend(context, response.body);
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                }
                              } else {
                                // Show error dialog for empty email
                                _showErrorDialog(
                                    "Por favor, ingrese un email válido");
                              }
                            },
                      child: const Text('Enviar'),
                    ),
                  ),
                ],
              )
      ],
    );
    // );
  }

  Widget _buildTokenInputStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Verifique su correo electronico e ingrese el token de recuperación',
            style: TextStyle(fontFamily: 'Sora', fontStyle: FontStyle.italic),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : TextFormField(
                  autofocus: true,
                  maxLength: 12,
                  controller: _tokenFieldController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.security),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su token';
                    }
                    return null;
                  },
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              var response;
              try {
                response = await validateToken(_tokenFieldController.text,
                    _textFieldController.text, deviceData);
                if (response.statusCode == 200) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                } else {
                  showErrorFromBackend(context, response.body);
                }
              } catch (e) {
                showErrorFromBackend(context, e.toString());
              }
            },
            child: const Text('Enviar'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ingrese su nueva contraseña. Nota: No debe contener espacios',
            style: TextStyle(fontFamily: 'Sora', fontStyle: FontStyle.italic),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : Column(
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                          // hintText: "Contraseña",
                          helperText: 'Ingrese su contraseña',
                          icon: Icon(Icons.security),
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: _passwordVerifierController,
                      obscureText: !_isPasswordVerifierVisible,
                      decoration: InputDecoration(
                          // hintText: "Verifiue Contraseña",
                          helperText: 'Verifique su contraseña',
                          icon: Icon(Icons.security),
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVerifierVisible =
                                      !_isPasswordVerifierVisible;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña para verificarla';
                        }
                        return null;
                      },
                    )
                  ],
                ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_passwordController.text.trim() !=
                  _passwordVerifierController.text.trim()) {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Las contraseñas no coinciden'));
                    });
              } else {
                var response = await updateUserPasswordByToken(
                  _tokenFieldController.text,
                  _passwordController.text,
                ).catchError((error) {
                  showErrorFromBackend(context, error);
                });
                if (response.statusCode == 200) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Exito'),
                          content:
                              const Text('Contraseña actualizada con exito'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.defaultRouteName;
                                },
                                child: const Text('OK'))
                          ],
                        );
                      });
                  // _pageController.nextPage(
                  //   duration: const Duration(milliseconds: 300),
                  //   curve: Curves.easeIn,
                  // );
                } else {
                  _showErrorDialog(response);
                }
              }
            },
            child: const Text('Enviar'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline),
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
