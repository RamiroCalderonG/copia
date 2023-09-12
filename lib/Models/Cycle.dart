class Cycle {
  late String claCiclo;
  late String fecIniCiclo;
  late String fecFinCiclo;

  Cycle(this.claCiclo, this.fecIniCiclo, this.fecFinCiclo);

  Map<dynamic, dynamic> toJson() => {
        "claCiclo": claCiclo,
        "fecIniCiclo": fecIniCiclo,
        "fecFinCiclo": fecFinCiclo
      };
}

dynamic cycleFromJSON(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else {
    var item = jsonList[0];
    String claCiclo = item['claCiclo'];
    String fecIniCiclo = item['FecIniCiclo'];
    String fecFinCiclo = item['FecFinCiclo'];

    return Cycle(claCiclo, fecIniCiclo, fecFinCiclo);
  }
}
