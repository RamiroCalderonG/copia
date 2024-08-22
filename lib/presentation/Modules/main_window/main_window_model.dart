import '../../components/side_nav04_widget.dart';
import '../../../core/config/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class MainWindowModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for SideNav04 component.
  late SideNav04Model sideNav04Model;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    sideNav04Model = createModel(context, () => SideNav04Model());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    sideNav04Model.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
