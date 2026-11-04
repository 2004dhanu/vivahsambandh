// To parse this JSON data, do
//
//     final childrenWithModel = childrenWithModelFromJson(jsonString);

import 'dart:convert';

ChildrenWithModel childrenWithModelFromJson(String str) =>
    ChildrenWithModel.fromJson(json.decode(str));

String childrenWithModelToJson(ChildrenWithModel data) =>
    json.encode(data.toJson());

class ChildrenWithModel {
  int? code;
  List<ChildrenWithData>? data;

  ChildrenWithModel({
    this.code,
    this.data,
  });

  ChildrenWithModel copyWith({
    int? code,
    List<ChildrenWithData>? data,
  }) =>
      ChildrenWithModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory ChildrenWithModel.fromJson(Map<String, dynamic> json) =>
      ChildrenWithModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<ChildrenWithData>.from(
                json["data"]!.map((x) => ChildrenWithData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class ChildrenWithData {
  String? childrenWith;

  ChildrenWithData({
    this.childrenWith,
  });

  ChildrenWithData copyWith({
    String? childrenWith,
  }) =>
      ChildrenWithData(
        childrenWith: childrenWith ?? this.childrenWith,
      );

  factory ChildrenWithData.fromJson(Map<String, dynamic> json) =>
      ChildrenWithData(
        childrenWith: json["childrenWith"],
      );

  Map<String, dynamic> toJson() => {
        "childrenWith": childrenWith,
      };
}
