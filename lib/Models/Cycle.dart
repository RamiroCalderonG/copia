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
