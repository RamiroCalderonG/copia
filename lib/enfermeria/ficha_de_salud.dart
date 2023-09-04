import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:oxschool/Models/Student.dart';
import 'package:oxschool/backend/api_requests/api_calls.dart';
import 'package:oxschool/constants/Student.dart';
import 'package:oxschool/constants/User.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';
import 'package:pluto_grid/pluto_grid.dart';

class FichaDeSalud extends StatefulWidget {
  const FichaDeSalud({super.key});

  @override
  State<FichaDeSalud> createState() => _FichaDeSaludState();
}

class _FichaDeSaludState extends State<FichaDeSalud> {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false; // Add a state variable to track search status
  ApiCallResponse? apiResultxgr;
  bool _showClearButton = true;

  final toolbarOptions = Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.medical_services),
          label: Text('Ficha Medica')),
      TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.add_circle),
          label: Text('Añadir algo'))
    ],
  );

  // var name

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _showClearButton = searchController.text.isNotEmpty;
      });
    });
  }

  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshCard() {
    // name = searchController.text;
    setState(() {
      isSearching = true;
    });
  }

  void _clearText() {
    setState(() {
      searchController.clear();
      _showClearButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight / 1.0;
    double cardWidth =
        MediaQuery.of(context).size.width * 0.8; // 80% of screen width

    return Scaffold(
      appBar: AppBar(
        actions: [],
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          'Ficha medica',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  toolbarOptions,
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      suffixIcon: _showClearButton
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: _clearText,
                            )
                          : null,
                      hintText: 'Buscar alumno',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (query) async {
                      List<String> substrings =
                          searchController.text.split(RegExp(' '));
                      apiResultxgr = await NurseryStudentCall.call(
                          apPaterno: substrings[0],
                          apMaterno: substrings[1],
                          claUn: currentUser.claUn,
                          claCiclo: '2023-2024');
                      if ((apiResultxgr?.succeeded ?? true)) {
                        List<dynamic> jsonList =
                            json.decode(apiResultxgr!.response!.body);
                        nurseryStudent = studentNursery(jsonList);
                        setState(() {
                          isSearching = true;
                        });
                        _refreshCard();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              (apiResultxgr?.jsonBody ?? '').toString(),
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF130C0D),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            duration: Duration(milliseconds: 8000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                        searchController.clear();
                      }
                    },
                  ),
                ],
                // ,
              )),
          if (isSearching) // Display the Card when searching
            Expanded(
              // child: Center(
              child: Container(
                width: cardWidth, // Set the card width here
                height: cardHeight,
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0, // Customize card elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre del estudiante : ${nurseryStudent.nombre}',
                            style: TextStyle(fontSize: 18.0)),
                        SizedBox(height: 8.0),
                        Text('Matricula : ${nurseryStudent.matricula}',
                            style: TextStyle(fontSize: 18.0)),
                        Text('Grado : ${nurseryStudent.grado}',
                            style: TextStyle(fontSize: 18.0)),
                        Text('Grupo : ${nurseryStudent.grupo}',
                            style: TextStyle(fontSize: 18.0)),
                        Text('Campus : ${nurseryStudent.claUn}',
                            style: TextStyle(fontSize: 18.0)),
                        Divider(),
                        Text('data')

                        // Add more data to display here
                      ],
                    ),
                  ),
                ),
              ),
            )
          // )
        ],
      ),
    );
  }
}

Student studentNursery(List<dynamic> jsonList) {
  late Student studentNursery;

  // Iterate through the list and split each item into variables
  for (var item in jsonList) {
    String alumno = item['Alumno'];
    String matricula = item['Matricula'];
    String nomGradoEscolar = item['NomGradoEscolar'];
    String grupo = item['Grupo'];
    String claUn = item['ClaUn'];

    studentNursery =
        Student(matricula, 0, alumno, claUn, grupo, nomGradoEscolar);
  }
  return studentNursery;
}





// class FichaDeSalud extends StatefulWidget {
//   const FichaDeSalud({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }
// }

// class _FichaDeSaludState extends State<FichaDeSalud> {
//   @override
//   Widget build(BuildContext context) {
//     
//     // final bodyFichaSalud = Container(alignment:)

//     

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: FlutterFlowTheme.of(context).primary,
//         title: Text('Consulta ficha de salud',
//             style: TextStyle(color: Colors.white)),
//         actions: [IconButton(icon: Icon(Icons.people), onPressed: () {})],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (query) {
//                 // Add your search logic here, e.g., update a list of search results
//                 // and set isSearching to true when searching
//                 setState(() {
//                   isSearching = true;
//                 });
//               },
//             ),
//           ),
//           if (isSearching) // Display the Card when searching
//             Container(
//               padding: EdgeInsets.all(16.0),
//               child: Card(
//                 elevation: 4.0, // Customize card elevation
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Student Name', style: TextStyle(fontSize: 18.0)),
//                       SizedBox(height: 8.0),
//                       Text('Student Info', style: TextStyle(fontSize: 14.0)),
//                       // Add more data to display here
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       //  SingleChildScrollView(

//       // ),
//     );
//   }
// }
