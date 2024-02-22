import 'package:flutter/material.dart';
import 'package:oxschool/Models/User.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

class UserWindow extends StatefulWidget {
  const UserWindow({super.key});

  @override
  State<UserWindow> createState() => _UserWindowState();
}

class _UserWindowState extends State<UserWindow> {
  late Future<User> userFuture; // Future to hold the user data

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < 600) {
        return _smallScreenUserDisplay();
      } else {
        return Placeholder();
        // TODO: CREATE FOR  LARGE SCREENS
      }
    });
  }

  Widget _smallScreenUserDisplay() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mi  perfil', style: TextStyle(color: Colors.white)),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
        body: Stack(
          children: [
            Center(
                child: Column(
              children: <Widget>[
                Container(
                  child: Center(
                    child: Text(
                      'Foto de empleado o inicial',
                      style: TextStyle(fontFamily: 'Sora', fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  width: 200,
                  height: 200,
                  margin: EdgeInsets.all(15),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Text(
                          'Nombre de usuario',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora'),
                        ),
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: 8, left: 20, right: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.purple.shade300,
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Text(
                          'Numero de empleado',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora'),
                        ),
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: 8, left: 20, right: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.green.shade300,
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Text(
                          'Puesto',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora'),
                        ),
                      ),
                    )),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: 8, left: 20, right: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(60)),
                      child: Center(
                        child: Text(
                          'Campus',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Sora'),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ))
          ],
        ));
  }
}
