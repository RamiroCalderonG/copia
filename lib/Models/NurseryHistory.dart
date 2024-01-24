class NurseryHistory {
  late String? studentId;
  late String? date;
  late String? studentName;
  late String? cause;
  late String? time;
  late int? grade;
  late String? campuse;
  late String? group;
  late int? idReport;
  late String? diagnosis;
  late String? observations;
  late String? canalization;
  late String? hospitalize;
  late String? tx;

  NurseryHistory(
      this.studentId,
      this.date,
      this.studentName,
      this.cause,
      this.time,
      this.grade,
      this.campuse,
      this.group,
      this.idReport,
      this.diagnosis,
      this.observations,
      this.canalization,
      this.hospitalize,
      this.tx);
}

dynamic studentHistoryFromJSON(List<dynamic> jsonList) {
  List<dynamic> nurseryHistory = [];
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else if (jsonList.length >= 1) {
    for (var item in jsonList) {
      // var item = jsonList[0];
      String? studentId = item['Matricula'];
      String? date = item['Fecha'];
      String? studentName = item['alumno'];
      String? cause = item['causa'];
      String? time = item['Hora'];
      int? grade = item['Gradosecuencia'];
      String? campuse = item['ClaUn'];
      String? group = item['Grupo'];
      int? idReport = item['idReporteEnfermeria'];
      String? diagnosis = item['valoracionenfermeria'];
      String? observations = item['obsGenerales'];
      String? canalization = item['irconmedico'];
      String? hospitalize = item['envioClinica'];
      String? tx = item['tx'];

      nurseryHistory.add(NurseryHistory(
          studentId,
          date,
          studentName,
          cause,
          time,
          grade,
          campuse,
          group,
          idReport,
          diagnosis,
          observations,
          canalization,
          hospitalize,
          tx));
    }
  }

  return nurseryHistory;
}
