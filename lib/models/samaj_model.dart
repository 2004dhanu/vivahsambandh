// To parse this JSON data, do
//
//     final samajModel = samajModelFromJson(jsonString);

import 'dart:convert';

SamajModel samajModelFromJson(String str) =>
    SamajModel.fromJson(json.decode(str));

String samajModelToJson(SamajModel data) => json.encode(data.toJson());

class SamajModel {
  int? code;
  Data? data;

  SamajModel({
    this.code,
    this.data,
  });

  SamajModel copyWith({
    int? code,
    Data? data,
  }) =>
      SamajModel(
        code: code ?? this.code,
        data: data ?? this.data,
      );

  factory SamajModel.fromJson(Map<String, dynamic> json) => SamajModel(
        code: json["code"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data?.toJson(),
      };
}

class Data {
  int? id;
  String? name;
  String? description;
  String? address;
  String? state;
  String? district;
  String? city;
  String? pincode;
  String? phone;
  String? emailId;
  String? mobileStatus;
  String? mainContactName;
  String? mainContactNumber;
  String? authoriseLetter;
  String? samajLogo;
  String? samajWebsite;
  dynamic createdAt;
  dynamic updatedAt;

  Data({
    this.id,
    this.name,
    this.description,
    this.address,
    this.state,
    this.district,
    this.city,
    this.pincode,
    this.phone,
    this.emailId,
    this.mobileStatus,
    this.mainContactName,
    this.mainContactNumber,
    this.authoriseLetter,
    this.samajLogo,
    this.samajWebsite,
    this.createdAt,
    this.updatedAt,
  });

  Data copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    String? phone,
    String? emailId,
    String? mobileStatus,
    String? mainContactName,
    String? mainContactNumber,
    String? authoriseLetter,
    String? samajLogo,
    String? samajWebsite,
    dynamic createdAt,
    dynamic updatedAt,
  }) =>
      Data(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        state: state ?? this.state,
        district: district ?? this.district,
        city: city ?? this.city,
        pincode: pincode ?? this.pincode,
        phone: phone ?? this.phone,
        emailId: emailId ?? this.emailId,
        mobileStatus: mobileStatus ?? this.mobileStatus,
        mainContactName: mainContactName ?? this.mainContactName,
        mainContactNumber: mainContactNumber ?? this.mainContactNumber,
        authoriseLetter: authoriseLetter ?? this.authoriseLetter,
        samajLogo: samajLogo ?? this.samajLogo,
        samajWebsite: samajWebsite ?? this.samajWebsite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        address: json["address"],
        state: json["state"],
        district: json["district"],
        city: json["city"],
        pincode: json["pincode"],
        phone: json["phone"],
        emailId: json["email_id"],
        mobileStatus: json["mobile_status"],
        mainContactName: json["main_contact_name"],
        mainContactNumber: json["main_contact_number"],
        authoriseLetter: json["authorise_letter"],
        samajLogo: json["samaj_logo"],
        samajWebsite: json["samaj_website"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "address": address,
        "state": state,
        "district": district,
        "city": city,
        "pincode": pincode,
        "phone": phone,
        "email_id": emailId,
        "mobile_status": mobileStatus,
        "main_contact_name": mainContactName,
        "main_contact_number": mainContactNumber,
        "authorise_letter": authoriseLetter,
        "samaj_logo": samajLogo,
        "samaj_website": samajWebsite,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
