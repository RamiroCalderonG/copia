import 'package:flutter/material.dart';
import 'package:oxschool/presentation/Modules/main_window/mobile_main_window_widget.dart';
import 'package:oxschool/presentation/Modules/services_ticket/processes/create_service_ticket.dart';
import 'package:oxschool/presentation/components/quality_dialogs.dart';

class MobileFloatingactionbutton extends StatefulWidget {
  const MobileFloatingactionbutton({super.key});

  @override
  State<MobileFloatingactionbutton> createState() =>
      _MobileFloatingactionbuttonState();
}

class _MobileFloatingactionbuttonState
    extends State<MobileFloatingactionbutton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      tooltip: 'Menu rapido',
      onPressed: () {},
      child: PopupMenuButton<int>(
        key: UniqueKey(),
        itemBuilder: (context) => [
          const PopupMenuItem<int>(
            value: 1,
            child: Text('Crear ticket de servicio'),
          ),
          const PopupMenuItem<int>(
            value: 2,
            child: Text('Consultar recibo de nomina(Proximamente)'),
          ),
          const PopupMenuItem<int>(
            value: 3,
            child: Text('Consulta huellas en checador(Proximamente)'),
          ),
        ],
        onSelected: (value) {
          switch (value) {
            case 1:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateServiceTicket()));
              break;
            default:
          }
        },
        child: const Icon(Icons.menu, size: 28),
      ),
    );
  }
}

Widget mobileFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
    backgroundColor: const Color(0xFFF87060),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    tooltip: 'Menu rapido',
    onPressed: () {},
    child: PopupMenuButton<int>(
      key: UniqueKey(),
      itemBuilder: (context) => [
        const PopupMenuItem<int>(
          value: 1,
          child: Text(
            'Inicio',
            style: TextStyle(fontFamily: 'Sora'),
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text(
            'Misión Ox School',
            style: TextStyle(fontFamily: 'Sora'),
          ),
        ),
        const PopupMenuItem<int>(
          value: 3,
          child: Text(
            'Visión Ox School',
            style: TextStyle(fontFamily: 'Sora'),
          ),
        ),
        const PopupMenuItem<int>(
          value: 4,
          child: Text(
            'Política de calidad OxSchool',
            style: TextStyle(fontFamily: 'Sora'),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 1:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const MobileMainWindow()));
            break;
          case 2:
            showMision(context);
            break;
          case 3:
            showVision(context);
            break;
          case 4:
            qualityPolitic(context);
            break;
          default:
        }
      },
      child: const Icon(Icons.menu, size: 28, color: Color(0xFF102542)),
    ),
  );
}
