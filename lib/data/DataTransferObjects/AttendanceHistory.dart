class AttendanceHistory {
  final String? employee;
  final int? record;
  final String? employeeNumber;
  final String? date;
  final String? where;
  final String? day;
  final bool? origin;

  AttendanceHistory({
    required this.employee,
    required this.record,
    required this.employeeNumber,
    required this.date,
    required this.where,
    required this.day,
    required this.origin,
  });

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    return AttendanceHistory(
      employee: json['Trabajador'].toString().trim(),
      record: json['Registro'],
      employeeNumber: json['NoEmpleado'],
      date: json['Fecha'],
      where: json['Donde'].toString().trim(),
      day: json['Dia'],
      origin: json['Origen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Trabajador': employee,
      'Registro': record,
      'NoEmpleado': employeeNumber,
      'Fecha': date,
      'Donde': where,
      'Dia': day,
      'Origen': origin,
    };
  }
}
