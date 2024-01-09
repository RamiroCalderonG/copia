// TODO: Pending to add more params
class Cause {
  final String claCause;
  final String nomCause;
  // final int area;
  // final int isactive;

  Cause(
    this.claCause,
    this.nomCause,
    //  this.area, this.isactive
  );

  factory Cause.fromJson(Map<String, dynamic> json) {
    return Cause(json['claCausa'], json['nomCausa']);
  }

  Map<dynamic, dynamic> toJson() => {
        "Clacausa": claCause,
        "nomCausa": nomCause,
        // "ClaArea": area,
        // 'Bajalogicasino': isactive
      };
}

dynamic causeFromJSON(List<dynamic> jsonList) {
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else {
    var item = jsonList[0];
    String claCause = item['claCausa'];
    String nomCause = item['nomCausa'];
    // int area = item['ClaArea'];
    // int isactive = item['Bajalogicasino'];

    return Cause(
      claCause, nomCause,
      // area, isactive
    );
  }
}
