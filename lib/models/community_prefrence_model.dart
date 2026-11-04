// To parse this JSON data, do
//
//     final communityPreModel = communityPreModelFromJson(jsonString);

import 'dart:convert';

CommunityPreModel communityPreModelFromJson(String str) =>
    CommunityPreModel.fromJson(json.decode(str));

String communityPreModelToJson(CommunityPreModel data) =>
    json.encode(data.toJson());

class CommunityPreModel {
  int? code;
  List<Datum>? data;

  CommunityPreModel({
    this.code,
    this.data,
  });

  CommunityPreModel copyWith({
    int? code,
    List<Datum>? data,
  }) =>
      CommunityPreModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory CommunityPreModel.fromJson(Map<String, dynamic> json) =>
      CommunityPreModel(
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
  String? cpreferences;

  Datum({
    this.cpreferences,
  });

  Datum copyWith({
    String? cpreferences,
  }) =>
      Datum(
        cpreferences: cpreferences ?? this.cpreferences,
      );

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        cpreferences: json["cpreferences"],
      );

  Map<String, dynamic> toJson() => {
        "cpreferences": cpreferences,
      };
}
