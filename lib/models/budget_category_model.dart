import 'dart:convert';

class BudgetCategoriesModel {
  int? code;
  List<Range>? data;

  BudgetCategoriesModel({
    this.code,
    this.data,
  });

  BudgetCategoriesModel copyWith({
    int? code,
    List<Range>? data,
  }) =>
      BudgetCategoriesModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory BudgetCategoriesModel.fromRawJson(String str) =>
      BudgetCategoriesModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BudgetCategoriesModel.fromJson(Map<String, dynamic> json) =>
      BudgetCategoriesModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<Range>.from(json["data"]!.map((x) => Range.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Range {
  int? id;
  String? ranges;

  Range({
    this.id,
    this.ranges,
  });

  Range copyWith({
    int? id,
    String? ranges,
  }) =>
      Range(
        id: id ?? this.id,
        ranges: ranges ?? this.ranges,
      );

  factory Range.fromRawJson(String str) => Range.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Range.fromJson(Map<String, dynamic> json) => Range(
        id: json["id"],
        ranges: json["ranges"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ranges": ranges,
      };
}
