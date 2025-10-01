import 'package:flutter/material.dart';
import 'package:oxschool/core/config/flutter_flow/flutter_flow_theme.dart';
import 'package:oxschool/core/extensions/capitalize_strings.dart';
import 'package:oxschool/core/reusable_methods/logger_actions.dart';
import 'package:oxschool/core/utils/loader_indicator.dart';
import 'package:oxschool/data/DataTransferObjects/CafeteriaConsumptionDto.dart';
import 'package:oxschool/data/services/backend/api_requests/api_calls_list_dio.dart';

class CafeteriaUserConsumption extends StatefulWidget {
  const CafeteriaUserConsumption({super.key});

  @override
  State<CafeteriaUserConsumption> createState() =>
      _CafeteriaUserConsumptionState();
}

List<DataCell> cells = [];

class _CafeteriaUserConsumptionState extends State<CafeteriaUserConsumption> {
  late Future<dynamic> cafeteriaConsumption;
  late final List<CafeteriaconsumptionDto> _cafeteriaConsumptionList = [];
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
        var response = value.data; //json.decode(utf8.decode(value.bodyBytes));
        for (var item in response) {
          CafeteriaconsumptionDto cafe = CafeteriaconsumptionDto(
            item['name'],
            DateTime.parse(item['date']).toLocal(),
            item['total'],
          );
          total = total + item['total'];
          _cafeteriaConsumptionList.add(cafe);
        }
        responseData = _cafeteriaConsumptionList;
        //CREATE DATA ROWS
        for (var item in _cafeteriaConsumptionList) {
          String formattedDate =
              "${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')} ${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}:${item.date.second.toString().padLeft(2, '0')}";

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Consumos de Cafetería',
            style: TextStyle(color: Colors.white)),
        centerTitle: false,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
        elevation: 0,
        //surfaceTintColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.12),
              colorScheme.secondary.withOpacity(0.10),
              colorScheme.surface,
            ],
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/cafe.png'),
            fit: BoxFit.contain,
            alignment: Alignment.bottomRight,
            opacity: 0.07,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: cafeteriaConsumption,
            builder: (context, snapshot) {
              Widget content;

              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const Center(child: CustomLoadingIndicator());
              } else if (snapshot.hasError) {
                content = Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colorScheme.error,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ocurrió un error al cargar los datos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                cafeteriaConsumption = obtainUserData();
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                content = Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 32,
                    vertical: isMobile ? 16 : 24,
                  ),
                  child: Card(
                    elevation: isMobile ? 2 : 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: colorScheme.surface,
                    surfaceTintColor: colorScheme.surfaceTint,
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header with title, buttons and total
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Historial de consumo',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Total: \$${total.toStringAsFixed(2)}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed: () {
                                      setState(() {
                                        // Clear existing data
                                        _cafeteriaConsumptionList.clear();
                                        dataRows.clear();
                                        total = 0;
                                        // Reload data
                                        cafeteriaConsumption = obtainUserData();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Actualizar'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          colorScheme.secondaryContainer,
                                      foregroundColor:
                                          colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton.icon(
                                    onPressed: _cafeteriaConsumptionList
                                            .isNotEmpty
                                        ? () {
                                            // TODO: Implement export functionality
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Función de exportar en desarrollo'),
                                                backgroundColor:
                                                    colorScheme.primary,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        : null,
                                    icon: const Icon(
                                        Icons.file_download_outlined),
                                    label: const Text('Exportar'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Data table
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      colorScheme.primaryContainer,
                                    ),
                                    dataRowColor:
                                        WidgetStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return colorScheme.primary
                                              .withOpacity(0.12);
                                        }
                                        if (states
                                            .contains(WidgetState.hovered)) {
                                          return colorScheme.onSurface
                                              .withOpacity(0.08);
                                        }
                                        return null;
                                      },
                                    ),
                                    border: TableBorder.all(
                                      color:
                                          colorScheme.outline.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    showBottomBorder: true,
                                    dividerThickness: 1,
                                    headingTextStyle:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                    dataTextStyle:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text('Artículo'),
                                      ),
                                      DataColumn(
                                        label: Text('Fecha'),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text('Costo'),
                                      ),
                                    ],
                                    rows: dataRows,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Nota: Solo se muestran consumos pendientes de cobrar.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Responsive layout
              if (isMobile) {
                return content;
              } else {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: content,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de consumo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      colorScheme.primaryContainer,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.primary.withOpacity(0.12);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return colorScheme.onSurface.withOpacity(0.08);
                        }
                        return null;
                      },
                    ),
                    border: TableBorder.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    showBottomBorder: true,
                    dividerThickness: 1,
                    headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Artículo')),
                      DataColumn(label: Text('Fecha')),
                      DataColumn(
                        numeric: true,
                        label: Text('Costo'),
                      ),
                    ],
                    rows: dataRows,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nota: Valores solo con estatus 0 (pendientes de cobrar)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
