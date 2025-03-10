Map<String, String> messagesFromBackend = {
  'TimeoutException': 'La solicitud expiró, vuelva a intentar, Code: 408',
  'Unavailable': 'Servicio no disponible por el momento, Code: 503',
  'FireDACPhysPGlibpq': 'Servicio no disponible por el momento, Code:503',
  'FormatException': 'Error al intentar procesar la información, Code: 409',
  'SocketException': 'Error en conexion, verificar conectividad, Code: 408',
  'Unauthorized':
      'No cuenta con los permisos requeridos, consulte a su cordinador, Code : 401',
  'Outdated': 'Fecha actual no cumple con parametros requeridos',
  'UserNotFound': 'No se encuentra el usuario, verifique sus datos de acceso'
};
// Map<int, String> api_status_code = {503: 'Service unavailable'};

String getMessageToDisplay(String currentMessage) {
  var stringMessage = currentMessage.replaceAll(
      RegExp(r'[^\w\s]+'), ''); //remove specia characters
  var firstWord =
      stringMessage.toString().split(" ").elementAt(0); //retrive first word
  if (messagesFromBackend.containsKey(firstWord)) {
    //Compare if value exist
    return messagesFromBackend[firstWord]!;
  } else {
    return currentMessage;
  }
}

Map<int, String> apiStatusCodes = {
  404: 'Not Found',
  408: 'Request Timeout',
};
