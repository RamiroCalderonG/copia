Map<String, String> messagesFromBackend = {
  'TimeoutException': 'Error en conexion, verificar conectividad, Code: 408',
};

String getMessageToDisplay(String currentMessage) {
  if (messagesFromBackend.containsKey(currentMessage)) {
    return messagesFromBackend[currentMessage]!;
  } else {
    return currentMessage;
  }
}
