class Employee {
  String? employeeID;
  String? name;
  String? firstLastName;
  String? secondLastName;
  String? workPosition;
  String? workArea;
  DateTime? birthDate;
  bool? disabled;

  Employee(this.employeeID, this.name, this.firstLastName, this.secondLastName,
      this.birthDate, this.workArea, this.workPosition, this.disabled);

  Map<dynamic, dynamic> toJson() => {
        'EmployeeId': employeeID,
        'Name': name,
        'FirstLastName': firstLastName,
        'SecondLastName': secondLastName,
        'BirthDate': "${birthDate?.year.toString()}",
        "Area": workArea,
        "Puesto": workPosition,
        "bajalogicaSiNo": disabled
      };
}
