import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../core/config/flutter_flow/flutter_flow_theme.dart';

Widget customMultiSelectorField(BuildContext context, List<dynamic> listOFItems,
    String title, textButton, TextEditingController controller) {
  return MultiSelectDialogField(
    items:
        listOFItems.map((pain) => MultiSelectItem<String>(pain, pain)).toList(),
    itemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Sora',
          color: FlutterFlowTheme.of(context).primaryText,
        ),
    selectedItemsTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Sora',
          color: FlutterFlowTheme.of(context).tertiary,
        ),
    title: Text(title),
    selectedColor: Colors.blue,
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      border: Border.all(
        color: Colors.blue,
        width: 2,
      ),
    ),
    buttonText: Text(textButton,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Sora',
              color: FlutterFlowTheme.of(context).primaryText,
            )),
    onConfirm: (results) {
      controller.text = results.toString();
      //_selectedAnimals = results;
    },
  );
}
