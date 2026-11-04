// To parse this JSON data, do
//
//     final workAfterMarriageModel = workAfterMarriageModelFromJson(jsonString);

import 'dart:convert';

WorkAfterMarriageModel workAfterMarriageModelFromJson(String str) =>
    WorkAfterMarriageModel.fromJson(json.decode(str));

String workAfterMarriageModelToJson(WorkAfterMarriageModel data) =>
    json.encode(data.toJson());

class WorkAfterMarriageModel {
  int? code;
  List<AfterMarriageData>? data;

  WorkAfterMarriageModel({
    this.code,
    this.data,
  });

  WorkAfterMarriageModel copyWith({
    int? code,
    List<AfterMarriageData>? data,
  }) =>
      WorkAfterMarriageModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory WorkAfterMarriageModel.fromJson(Map<String, dynamic> json) =>
      WorkAfterMarriageModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<AfterMarriageData>.from(
                json["data"]!.map((x) => AfterMarriageData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AfterMarriageData {
  String? workMarriage;

  AfterMarriageData({
    this.workMarriage,
  });

  AfterMarriageData copyWith({
    String? workMarriage,
  }) =>
      AfterMarriageData(
        workMarriage: workMarriage ?? this.workMarriage,
      );

  factory AfterMarriageData.fromJson(Map<String, dynamic> json) =>
      AfterMarriageData(
        workMarriage: json["workMarriage"],
      );

  Map<String, dynamic> toJson() => {
        "workMarriage": workMarriage,
      };
}
