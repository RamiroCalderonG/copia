import 'package:oxschool/backend/api_requests/api_calls.dart';

//selectedcampus:  can be 'A' to get all campuses or the initial letter of each campus
//employeeID: if you want to get a single employee
//logData: logger function to post data from the device making the call
//param: to determinate if we want a single employee(1) or all of them(0)
getEmployee(
    String selectedCampus, String employeeID, String logData, int param) async {
  var apiResultxgr = await EmployeeCall.call(
          campus: selectedCampus,
          EmployeeID: employeeID,
          logData: logData,
          param: param.toString())
      .timeout(Duration(seconds: 15));
}
