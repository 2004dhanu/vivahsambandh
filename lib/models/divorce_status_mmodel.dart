// To parse this JSON data, do
//
//     final divorceStatusModel = divorceStatusModelFromJson(jsonString);

import 'dart:convert';

DivorceStatusModel divorceStatusModelFromJson(String str) =>
    DivorceStatusModel.fromJson(json.decode(str));

String divorceStatusModelToJson(DivorceStatusModel data) =>
    json.encode(data.toJson());

class DivorceStatusModel {
  int? code;
  List<Datum>? data;

  DivorceStatusModel({
    this.code,
    this.data,
  });

  DivorceStatusModel copyWith({
    int? code,
    List<Datum>? data,
  }) =>
      DivorceStatusModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory DivorceStatusModel.fromJson(Map<String, dynamic> json) =>
      DivorceStatusModel(
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
  String? divorceStatus;

  Datum({
    this.divorceStatus,
  });

  Datum copyWith({
    String? divorceStatus,
  }) =>
      Datum(
        divorceStatus: divorceStatus ?? this.divorceStatus,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        divorceStatus: json["divorceStatus"],
      );

  Map<String, dynamic> toJson() => {
        "divorceStatus": divorceStatus,
      };
}
