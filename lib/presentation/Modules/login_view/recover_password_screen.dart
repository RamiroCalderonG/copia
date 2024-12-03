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
  bool displaySecondScren = false;
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _tokenFieldController = TextEditingController();
  String deviceData = '';

  @override
  void initState() {
    loadingStart();
    super.initState();
  }

  @override
  void dispose() {
    isLoading = false;
    _textFieldController.clear();
    displaySecondScren = false;
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (displaySecondScren == false) {
        return AlertDialog(
          title: const Text(
            'Recuperar contraseña',
            style: TextStyle(fontFamily: 'Sora'),
          ),
          content: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TextFormField(
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
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCELAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: isLoading
                  ? null // Disable the button when loading
                  : () async {
                      setState(() {
                        isLoading = true; // Start loading animation
                      });
                      if (_textFieldController.text.isNotEmpty ||
                          _textFieldController.text != '') {
                        var response;

                        response = await sendRecoveryToken(
                            _textFieldController.text, deviceData);
                        if (response.statusCode != 200) {
                          setState(() {
                            isLoading = false;
                          });
                          showErrorFromBackend(context, response.body);
                        } else {
                          setState(() {
                            isLoading = false;
                            displaySecondScren = true;
                          });
                        }

                        //     .catchError((error) {
                        //   setState(() {
                        //     isLoading = false;
                        //   });
                        //   if (!mounted) {
                        //     Navigator.pop(context);
                        //     return showErrorFromBackend(context, error);
                        //   }
                        // });
                        // if (response.statusCode == 200) {
                        //   setState(() {
                        //     isLoading = false;
                        //     displaySecondScren = true;
                        //   });
                        // }

                        // var responseCode = await sendUserPasswordToMail(
                        //     _textFieldController.text,
                        //     deviceInformation.toString(),
                        //     deviceIp);
                        // if (responseCode == 200) {
                        //   Navigator.pop(context);
                        //   showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return AlertDialog(
                        //           title: const Text(
                        //             "Solicitud enviada",
                        //             style: TextStyle(fontFamily: 'Sora'),
                        //           ),
                        //           content: const Text(
                        //               "Si los resultados coinciden, recibirá en su correo su contraseña"),
                        //           icon: (const Icon(Icons.beenhere_outlined)),
                        //           actions: [
                        //             TextButton(
                        //                 onPressed: () {
                        //                   Navigator.pop(context);
                        //                 },
                        //                 child: const Text('OK'))
                        //           ],
                        //         );
                        //       });
                        // } else {
                        //   showDialog(
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return AlertDialog(
                        //           title: const Text(
                        //             "Error",
                        //             style: TextStyle(fontFamily: 'Sora'),
                        //           ),
                        //           content: Text(responseCode.toString()),
                        //           icon: (const Icon(Icons.error_outline)),
                        //           actions: [
                        //             TextButton(
                        //                 onPressed: () {
                        //                   Navigator.pop(context);
                        //                 },
                        //                 child: const Text('OK'))
                        //           ],
                        //         );
                        //       });
                        // }
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              icon: const Icon(Icons.error_outline),
                              title: const Text(
                                "Error",
                                style: TextStyle(fontFamily: 'Sora'),
                              ),
                              content: const Text(
                                "Por favor, ingrese un email válido",
                              ),
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
                    },
              child: const Text('OK'),
            ),
          ],
        );
      } else {
        return AlertDialog(
          icon: Icon(Icons.lock),
          title: Text(
            'Ingresa el código de verificación \n que se envió a tu correo electrónico',
            style: TextStyle(fontFamily: 'Sora', fontSize: 14),
          ),
          content: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : TextFormField(
                  autofocus: true,
                  maxLength: 12,
                  controller: _tokenFieldController,
                  decoration: const InputDecoration(
                    // hintText: "Token",
                    // helperText: 'Introduce el token',
                    icon: Icon(Icons.security),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su token';
                    }
                    return null;
                  },
                ),
          actions: [
            TextButton(onPressed: () async {}, child: const Text('Enviar')),
            TextButton(
                onPressed: () async {
                  isLoading = false;
                  displaySecondScren = false;
                  Navigator.pop(context);
                },
                child: const Text('Cancelar')),
          ],
        );
      }
    });
  }
}
