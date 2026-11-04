// To parse this JSON data, do
//
//     final professionModel = professionModelFromJson(jsonString);

import 'dart:convert';

ProfessionModel professionModelFromJson(String str) =>
    ProfessionModel.fromJson(json.decode(str));

String professionModelToJson(ProfessionModel data) =>
    json.encode(data.toJson());

class ProfessionModel {
  int? code;
  List<Datum>? data;

  ProfessionModel({
    this.code,
    this.data,
  });

  ProfessionModel copyWith({
    int? code,
    List<Datum>? data,
  }) =>
      ProfessionModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory ProfessionModel.fromJson(Map<String, dynamic> json) =>
      ProfessionModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? profession;

  Datum({
    this.profession,
  });

  Datum copyWith({
    String? profession,
  }) =>
      Datum(
        profession: profession ?? this.profession,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        profession: json["profession"],
      );

  Map<String, dynamic> toJson() => {
        "profession": profession,
      };
}
