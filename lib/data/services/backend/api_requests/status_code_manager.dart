import 'package:oxschool/core/constants/connection.dart';

String returnsMessageToDisplay(int statusCode) {
  if (apiResponseCodes.containsKey(statusCode)) {
    return apiResponseCodes[statusCode]!;
  } else {
    return 'Error desconocido, consulte con IT Support';
  }
}
