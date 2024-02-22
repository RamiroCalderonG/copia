import '/flutter_flow/flutter_flow_util.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class EnfermeriaModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // State field(s) for SearchFielf widget.
  TextEditingController? searchFielfController;
  String? Function(BuildContext, String?)? searchFielfControllerValidator;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    dataTableShowLogs = false; // Disables noisy DataTable2 debug statements.
  }

  void dispose() {
    unfocusNode.dispose();
    tabBarController?.dispose();
    searchFielfController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
