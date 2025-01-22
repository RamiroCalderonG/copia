import 'dart:ffi';

class CafeteriaconsumptionDto {
  String article;
  DateTime date;
  double total;

  CafeteriaconsumptionDto(this.article, this.date, this.total);

  Map<dynamic, dynamic> toJson() => {
        "article": article,
        "date": date,
        "total": total,
      };

  CafeteriaconsumptionDto fromJson(List<dynamic> jsonCafeteriaConsumption) {
    for (var item in jsonCafeteriaConsumption) {
      article = jsonCafeteriaConsumption[item]['name'];
      date = jsonCafeteriaConsumption[item]['date'];
      total = jsonCafeteriaConsumption[item]['total'];
    }
    return CafeteriaconsumptionDto(article, date, total);
  }
}
