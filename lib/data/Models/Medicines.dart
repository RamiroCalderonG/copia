// ignore_for_file: file_names

class Medicines {
  late int claMedicamento;
  late String nomMedicamento;
  late int? id;

  Medicines(this.claMedicamento, this.nomMedicamento, this.id);

  Map<dynamic, dynamic> toJson() => {
        'ClaMedicamento': claMedicamento,
        'NomMedicamento': nomMedicamento,
      };
}

dynamic getMedicinesFromJSON(List<dynamic> jsonList) {
  List<Medicines> studentMedicines = [];
  if (jsonList.isEmpty) {
    return null;
  } else {
    for (var item in jsonList) {
      // item = jsonList[0];
      int claMedicamento = item['CLAMEDICAMENTO'];
      String nomMedicamento = item['NomMedicamento'];
      int id = item['id'];
      studentMedicines.add(Medicines(claMedicamento, nomMedicamento, id));
    }
    return studentMedicines;
  }
}
