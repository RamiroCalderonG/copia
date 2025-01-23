import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/constants/screens.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/academic_functions.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/Data%20Transfer%20Objects/CafeteriaConsumptionDto.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list.dart';

class CafeteriaUserConsumption extends StatefulWidget {
  const CafeteriaUserConsumption({super.key});

  @override
  State<CafeteriaUserConsumption> createState() =>
      _CafeteriaUserConsumptionState();
}

List<DataCell> cells = [];

class _CafeteriaUserConsumptionState extends State<CafeteriaUserConsumption> {
  late Future<dynamic> cafeteriaConsumption;
  late List<CafeteriaconsumptionDto> _cafeteriaConsumptionList = [];
  double total = 0;
  List<DataRow> dataRows = [];

  @override
  void initState() {
    cafeteriaConsumption = obtainUserData();
    super.initState();
  }

  @override
  void dispose() {
    cells.clear();
    _cafeteriaConsumptionList.clear();
    super.dispose();
  }

  //Function to retrive and convert user cafeteria history that is set on Estatus as 0; (Pending to charge)
  Future<dynamic> obtainUserData() async {
    try {
      var responseData;
      await getUserCafeteriaConsumptionHistory().then((value) {
        var response = json.decode(utf8.decode(value.bodyBytes));
        for (var item in response) {
          CafeteriaconsumptionDto cafe = CafeteriaconsumptionDto(
            item['name'],
            DateTime.parse(item['date']),
            item['total'],
          );
          total = total + item['total'];
          _cafeteriaConsumptionList.add(cafe);
        }
        responseData = _cafeteriaConsumptionList;
        //CREATE DATA ROWS
        for (var item in _cafeteriaConsumptionList) {
          String formattedDate =
              "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}";

          DataCell article = DataCell(Text(item.article.toTitleCase));
          DataCell date = DataCell(Text(formattedDate));
          DataCell total = DataCell(Text(item.total.toString()));
          cells.addAll([article, date, total]);

          DataRow dataRow = DataRow(cells: []);
          dataRow.cells.addAll(cells);
          dataRows.add(dataRow);
          cells.clear();
        }
      });
      return responseData;
    } catch (e) {
      insertErrorLog(e.toString(), 'obtainUserData()');
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: cafeteriaConsumption,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomLoadingIndicator());
          } else if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Historal de compras de cafetería'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: FlutterFlowTheme.of(context).primaryText,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: const Placeholder(
                    color: Colors.transparent,
                    child: Center(child: Text('Sin información disponible'))));
          } else if (snapshot.hasError) {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Historal de compras de cafetería'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: FlutterFlowTheme.of(context).primaryText,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                body: Placeholder(
                    child: Center(child: Text('Error: ${snapshot.error}'))));
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('Historial de consumo de cafetería'),
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: FlutterFlowTheme.of(context).primaryText,
                ),
                body: Padding(
                    padding: EdgeInsets.all(15),
                    child: CafeteriaUserHistoryTable(
                      cafeteriaConsumptionList: _cafeteriaConsumptionList,
                      dataRows: dataRows,
                      total: total,
                    )));
          }
        });
  }
}

class CafeteriaUserHistoryTable extends StatelessWidget {
  final List<CafeteriaconsumptionDto> cafeteriaConsumptionList;
  final List<DataRow> dataRows;
  final double total;
  const CafeteriaUserHistoryTable({
    super.key,
    required this.cafeteriaConsumptionList,
    required this.dataRows,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.blueGrey),
                        border: TableBorder.all(),
                        showBottomBorder: true,
                        dividerThickness: 2,
                        columns: <DataColumn>[
                          const DataColumn(
                            label: Expanded(
                              child: Text(
                                'Articulo',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Expanded(
                              child: Text(
                                'Fecha',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          const DataColumn(
                            numeric: true,
                            label: Expanded(
                              child: Text(
                                'Costo',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ],
                        rows: dataRows,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Flexible(
                    child: Text(
                      'Total: $total \n  \t* Nota: Valores solo con estatus 0',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
