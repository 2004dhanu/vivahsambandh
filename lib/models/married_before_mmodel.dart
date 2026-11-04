// To parse this JSON data, do
//
//     final marriedBeforeModel = marriedBeforeModelFromJson(jsonString);

import 'dart:convert';

MarriedBeforeModel marriedBeforeModelFromJson(String str) =>
    MarriedBeforeModel.fromJson(json.decode(str));

String marriedBeforeModelToJson(MarriedBeforeModel data) =>
    json.encode(data.toJson());

class MarriedBeforeModel {
  int? code;
  List<Datum>? data;

  MarriedBeforeModel({
    this.code,
    this.data,
  });

  MarriedBeforeModel copyWith({
    int? code,
    List<Datum>? data,
  }) =>
      MarriedBeforeModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory MarriedBeforeModel.fromJson(Map<String, dynamic> json) =>
      MarriedBeforeModel(
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
  String? marriedbefore;

  Datum({
    this.marriedbefore,
  });

  Datum copyWith({
    String? marriedbefore,
  }) =>
      Datum(
        marriedbefore: marriedbefore ?? this.marriedbefore,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        marriedbefore: json["marriedbefore"],
      );

  Map<String, dynamic> toJson() => {
        "marriedbefore": marriedbefore,
      };
}
