class Serviceticketrequest {
  int idReqServ;
  String reportedBy;
  String requestFromDept;
  String capturedBy;
  String requestToDept;
  String? assignedTo;
  String campus;
  DateTime serviceCreationDate;
  DateTime serviceRequestDate;
  DateTime? deadLine;
  DateTime? closureDate;
  String description;
  String observations;
  int status;


  Serviceticketrequest({
    required this.idReqServ,
    required this.reportedBy,
    required this.requestFromDept,
    required this.capturedBy,
    required this.requestToDept,
    this.assignedTo,
    required this.campus,
    required this.serviceCreationDate,
    required this.serviceRequestDate,
    this.deadLine,
    this.closureDate,
    required this.description,
    required this.observations,
    required this.status,
  });


  Serviceticketrequest.fromJson(Map<String, dynamic> json)
  : 
    idReqServ = json['idReqServ'],
    reportedBy = json['reportedBy'],
    requestFromDept = json['requestFromDept'],
    capturedBy = json['capturedBy'],
    requestToDept = json['requestToDept'],
    assignedTo = json['assignedTo'],
    campus = json['campus'],
    serviceCreationDate = DateTime.parse(json['serviceCreationDate']),
    serviceRequestDate = DateTime.parse(json['serviceRequestDate']),
    deadLine = json['deadLine'] != null ? DateTime.parse(json['deadLine']) : null,
    closureDate = json['closureDate'] != null ? DateTime.parse(json['closureDate']) : null,
    description = json['description'],
    observations = json['observations'],
    status = json['status'];
  
}