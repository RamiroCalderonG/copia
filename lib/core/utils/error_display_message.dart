dynamic getUserFriendlyErrorMessage(int? statusCode, dynamic exceptionType) {
  if (statusCode != null) {
    return getMessageByStatusCode(statusCode);
  } else if (exceptionType != null) {
    //TODO: Create function by exception type
  }
}

String getMessageByStatusCode(int statusCode) {
  switch (statusCode) {
    case 400:
      return "La solicitud no se pudo completar correctamente";

    case 401:
      return "No cuenta con los permisos requeridos para la acción";

    case 404:
      return "No se encontró la información solicituada";

    case 408:
      return "Tiempo de espera de la solicitud expiró";

    case 429:
      return "Demasiadas peticiones";

    default:
      return "Favor de consultar con soporte técnico de su campus";
  }
}
