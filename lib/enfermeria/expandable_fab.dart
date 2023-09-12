import 'package:flutter/material.dart';

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

final _key = GlobalKey<ExpandableFabState>();

final expandableFABWidget = ExpandableFab(
  key: _key,
  duration: const Duration(milliseconds: 500),
  distance: 100.0,
  type: ExpandableFabType.up,
  pos: ExpandableFabPos.right,
  childrenOffset: const Offset(0, 20),
  fanAngle: 75,
  openButtonBuilder: RotateFloatingActionButtonBuilder(
      child: const Icon(Icons.add),
      fabSize: ExpandableFabSize.regular,
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ) //const  CircleBorder(),
      // angle: 3.14 * 2,
      ),
  closeButtonBuilder: FloatingActionButtonBuilder(
    size: 28,
    builder: (BuildContext context, void Function()? onPressed,
        Animation<double> progress) {
      return IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.check_circle_outline,
          size: 50,
        ),
      );
    },
  ),
  overlayStyle: ExpandableFabOverlayStyle(
    blur: 5,
  ),
  onOpen: () {
    debugPrint('onOpen');
  },
  afterOpen: () {
    debugPrint('afterOpen');
  },
  onClose: () {
    debugPrint('onClose');
  },
  afterClose: () {
    debugPrint('afterClose');
  },
  children: [
    FloatingActionButton.extended(
      label: Text(
        'Agregar visita de alumno',
        style: TextStyle(color: Colors.black),
      ),
      icon: Icon(Icons.people),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      tooltip: 'Agregar visita de alumno',
      heroTag: null,
      // child: const Icon(Icons.edit),
      onPressed: () {
        const SnackBar snackBar = SnackBar(
          content: Text("SnackBar"),
        );
        // scaffoldKey.currentState?.showSnackBar(snackBar);
      },
      backgroundColor: Colors.blueAccent,
    ),
    FloatingActionButton.extended(
      label: Text(
        'Agregar medicamento autorizado',
        style: TextStyle(color: Colors.black),
      ),
      icon: Icon(Icons.medication),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      tooltip: 'Agregar medicamento autorizado',
      heroTag: null,
      // child: const Icon(Icons.edit),
      onPressed: () {
        const SnackBar snackBar = SnackBar(
          content: Text("SnackBar"),
        );
        // scaffoldKey.currentState?.showSnackBar(snackBar);
      },
      backgroundColor: Colors.blueAccent,
    ),
    // FloatingActionButton.small(
    //   // shape: const CircleBorder(),
    //   heroTag: null,
    //   child: const Icon(Icons.share),
    //   onPressed: () {
    //     final state = _key.currentState;
    //     if (state != null) {
    //       debugPrint('isOpen:${state.isOpen}');
    //       state.toggle();
    //     }
    //   },
    // ),
  ],
);
