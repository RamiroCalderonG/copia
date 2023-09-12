class Family {
  late String relationship;
  late String familyName;
  late String firstLastName;
  late String secondLastName;
  late String name;
  late int liveTogether;
  late int isParent;
  late int alive;
  late String adress;
  late String colony;
  late String betweenStreets;
  late int zipCode;
  late String city;
  late int cityCode;
  late String phoneNumber;
  late String cellPhoneNumber;
  late String email;
  late String workplaceName;
  late String workPhoneNumber;
  late String registrationDate;
  late int canPickUp;
  late int idFamilyDet;
  late String taxRegistrationName;
  late String? taxAddress;
  late String? taxColony;
  late int? taxCityCode;
  late String? taxPhoneNumber;
  late String? taxRegistrationRFC;
  late int notActive;
  late int academicGrade;
  late String? workPosition;
  late int isRestricted;
  late String? restrictionMotive;

  Family(
      this.relationship,
      this.familyName,
      this.firstLastName,
      this.secondLastName,
      this.name,
      this.liveTogether,
      this.isParent,
      this.alive,
      this.adress,
      this.colony,
      this.betweenStreets,
      this.zipCode,
      this.city,
      this.cityCode,
      this.phoneNumber,
      this.cellPhoneNumber,
      this.email,
      this.workplaceName,
      this.workPhoneNumber,
      this.registrationDate,
      this.canPickUp,
      this.idFamilyDet,
      this.taxRegistrationName,
      this.taxAddress,
      this.taxColony,
      this.taxCityCode,
      this.taxPhoneNumber,
      this.taxRegistrationRFC,
      this.notActive,
      this.academicGrade,
      this.workPosition,
      this.isRestricted,
      this.restrictionMotive);

  Map<dynamic, dynamic> toJson() => {
        "relationship": relationship,
        "familyName": familyName,
        "firstLastName": firstLastName,
        "secondLastName": secondLastName,
        "name": name,
        "liveTogether": liveTogether,
        "isParent": isParent,
        "alive": alive,
        "adress": adress,
        "colony": colony,
        "betweenStreets": betweenStreets,
        "zipCode": zipCode,
        "city ": city,
        "cityCode": cityCode,
        "phoneNumber": phoneNumber,
        "cellPhoneNumber": cellPhoneNumber,
        "email": email,
        "workplaceName": workplaceName,
        "workPhoneNumber": workPhoneNumber,
        "registrationDate": registrationDate,
        "canPickUp": canPickUp,
        "idFamilyDet": idFamilyDet,
        "taxRegistrationName": taxRegistrationName,
        "taxAddress": taxAddress,
        "taxColony": taxColony,
        "taxCityCode": taxCityCode,
        "taxPhoneNumber": taxPhoneNumber,
        "taxRegistrationRFC": taxRegistrationRFC,
        "notActive": notActive,
        "academicGrade": academicGrade,
        "workPosition": workPosition,
        "isRestricted": isRestricted,
        "restrictionMotive": restrictionMotive
      };
}

dynamic familyFromJSON(List<dynamic> jsonList) {
  // late Family selectedFamily;
  if (jsonList.isEmpty) {
    return null; // Return null if the list is empty
  } else if (jsonList.length == 1) {
    var item = jsonList[0];
    String relationship = item['Parentesco'];
    String familyName = item['NomFamilia'];
    String firstLastName = item['appaterno'];
    String secondLastName = item['Nombre'];
    String name = item['Nombre'];
    int liveTogether = item['VivenJuntosSiNo'];
    int isParent = item['TutorSiNo'];
    int alive = item['Vivesino'];
    String adress = item['Dir'];
    String colony = item['Col'];
    String betweenStreets = item['Entrecalles'];
    int zipCode = item['cp'];
    String city = item['Ciudad'];
    int cityCode = item['ClaCiudad'];
    String phoneNumber = item['Tel'];
    String cellPhoneNumber = item['celular'];
    String email = item['email'];
    String workplaceName = item['nomTrabajo'];
    String workPhoneNumber = item['TelTrabajo'];
    String registrationDate = item['FechaAlta'];
    int canPickUp = item['Recojesino'];
    int idFamilyDet = item['idFamiliaDet'];
    String taxRegistrationName = item['Nombre_Fiscal'];
    String taxAddress = item['dir_Fiscal'];
    String taxColony = item['col_Fiscal'];
    int taxCityCode = item['ClaCiudadFiscal'];
    String taxPhoneNumber = item['Tel_Fiscal'];
    String taxRegistrationRFC = item['Rfc'];
    int notActive = item['BajaLogicaSiNo'];
    int academicGrade = item['Estudios'];
    String workPosition = item['Puesto'];
    int isRestricted = item['Restriccion'];
    String restrictionMotive = item['MotivoRestr'];

    return Family(
        relationship,
        familyName,
        firstLastName,
        secondLastName,
        name,
        liveTogether,
        isParent,
        alive,
        adress,
        colony,
        betweenStreets,
        zipCode,
        city,
        cityCode,
        phoneNumber,
        cellPhoneNumber,
        email,
        workplaceName,
        workPhoneNumber,
        registrationDate,
        canPickUp,
        idFamilyDet,
        taxRegistrationName,
        taxAddress,
        taxColony,
        taxCityCode,
        taxPhoneNumber,
        taxRegistrationRFC,
        notActive,
        academicGrade,
        workPosition,
        isRestricted,
        restrictionMotive);
  } else {
    List<Family> familyList = [];
    for (var item in jsonList) {
      String relationship = item['Parentesco'];
      String familyName = item['NomFamilia'];
      String firstLastName = item['appaterno'];
      String secondLastName = item['apmaterno'];
      String name = item['Nombre'];
      int liveTogether = item['VivenJuntosSiNo'];
      int isParent = item['TutorSiNo'];
      int alive = item['Vivesino'];
      String adress = item['Dir'];
      String colony = item['Col'];
      String betweenStreets = item['Entrecalles'];
      int zipCode = item['cp'];
      String city = item['Ciudad'];
      int cityCode = item['ClaCiudad'];
      String phoneNumber = item['Tel'];
      String cellPhoneNumber = item['celular'];
      String email = item['email'];
      String workplaceName = item['nomTrabajo'];
      String workPhoneNumber = item['TelTrabajo'];
      String registrationDate = item['FechaAlta'];
      int canPickUp = item['Recojesino'];
      int idFamilyDet = item['idFamiliaDet'];
      String taxRegistrationName = item['Nombre_Fiscal'];
      String? taxAddress = item['dir_Fiscal'];
      String? taxColony = item['col_Fiscal'];
      int? taxCityCode = item['ClaCiudadFiscal'];
      String? taxPhoneNumber = item['Tel_Fiscal'];
      String? taxRegistrationRFC = item['Rfc'];
      int notActive = item['BajaLogicaSiNo'];
      int academicGrade = item['Estudios'];
      String? workPosition = item['Puesto'];
      int isRestricted = item['Restriccion'];
      String? restrictionMotive = item['MotivoRestr'];

      familyList.add(Family(
          relationship,
          familyName,
          firstLastName,
          secondLastName,
          name,
          liveTogether,
          isParent,
          alive,
          adress,
          colony,
          betweenStreets,
          zipCode,
          city,
          cityCode,
          phoneNumber,
          cellPhoneNumber,
          email,
          workplaceName,
          workPhoneNumber,
          registrationDate,
          canPickUp,
          idFamilyDet,
          taxRegistrationName,
          taxAddress,
          taxColony,
          taxCityCode,
          taxPhoneNumber,
          taxRegistrationRFC,
          notActive,
          academicGrade,
          workPosition,
          isRestricted,
          restrictionMotive));
    }
    return familyList;
  }
}
