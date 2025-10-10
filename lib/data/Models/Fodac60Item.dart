class Fodac60Item {
  final int promediosino;
  final int coment10;
  final double calif9;
  final String calif3C;
  final double calif8;
  final double calif7;
  final double calif6;
  final double calif5;
  final String calif1C;
  final String grupo;
  final double calif4;
  final int grupocalif;
  final double calif3;
  final String nommateria;
  final double calif2;
  final int discip10;
  final int faltas3;
  final int faltas4;
  final String calif7C;
  final String promedioCalC;
  final int faltas1;
  final int faltas2;
  final int habitos10;
  final String matricula;
  final int orden;
  final String regSepCampus;
  final String maestro;
  final int planestudios;
  final int habitos2;
  final int habitos3;
  final String calif6C;
  final int habitos1;
  final int habitos6;
  final String calif10C;
  final String nomGrado;
  final int habitos7;
  final int tareas10;
  final int habitos4;
  final String calif2C;
  final int clamateria;
  final int habitos5;
  final int tareas1;
  final int gradoSecuencia;
  final String gp;
  final int discip3;
  final int tareas9;
  final String claCiclo;
  final String claUN;
  final int discip2;
  final int tareas8;
  final double calif10;
  final int discip1;
  final int tareas7;
  final int tareas6;
  final int tareas5;
  final String nombreCampus;
  final int tareas4;
  final double promedioCal;
  final int tareas3;
  final int tareas2;
  final int habitos8;
  final int discip9;
  final int discip8;
  final int habitos9;
  final int discip7;
  final int discip6;
  final int discip5;
  final int discip4;
  final int coment5;
  final int coment4;
  final String nombre;
  final int coment3;
  final int coment2;
  final String calif5C;
  final int coment9;
  final int coment8;
  final String nombreCoordinadora;
  final int coment7;
  final int coment6;
  final int coment1;
  final String dirCampus;
  final int faltas10;
  final String calif9C;
  final int faltas7;
  final int faltas8;
  final int faltas5;
  final int faltas6;
  final String telCampus;
  final int faltas9;
  final String nombreGrupo;
  final String calif4C;
  final String nombreDirectora;
  final int frecuencias;
  final double calif1;
  final String calif8C;

  const Fodac60Item({
    required this.promediosino,
    required this.coment10,
    required this.calif9,
    required this.calif3C,
    required this.calif8,
    required this.calif7,
    required this.calif6,
    required this.calif5,
    required this.calif1C,
    required this.grupo,
    required this.calif4,
    required this.grupocalif,
    required this.calif3,
    required this.nommateria,
    required this.calif2,
    required this.discip10,
    required this.faltas3,
    required this.faltas4,
    required this.calif7C,
    required this.promedioCalC,
    required this.faltas1,
    required this.faltas2,
    required this.habitos10,
    required this.matricula,
    required this.orden,
    required this.regSepCampus,
    required this.maestro,
    required this.planestudios,
    required this.habitos2,
    required this.habitos3,
    required this.calif6C,
    required this.habitos1,
    required this.habitos6,
    required this.calif10C,
    required this.nomGrado,
    required this.habitos7,
    required this.tareas10,
    required this.habitos4,
    required this.calif2C,
    required this.clamateria,
    required this.habitos5,
    required this.tareas1,
    required this.gradoSecuencia,
    required this.gp,
    required this.discip3,
    required this.tareas9,
    required this.claCiclo,
    required this.claUN,
    required this.discip2,
    required this.tareas8,
    required this.calif10,
    required this.discip1,
    required this.tareas7,
    required this.tareas6,
    required this.tareas5,
    required this.nombreCampus,
    required this.tareas4,
    required this.promedioCal,
    required this.tareas3,
    required this.tareas2,
    required this.habitos8,
    required this.discip9,
    required this.discip8,
    required this.habitos9,
    required this.discip7,
    required this.discip6,
    required this.discip5,
    required this.discip4,
    required this.coment5,
    required this.coment4,
    required this.nombre,
    required this.coment3,
    required this.coment2,
    required this.calif5C,
    required this.coment9,
    required this.coment8,
    required this.nombreCoordinadora,
    required this.coment7,
    required this.coment6,
    required this.coment1,
    required this.dirCampus,
    required this.faltas10,
    required this.calif9C,
    required this.faltas7,
    required this.faltas8,
    required this.faltas5,
    required this.faltas6,
    required this.telCampus,
    required this.faltas9,
    required this.nombreGrupo,
    required this.calif4C,
    required this.nombreDirectora,
    required this.frecuencias,
    required this.calif1,
    required this.calif8C,
  });

  factory Fodac60Item.fromJson(Map<String, dynamic> json) {
    return Fodac60Item(
      promediosino: json['Promediosino'] ?? 0,
      coment10: json['Coment10'] ?? 0,
      calif9: (json['Calif9'] ?? 0.0).toDouble(),
      calif3C: json['Calif3C'] ?? '',
      calif8: (json['Calif8'] ?? 0.0).toDouble(),
      calif7: (json['Calif7'] ?? 0.0).toDouble(),
      calif6: (json['Calif6'] ?? 0.0).toDouble(),
      calif5: (json['Calif5'] ?? 0.0).toDouble(),
      calif1C: json['Calif1C'] ?? '',
      grupo: json['Grupo'] ?? '',
      calif4: (json['Calif4'] ?? 0.0).toDouble(),
      grupocalif: json['grupocalif'] ?? 0,
      calif3: (json['Calif3'] ?? 0.0).toDouble(),
      nommateria: json['Nommateria'] ?? '',
      calif2: (json['Calif2'] ?? 0.0).toDouble(),
      discip10: json['Discip10'] ?? 0,
      faltas3: json['Faltas3'] ?? 0,
      faltas4: json['Faltas4'] ?? 0,
      calif7C: json['Calif7C'] ?? '',
      promedioCalC: json['PromedioCalC'] ?? '',
      faltas1: json['Faltas1'] ?? 0,
      faltas2: json['Faltas2'] ?? 0,
      habitos10: json['Habitos10'] ?? 0,
      matricula: json['Matricula'] ?? '',
      orden: json['Orden'] ?? 0,
      regSepCampus: json['RegSepCampus'] ?? '',
      maestro: json['Maestro'] ?? '',
      planestudios: json['Planestudios'] ?? 0,
      habitos2: json['Habitos2'] ?? 0,
      habitos3: json['Habitos3'] ?? 0,
      calif6C: json['Calif6C'] ?? '',
      habitos1: json['Habitos1'] ?? 0,
      habitos6: json['Habitos6'] ?? 0,
      calif10C: json['Calif10C'] ?? '',
      nomGrado: json['NomGrado'] ?? '',
      habitos7: json['Habitos7'] ?? 0,
      tareas10: json['Tareas10'] ?? 0,
      habitos4: json['Habitos4'] ?? 0,
      calif2C: json['Calif2C'] ?? '',
      clamateria: json['Clamateria'] ?? 0,
      habitos5: json['Habitos5'] ?? 0,
      tareas1: json['Tareas1'] ?? 0,
      gradoSecuencia: json['GradoSecuencia'] ?? 0,
      gp: json['Gp'] ?? '',
      discip3: json['Discip3'] ?? 0,
      tareas9: json['Tareas9'] ?? 0,
      claCiclo: json['ClaCiclo'] ?? '',
      claUN: json['ClaUN'] ?? '',
      discip2: json['Discip2'] ?? 0,
      tareas8: json['Tareas8'] ?? 0,
      calif10: (json['Calif10'] ?? 0.0).toDouble(),
      discip1: json['Discip1'] ?? 0,
      tareas7: json['Tareas7'] ?? 0,
      tareas6: json['Tareas6'] ?? 0,
      tareas5: json['Tareas5'] ?? 0,
      nombreCampus: json['NombreCampus'] ?? '',
      tareas4: json['Tareas4'] ?? 0,
      promedioCal: (json['PromedioCal'] ?? 0.0).toDouble(),
      tareas3: json['Tareas3'] ?? 0,
      tareas2: json['Tareas2'] ?? 0,
      habitos8: json['Habitos8'] ?? 0,
      discip9: json['Discip9'] ?? 0,
      discip8: json['Discip8'] ?? 0,
      habitos9: json['Habitos9'] ?? 0,
      discip7: json['Discip7'] ?? 0,
      discip6: json['Discip6'] ?? 0,
      discip5: json['Discip5'] ?? 0,
      discip4: json['Discip4'] ?? 0,
      coment5: json['Coment5'] ?? 0,
      coment4: json['Coment4'] ?? 0,
      nombre: json['Nombre'] ?? '',
      coment3: json['Coment3'] ?? 0,
      coment2: json['Coment2'] ?? 0,
      calif5C: json['Calif5C'] ?? '',
      coment9: json['Coment9'] ?? 0,
      coment8: json['Coment8'] ?? 0,
      nombreCoordinadora: json['NombreCoordinadora'] ?? '',
      coment7: json['Coment7'] ?? 0,
      coment6: json['Coment6'] ?? 0,
      coment1: json['Coment1'] ?? 0,
      dirCampus: json['DirCampus'] ?? '',
      faltas10: json['Faltas10'] ?? 0,
      calif9C: json['Calif9C'] ?? '',
      faltas7: json['Faltas7'] ?? 0,
      faltas8: json['Faltas8'] ?? 0,
      faltas5: json['Faltas5'] ?? 0,
      faltas6: json['Faltas6'] ?? 0,
      telCampus: json['TelCampus'] ?? '',
      faltas9: json['Faltas9'] ?? 0,
      nombreGrupo: json['NombreGrupo'] ?? '',
      calif4C: json['Calif4C'] ?? '',
      nombreDirectora: json['NombreDirectora'] ?? '',
      frecuencias: json['frecuencias'] ?? 0,
      calif1: (json['Calif1'] ?? 0.0).toDouble(),
      calif8C: json['Calif8C'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Promediosino': promediosino,
      'Coment10': coment10,
      'Calif9': calif9,
      'Calif3C': calif3C,
      'Calif8': calif8,
      'Calif7': calif7,
      'Calif6': calif6,
      'Calif5': calif5,
      'Calif1C': calif1C,
      'Grupo': grupo,
      'Calif4': calif4,
      'grupocalif': grupocalif,
      'Calif3': calif3,
      'Nommateria': nommateria,
      'Calif2': calif2,
      'Discip10': discip10,
      'Faltas3': faltas3,
      'Faltas4': faltas4,
      'Calif7C': calif7C,
      'PromedioCalC': promedioCalC,
      'Faltas1': faltas1,
      'Faltas2': faltas2,
      'Habitos10': habitos10,
      'Matricula': matricula,
      'Orden': orden,
      'RegSepCampus': regSepCampus,
      'Maestro': maestro,
      'Planestudios': planestudios,
      'Habitos2': habitos2,
      'Habitos3': habitos3,
      'Calif6C': calif6C,
      'Habitos1': habitos1,
      'Habitos6': habitos6,
      'Calif10C': calif10C,
      'NomGrado': nomGrado,
      'Habitos7': habitos7,
      'Tareas10': tareas10,
      'Habitos4': habitos4,
      'Calif2C': calif2C,
      'Clamateria': clamateria,
      'Habitos5': habitos5,
      'Tareas1': tareas1,
      'GradoSecuencia': gradoSecuencia,
      'Gp': gp,
      'Discip3': discip3,
      'Tareas9': tareas9,
      'ClaCiclo': claCiclo,
      'ClaUN': claUN,
      'Discip2': discip2,
      'Tareas8': tareas8,
      'Calif10': calif10,
      'Discip1': discip1,
      'Tareas7': tareas7,
      'Tareas6': tareas6,
      'Tareas5': tareas5,
      'NombreCampus': nombreCampus,
      'Tareas4': tareas4,
      'PromedioCal': promedioCal,
      'Tareas3': tareas3,
      'Tareas2': tareas2,
      'Habitos8': habitos8,
      'Discip9': discip9,
      'Discip8': discip8,
      'Habitos9': habitos9,
      'Discip7': discip7,
      'Discip6': discip6,
      'Discip5': discip5,
      'Discip4': discip4,
      'Coment5': coment5,
      'Coment4': coment4,
      'Nombre': nombre,
      'Coment3': coment3,
      'Coment2': coment2,
      'Calif5C': calif5C,
      'Coment9': coment9,
      'Coment8': coment8,
      'NombreCoordinadora': nombreCoordinadora,
      'Coment7': coment7,
      'Coment6': coment6,
      'Coment1': coment1,
      'DirCampus': dirCampus,
      'Faltas10': faltas10,
      'Calif9C': calif9C,
      'Faltas7': faltas7,
      'Faltas8': faltas8,
      'Faltas5': faltas5,
      'Faltas6': faltas6,
      'TelCampus': telCampus,
      'Faltas9': faltas9,
      'NombreGrupo': nombreGrupo,
      'Calif4C': calif4C,
      'NombreDirectora': nombreDirectora,
      'frecuencias': frecuencias,
      'Calif1': calif1,
      'Calif8C': calif8C,
    };
  }

  @override
  String toString() {
    return 'Fodac60Item(matricula: $matricula, nombre: $nombre, nommateria: $nommateria, promedioCal: $promedioCal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fodac60Item &&
        other.matricula == matricula &&
        other.clamateria == clamateria &&
        other.orden == orden;
  }

  @override
  int get hashCode {
    return matricula.hashCode ^ clamateria.hashCode ^ orden.hashCode;
  }
}
