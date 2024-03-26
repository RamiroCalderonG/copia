import 'package:flutter/material.dart';
import 'package:oxschool/flutter_flow/flutter_flow_theme.dart';

class RolesAndProfilesScreen extends StatefulWidget {
  const RolesAndProfilesScreen({super.key});

  @override
  State<RolesAndProfilesScreen> createState() => _RolesAndProfilesScreenState();
}

class _RolesAndProfilesScreenState extends State<RolesAndProfilesScreen> {
  List<String> roles = ['Admin', 'User', 'Second', 'Item'];
  List<String> description = [
    'Admins',
    'Mortals',
    'Other description',
    'Another description to use'
  ];

  Widget roleContainerCard(String role, String desc) {
    return Card(
      color: Colors.cyan[50],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  // Implement delete functionality here
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement open functionality here
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Open'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            title: Text('Administración de usuarios',
                style: TextStyle(color: Colors.white))),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            return Card(
              child: Placeholder(),
            );
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () {}, child: Text('Nuevo Rol')),
                        TextButton(
                            onPressed: () {}, child: Text('Mostrar todos'))
                      ],
                    ),
                  ),
                  SizedBox(width: 36),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                          // height: MediaQuery.of(context).size.height * 0.5,
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Expanded(
                                child: Row(
                                  children: List.generate(
                                      roles.length,
                                      (index) => Expanded(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: 200,
                                                  child: roleContainerCard(
                                                      roles[index],
                                                      description[index]),
                                                )),
                                          )),
                                ),
                              ))))
                ],
              ),
            );
          }
        }));
  }
}
