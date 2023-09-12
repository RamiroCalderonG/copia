class Medicines {
  late int claMedicamento;
  late String nomMedicamento;

  Medicines(this.claMedicamento, this.nomMedicamento);

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
      studentMedicines.add(Medicines(claMedicamento, nomMedicamento));
    }
    return studentMedicines;
  }
}
