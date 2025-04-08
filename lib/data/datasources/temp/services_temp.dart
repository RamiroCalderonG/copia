import 'package:oxschool/data/Models/ServiceTicketRequest.dart';
import 'package:pluto_grid/pluto_grid.dart';


 List<dynamic> servicesTicketsDecodedResponse = [];
 List<Serviceticketrequest> servicesTicketsDecodedResponseList = [];
 List<Serviceticketrequest> assignedTickets = [];
  List<Serviceticketrequest> unassignedTickets = [];
  List<Serviceticketrequest> onProgressTickets = [];
  List<Serviceticketrequest> closedTickets = [];
  List<Serviceticketrequest> overdueTickets = [];
  int totalTickets = 0;
  int assigned = 0;
  int onProgress = 0;
  int closed = 0;
  int overdue = 0;
  int unassigned = 0;