import '/components/side_nav04_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainWindowModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for SideNav04 component.
  late SideNav04Model sideNav04Model;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {
    sideNav04Model = createModel(context, () => SideNav04Model());
  }

  void dispose() {
    unfocusNode.dispose();
    sideNav04Model.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
