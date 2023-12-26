class Assignature {
  late int claMateria;
  late String nomMateria;
  late String nomGradoEscolar;
  late String gradoSecuencia;
  late String grado;
  late String gradoGrupo;

  Assignature(this.claMateria, this.nomMateria, this.nomGradoEscolar,
      this.gradoSecuencia, this.grado, this.gradoGrupo);

  Map<dynamic, dynamic> toJson() => {
        "claMateria": claMateria,
        "nomMateria": nomMateria,
        "nomGradoEscolar": nomGradoEscolar,
        "gradoSecuencia": gradoSecuencia,
        "grado": grado,
        "gradoGrupo": gradoGrupo
      };

  void clear() {
    claMateria = 0000;
    nomMateria = "";
    nomGradoEscolar = "";
    gradoSecuencia = "";
    grado = "";
    gradoGrupo = "";
  }
}

dynamic assignatureFromJSON(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else {
    var item = jsonList[0];
    int claMateria = item['claMateria'];
    String nomMateria = item['nomMateria'];
    String nomGradoEscolar = item['nomGradoEscolar'] ?? 'No definido';
    String gradoSecuencia = item['gradoSecuencia'] ?? 'No definido';
    String grado = item['grado'] ?? '';
    String gradoGrupo = item['gradoGrupo'] ?? 'No definido';

    return Assignature(claMateria, nomMateria, nomGradoEscolar, gradoSecuencia,
        grado, gradoGrupo);
  }
}
