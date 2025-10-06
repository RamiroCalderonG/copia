// ignore_for_file: file_names

class Student {
  late String? matricula;
  late int? claFamilia;
  late String? nombre;
  late String? claUn;
  late String? grupo;
  late String? grado;
  late int? gradoSecuencia;

  Student(this.matricula, this.claFamilia, this.nombre, this.claUn, this.grupo,
      this.grado, this.gradoSecuencia);

  Map<dynamic, dynamic> toJson() => {
        'matricula': matricula,
        'claFamilia': claFamilia,
        'nombre': nombre,
        'claUn': claUn,
        'grupo': grupo,
        'grado': grado,
        'gradoSecuencia': gradoSecuencia
      };

  Student.fromJson(Map<dynamic, dynamic> json)
      : matricula = json['studentId'] ?? '',
        claFamilia = json['claFamilia'],
        nombre = json['name'],
        claUn = json['campus'],
        grupo = json['group'],
        grado = json['gradeName'],
        gradoSecuencia = json['gradeSequence'];

  void clear() {
    matricula = null;
    claFamilia = null;
    nombre = null;
    claUn = null;
    grupo = null;
    grado = null;
    gradoSecuencia = null;
  }
}
