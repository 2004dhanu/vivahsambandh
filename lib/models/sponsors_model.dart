// To parse this JSON data, do
//
//     final sponsoredModel = sponsoredModelFromJson(jsonString);

import 'dart:convert';

SponsoredModel sponsoredModelFromJson(String str) =>
    SponsoredModel.fromJson(json.decode(str));

String sponsoredModelToJson(SponsoredModel data) => json.encode(data.toJson());

class SponsoredModel {
  int? code;
  List<SponsorItem>? data;

  SponsoredModel({
    this.code,
    this.data,
  });

  SponsoredModel copyWith({
    int? code,
    List<SponsorItem>? data,
  }) =>
      SponsoredModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory SponsoredModel.fromJson(Map<String, dynamic> json) => SponsoredModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<SponsorItem>.from(
                json["data"]!.map((x) => SponsorItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SponsorItem {
  String? image;

  SponsorItem({
    this.image,
  });

  SponsorItem copyWith({
    String? image,
  }) =>
      SponsorItem(
        image: image ?? this.image,
      );

  factory SponsorItem.fromJson(Map<String, dynamic> json) => SponsorItem(
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
      };
}
