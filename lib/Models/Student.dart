class Student {
  late String matricula;
  late int claFamilia;
  late String nombre;
  late String claUn;
  late String grupo;
  late String grado;

  Student(this.matricula, this.claFamilia, this.nombre, this.claUn, this.grupo,
      this.grado);

  Map<dynamic, dynamic> toJson() => {
        'matricula': matricula,
        'claFamilia': claFamilia,
        'nombre': nombre,
        'claUn': claUn,
        'grupo': grupo,
        'grado': grado
      };
}
