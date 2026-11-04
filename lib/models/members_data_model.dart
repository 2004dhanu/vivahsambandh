// To parse this JSON data, do
//
//     final membersModel = membersModelFromJson(jsonString);

import 'dart:convert';

MembersModel membersModelFromJson(String str) =>
    MembersModel.fromJson(json.decode(str));

String membersModelToJson(MembersModel data) => json.encode(data.toJson());

class MembersModel {
  int? code;
  String? msg;
  List<MembersDataModel>? data;

  MembersModel({
    this.code,
    this.msg,
    this.data,
  });

  MembersModel copyWith({
    int? code,
    String? msg,
    List<MembersDataModel>? data,
  }) =>
      MembersModel(
        code: code ?? this.code,
        msg: msg ?? this.msg,
        data: data ?? this.data,
      );

  factory MembersModel.fromJson(Map<String, dynamic> json) => MembersModel(
        code: json["code"],
        msg: json["msg"],
        data: json["data"] == null
            ? []
            : List<MembersDataModel>.from(
                json["data"]!.map((x) => MembersDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "msg": msg,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class MembersDataModel {
  int? id;
  String? name;
  String? profileFirstName;
  String? email;
  String? profilePassword;
  String? profileGender;
  int? profileHeight;
  DateTime? profileDateOfBirth;
  String? profileTimeOfBirth;
  String? profilePlaceOfBirth;
  String? profileEducationCatogery;
  String? profileEducationQualification;
  dynamic profileEduqualificationOther;
  dynamic profileProfession;
  String? profileProfessionOrgName;
  String? profileProfessionOrgType;
  int? profileProfessionAnnualNetIncome;
  String? profileProfessionOthers;
  String? profileFatherFullName;
  String? profileMotherFullName;
  String? profileMarriedBrother;
  String? profileUnmarriedBrother;
  String? profileMarriedSister;
  String? profileUnmarriedSister;
  String? profileMainContactFullName;
  String? profileMainContactNum;
  String? profileAlternateContactFullName;
  dynamic profileAlternateContactNum;
  String? profileCurrentResidAddress;
  dynamic profileNumOfYearsAtThisAddress;
  dynamic profileHouseType;
  String? profilePresentCity;
  dynamic profileHaveMarriedBefore;
  String? profileDivorceStatus;
  dynamic profileSpouseDied;
  String? profileChildrenNumFromPrevMarriage;
  String? profileChildrenWith;
  String? profileComunityName;
  String? profileGotra;
  String? profileMarryInComunity;
  dynamic profileWillMarryInSameGotra;
  dynamic profileIsManglik;
  dynamic profileWillMarryManglink;
  dynamic profileWillMatchGanna;
  dynamic profileSpouseCanBeOlderBy;
  dynamic profileSpouseCanBeYoungerBy;
  dynamic profileBridePermittedToWorkAfterMarriage;
  String? profilePlaceOfResidAfterMarriage;
  String? profileBudgetCategoryId;
  String? profileGroomBudgetCategoryId;
  String? profileFullLengthPhotoFileName;
  String? profileFullLengthPhoto;
  String? profileFullFacePhotoFileName;
  String? profilePhysicalDisablity;
  String? profileSamajId;
  int? profileType;
  String? profileViewFlag;
  DateTime? profileRegistrationDate;
  DateTime? profileModifyDate;
  String? profileDeviceId;
  dynamic deviceIdCount;
  DateTime? profileLastLogin;
  String? profileLoginFlag;
  String? profilePackageCategory;
  DateTime? profileValidityEnds;
  String? profileApproved;
  dynamic sNotification;
  dynamic sEmail;
  dynamic sSms;
  dynamic sWhatsapp;
  dynamic schoolName;
  dynamic schoolCity;
  dynamic collageName;
  dynamic collageCity;
  dynamic briefFatherProfession;
  dynamic briefFamilyHistory;
  dynamic briefAfterTenYears;
  String? profileMarriedStatus;
  dynamic paymentAmount;
  dynamic paymentMethod;
  dynamic paymentDate;
  dynamic paymentReference;
  dynamic paymentReceived;
  dynamic paymentEmailCount;
  dynamic emailVerifiedAt;
  dynamic emailSent;
  dynamic token;
  dynamic pv;
  dynamic profileNote;
  DateTime? createdAt;
  dynamic createdBy;
  DateTime? updatedAt;
  dynamic updatedBy;
  BudgetCategories? budgetCategories;
  BudgetCategories? budgetCategories1;

  MembersDataModel({
    this.id,
    this.name,
    this.profileFirstName,
    this.email,
    this.profilePassword,
    this.profileGender,
    this.profileHeight,
    this.profileDateOfBirth,
    this.profileTimeOfBirth,
    this.profilePlaceOfBirth,
    this.profileEducationCatogery,
    this.profileEducationQualification,
    this.profileEduqualificationOther,
    this.profileProfession,
    this.profileProfessionOrgName,
    this.profileProfessionOrgType,
    this.profileProfessionAnnualNetIncome,
    this.profileProfessionOthers,
    this.profileFatherFullName,
    this.profileMotherFullName,
    this.profileMarriedBrother,
    this.profileUnmarriedBrother,
    this.profileMarriedSister,
    this.profileUnmarriedSister,
    this.profileMainContactFullName,
    this.profileMainContactNum,
    this.profileAlternateContactFullName,
    this.profileAlternateContactNum,
    this.profileCurrentResidAddress,
    this.profileNumOfYearsAtThisAddress,
    this.profileHouseType,
    this.profilePresentCity,
    this.profileHaveMarriedBefore,
    this.profileDivorceStatus,
    this.profileSpouseDied,
    this.profileChildrenNumFromPrevMarriage,
    this.profileChildrenWith,
    this.profileComunityName,
    this.profileGotra,
    this.profileMarryInComunity,
    this.profileWillMarryInSameGotra,
    this.profileIsManglik,
    this.profileWillMarryManglink,
    this.profileWillMatchGanna,
    this.profileSpouseCanBeOlderBy,
    this.profileSpouseCanBeYoungerBy,
    this.profileBridePermittedToWorkAfterMarriage,
    this.profilePlaceOfResidAfterMarriage,
    this.profileBudgetCategoryId,
    this.profileGroomBudgetCategoryId,
    this.profileFullLengthPhotoFileName,
    this.profileFullLengthPhoto,
    this.profileFullFacePhotoFileName,
    this.profilePhysicalDisablity,
    this.profileSamajId,
    this.profileType,
    this.profileViewFlag,
    this.profileRegistrationDate,
    this.profileModifyDate,
    this.profileDeviceId,
    this.deviceIdCount,
    this.profileLastLogin,
    this.profileLoginFlag,
    this.profilePackageCategory,
    this.profileValidityEnds,
    this.profileApproved,
    this.sNotification,
    this.sEmail,
    this.sSms,
    this.sWhatsapp,
    this.schoolName,
    this.schoolCity,
    this.collageName,
    this.collageCity,
    this.briefFatherProfession,
    this.briefFamilyHistory,
    this.briefAfterTenYears,
    this.profileMarriedStatus,
    this.paymentAmount,
    this.paymentMethod,
    this.paymentDate,
    this.paymentReference,
    this.paymentReceived,
    this.paymentEmailCount,
    this.emailVerifiedAt,
    this.emailSent,
    this.token,
    this.pv,
    this.profileNote,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.budgetCategories,
    this.budgetCategories1,
  });

  MembersDataModel copyWith({
    int? id,
    String? name,
    String? profileFirstName,
    String? email,
    String? profilePassword,
    String? profileGender,
    int? profileHeight,
    DateTime? profileDateOfBirth,
    String? profileTimeOfBirth,
    String? profilePlaceOfBirth,
    String? profileEducationCatogery,
    String? profileEducationQualification,
    dynamic profileEduqualificationOther,
    dynamic profileProfession,
    String? profileProfessionOrgName,
    String? profileProfessionOrgType,
    int? profileProfessionAnnualNetIncome,
    String? profileProfessionOthers,
    String? profileFatherFullName,
    String? profileMotherFullName,
    String? profileMarriedBrother,
    String? profileUnmarriedBrother,
    String? profileMarriedSister,
    String? profileUnmarriedSister,
    String? profileMainContactFullName,
    String? profileMainContactNum,
    String? profileAlternateContactFullName,
    dynamic profileAlternateContactNum,
    String? profileCurrentResidAddress,
    dynamic profileNumOfYearsAtThisAddress,
    dynamic profileHouseType,
    String? profilePresentCity,
    dynamic profileHaveMarriedBefore,
    String? profileDivorceStatus,
    dynamic profileSpouseDied,
    String? profileChildrenNumFromPrevMarriage,
    String? profileChildrenWith,
    String? profileComunityName,
    String? profileGotra,
    String? profileMarryInComunity,
    dynamic profileWillMarryInSameGotra,
    dynamic profileIsManglik,
    dynamic profileWillMarryManglink,
    dynamic profileWillMatchGanna,
    dynamic profileSpouseCanBeOlderBy,
    dynamic profileSpouseCanBeYoungerBy,
    dynamic profileBridePermittedToWorkAfterMarriage,
    String? profilePlaceOfResidAfterMarriage,
    String? profileBudgetCategoryId,
    String? profileGroomBudgetCategoryId,
    String? profileFullLengthPhotoFileName,
    String? profileFullLengthPhoto,
    String? profileFullFacePhotoFileName,
    String? profilePhysicalDisablity,
    String? profileSamajId,
    int? profileType,
    String? profileViewFlag,
    DateTime? profileRegistrationDate,
    DateTime? profileModifyDate,
    String? profileDeviceId,
    dynamic deviceIdCount,
    DateTime? profileLastLogin,
    String? profileLoginFlag,
    String? profilePackageCategory,
    DateTime? profileValidityEnds,
    String? profileApproved,
    dynamic sNotification,
    dynamic sEmail,
    dynamic sSms,
    dynamic sWhatsapp,
    dynamic schoolName,
    dynamic schoolCity,
    dynamic collageName,
    dynamic collageCity,
    dynamic briefFatherProfession,
    dynamic briefFamilyHistory,
    dynamic briefAfterTenYears,
    String? profileMarriedStatus,
    dynamic paymentAmount,
    dynamic paymentMethod,
    dynamic paymentDate,
    dynamic paymentReference,
    dynamic paymentReceived,
    dynamic paymentEmailCount,
    dynamic emailVerifiedAt,
    dynamic emailSent,
    dynamic token,
    dynamic pv,
    dynamic profileNote,
    DateTime? createdAt,
    dynamic createdBy,
    DateTime? updatedAt,
    dynamic updatedBy,
    BudgetCategories? budgetCategories,
    BudgetCategories? budgetCategories1,
  }) =>
      MembersDataModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profileFirstName: profileFirstName ?? this.profileFirstName,
        email: email ?? this.email,
        profilePassword: profilePassword ?? this.profilePassword,
        profileGender: profileGender ?? this.profileGender,
        profileHeight: profileHeight ?? this.profileHeight,
        profileDateOfBirth: profileDateOfBirth ?? this.profileDateOfBirth,
        profileTimeOfBirth: profileTimeOfBirth ?? this.profileTimeOfBirth,
        profilePlaceOfBirth: profilePlaceOfBirth ?? this.profilePlaceOfBirth,
        profileEducationCatogery:
            profileEducationCatogery ?? this.profileEducationCatogery,
        profileEducationQualification:
            profileEducationQualification ?? this.profileEducationQualification,
        profileEduqualificationOther:
            profileEduqualificationOther ?? this.profileEduqualificationOther,
        profileProfession: profileProfession ?? this.profileProfession,
        profileProfessionOrgName:
            profileProfessionOrgName ?? this.profileProfessionOrgName,
        profileProfessionOrgType:
            profileProfessionOrgType ?? this.profileProfessionOrgType,
        profileProfessionAnnualNetIncome: profileProfessionAnnualNetIncome ??
            this.profileProfessionAnnualNetIncome,
        profileProfessionOthers:
            profileProfessionOthers ?? this.profileProfessionOthers,
        profileFatherFullName:
            profileFatherFullName ?? this.profileFatherFullName,
        profileMotherFullName:
            profileMotherFullName ?? this.profileMotherFullName,
        profileMarriedBrother:
            profileMarriedBrother ?? this.profileMarriedBrother,
        profileUnmarriedBrother:
            profileUnmarriedBrother ?? this.profileUnmarriedBrother,
        profileMarriedSister: profileMarriedSister ?? this.profileMarriedSister,
        profileUnmarriedSister:
            profileUnmarriedSister ?? this.profileUnmarriedSister,
        profileMainContactFullName:
            profileMainContactFullName ?? this.profileMainContactFullName,
        profileMainContactNum:
            profileMainContactNum ?? this.profileMainContactNum,
        profileAlternateContactFullName: profileAlternateContactFullName ??
            this.profileAlternateContactFullName,
        profileAlternateContactNum:
            profileAlternateContactNum ?? this.profileAlternateContactNum,
        profileCurrentResidAddress:
            profileCurrentResidAddress ?? this.profileCurrentResidAddress,
        profileNumOfYearsAtThisAddress: profileNumOfYearsAtThisAddress ??
            this.profileNumOfYearsAtThisAddress,
        profileHouseType: profileHouseType ?? this.profileHouseType,
        profilePresentCity: profilePresentCity ?? this.profilePresentCity,
        profileHaveMarriedBefore:
            profileHaveMarriedBefore ?? this.profileHaveMarriedBefore,
        profileDivorceStatus: profileDivorceStatus ?? this.profileDivorceStatus,
        profileSpouseDied: profileSpouseDied ?? this.profileSpouseDied,
        profileChildrenNumFromPrevMarriage:
            profileChildrenNumFromPrevMarriage ??
                this.profileChildrenNumFromPrevMarriage,
        profileChildrenWith: profileChildrenWith ?? this.profileChildrenWith,
        profileComunityName: profileComunityName ?? this.profileComunityName,
        profileGotra: profileGotra ?? this.profileGotra,
        profileMarryInComunity:
            profileMarryInComunity ?? this.profileMarryInComunity,
        profileWillMarryInSameGotra:
            profileWillMarryInSameGotra ?? this.profileWillMarryInSameGotra,
        profileIsManglik: profileIsManglik ?? this.profileIsManglik,
        profileWillMarryManglink:
            profileWillMarryManglink ?? this.profileWillMarryManglink,
        profileWillMatchGanna:
            profileWillMatchGanna ?? this.profileWillMatchGanna,
        profileSpouseCanBeOlderBy:
            profileSpouseCanBeOlderBy ?? this.profileSpouseCanBeOlderBy,
        profileSpouseCanBeYoungerBy:
            profileSpouseCanBeYoungerBy ?? this.profileSpouseCanBeYoungerBy,
        profileBridePermittedToWorkAfterMarriage:
            profileBridePermittedToWorkAfterMarriage ??
                this.profileBridePermittedToWorkAfterMarriage,
        profilePlaceOfResidAfterMarriage: profilePlaceOfResidAfterMarriage ??
            this.profilePlaceOfResidAfterMarriage,
        profileBudgetCategoryId:
            profileBudgetCategoryId ?? this.profileBudgetCategoryId,
        profileGroomBudgetCategoryId:
            profileGroomBudgetCategoryId ?? this.profileGroomBudgetCategoryId,
        profileFullLengthPhotoFileName: profileFullLengthPhotoFileName ??
            this.profileFullLengthPhotoFileName,
        profileFullLengthPhoto:
            profileFullLengthPhoto ?? this.profileFullLengthPhoto,
        profileFullFacePhotoFileName:
            profileFullFacePhotoFileName ?? this.profileFullFacePhotoFileName,
        profilePhysicalDisablity:
            profilePhysicalDisablity ?? this.profilePhysicalDisablity,
        profileSamajId: profileSamajId ?? this.profileSamajId,
        profileType: profileType ?? this.profileType,
        profileViewFlag: profileViewFlag ?? this.profileViewFlag,
        profileRegistrationDate:
            profileRegistrationDate ?? this.profileRegistrationDate,
        profileModifyDate: profileModifyDate ?? this.profileModifyDate,
        profileDeviceId: profileDeviceId ?? this.profileDeviceId,
        deviceIdCount: deviceIdCount ?? this.deviceIdCount,
        profileLastLogin: profileLastLogin ?? this.profileLastLogin,
        profileLoginFlag: profileLoginFlag ?? this.profileLoginFlag,
        profilePackageCategory:
            profilePackageCategory ?? this.profilePackageCategory,
        profileValidityEnds: profileValidityEnds ?? this.profileValidityEnds,
        profileApproved: profileApproved ?? this.profileApproved,
        sNotification: sNotification ?? this.sNotification,
        sEmail: sEmail ?? this.sEmail,
        sSms: sSms ?? this.sSms,
        sWhatsapp: sWhatsapp ?? this.sWhatsapp,
        schoolName: schoolName ?? this.schoolName,
        schoolCity: schoolCity ?? this.schoolCity,
        collageName: collageName ?? this.collageName,
        collageCity: collageCity ?? this.collageCity,
        briefFatherProfession:
            briefFatherProfession ?? this.briefFatherProfession,
        briefFamilyHistory: briefFamilyHistory ?? this.briefFamilyHistory,
        briefAfterTenYears: briefAfterTenYears ?? this.briefAfterTenYears,
        profileMarriedStatus: profileMarriedStatus ?? this.profileMarriedStatus,
        paymentAmount: paymentAmount ?? this.paymentAmount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentDate: paymentDate ?? this.paymentDate,
        paymentReference: paymentReference ?? this.paymentReference,
        paymentReceived: paymentReceived ?? this.paymentReceived,
        paymentEmailCount: paymentEmailCount ?? this.paymentEmailCount,
        emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
        emailSent: emailSent ?? this.emailSent,
        token: token ?? this.token,
        pv: pv ?? this.pv,
        profileNote: profileNote ?? this.profileNote,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
        budgetCategories: budgetCategories ?? this.budgetCategories,
        budgetCategories1: budgetCategories1 ?? this.budgetCategories1,
      );

  factory MembersDataModel.fromJson(Map<String, dynamic> json) =>
      MembersDataModel(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0'),
        name: json["name"],
        profileFirstName: json["profile_first_name"] ?? json["name"],
        email: json["email"],
        profilePassword: json["profile_password"] ?? json["password"],
        profileGender: json["profile_gender"] ?? json["gender"],
        profileHeight: json["profile_height"] is int ? json["profile_height"] : int.tryParse(json["profile_height"]?.toString() ?? ''),
        profileDateOfBirth: (json["profile_date_of_birth"] ?? json["date_of_birth"]) == null
            ? null
            : DateTime.tryParse((json["profile_date_of_birth"] ?? json["date_of_birth"]).toString()),
        profileTimeOfBirth: json["profile_time_of_birth"] ?? json["time_of_birth"],
        profilePlaceOfBirth: json["profile_place_of_birth"] ?? json["place_of_birth"],
        profileEducationCatogery: json["profile_education_catogery"] ?? (json["education"] is Map ? json["education"]["education_name"] : null),
        profileEducationQualification: json["profile_education_qualification"] ?? (json["education"] is Map ? json["education"]["education_name"] : null),
        profileEduqualificationOther: json["profile_eduqualification_other"],
        profileProfession: json["profile_profession"] ?? (json["profession"] is Map ? json["profession"]["profession_name"] : null),
        profileProfessionOrgName: json["profile_profession_org_name"] ?? json["company_name"],
        profileProfessionOrgType: json["profile_profession_org_type"] ?? json["company_type"],
        profileProfessionAnnualNetIncome:
            json["profile_profession_annual_net_income"] is int ? json["profile_profession_annual_net_income"] : int.tryParse(json["annual_income"]?.toString() ?? ''),
        profileProfessionOthers: json["profile_profession_others"],
        profileFatherFullName: json["profile_father_full_name"] ?? json["father_name"],
        profileMotherFullName: json["profile_mother_full_name"] ?? json["mother_name"],
        profileMarriedBrother: json["profile_married_brother"] ?? json["brother_married"]?.toString(),
        profileUnmarriedBrother: json["profile_unmarried_brother"] ?? json["brother_un_married"]?.toString(),
        profileMarriedSister: json["profile_married_sister"] ?? json["sister_married"]?.toString(),
        profileUnmarriedSister: json["profile_unmarried_sister"] ?? json["sister_un_married"]?.toString(),
        profileMainContactFullName: json["profile_main_contact_full_name"] ?? json["contact_name"],
        profileMainContactNum: json["profile_main_contact_num"] ?? json["mobile"],
        profileAlternateContactFullName:
            json["profile_alternate_contact_full_name"] ?? json["alternate_contact_name"],
        profileAlternateContactNum: json["profile_alternate_contact_num"] ?? json["alternate_mobile_no"],
        profileCurrentResidAddress: json["profile_current_resid_address"] ?? json["user_address"],
        profileNumOfYearsAtThisAddress:
            json["profile_num_of_years_at_this_address"],
        profileHouseType: json["profile_house_type"] ?? json["house_type"],
        profilePresentCity: json["profile_present_city"] ?? json["user_current_city"],
        profileHaveMarriedBefore: json["profile_have_married_before"] ?? json["married_before"],
        profileDivorceStatus: json["profile_divorce_status"] ?? json["divorce_status"],
        profileSpouseDied: json["profile_spouse_died"],
        profileChildrenNumFromPrevMarriage:
            json["profile_children_num_from_prev_marriage"] ?? json["children_from_prior_marriage"],
        profileChildrenWith: json["profile_children_with"] ?? json["children_with"],
        profileComunityName: json["profile_comunity_name"] ?? (json["community"] is Map ? json["community"]["community_name"] : null),
        profileGotra: json["profile_gotra"] ?? (json["gotra"] is Map ? json["gotra"]["gotra_name"] : null),
        profileMarryInComunity: json["profile_marry_in_comunity"] ?? json["marry_in_community"],
        profileWillMarryInSameGotra: json["profile_will_marry_in_same_gotra"] ?? json["will_marry_same_gotra"],
        profileIsManglik: json["profile_is_manglik"] ?? json["is_manglik"],
        profileWillMarryManglink: json["profile_will_marry_manglink"] ?? json["will_marry_manglik"],
        profileWillMatchGanna: json["profile_will_match_ganna"],
        profileSpouseCanBeOlderBy: json["profile_spouse_can_be_older_by"],
        profileSpouseCanBeYoungerBy: json["profile_spouse_can_be_younger_by"],
        profileBridePermittedToWorkAfterMarriage:
            json["profile_bride_permitted_to_work_after_marriage"],
        profilePlaceOfResidAfterMarriage:
            json["profile_place_of_resid_after_marriage"],
        profileBudgetCategoryId: json["profile_budget_category_id"],
        profileGroomBudgetCategoryId: json["profile_groom_budget_category_id"],
        profileFullLengthPhotoFileName:
            json["profile_full_length_photo_file_name"] ?? json["full_image"],
        profileFullLengthPhoto: json["profile_full_length_photo"] ?? json["full_image"],
        profileFullFacePhotoFileName: json["profile_full_face_photo_file_name"] ?? json["face_image"],
        profilePhysicalDisablity: json["profile_physical_disablity"] ?? json["physical_disablity"],
        profileSamajId: json["profile_samaj_id"],
        profileType: int.tryParse((json["profile_type"] ?? json["user_type"])?.toString() ?? ''),
        profileViewFlag: json["profile_view_flag"],
        profileRegistrationDate: (json["profile_registration_date"] ?? json["register_date"]) == null
            ? null
            : DateTime.tryParse((json["profile_registration_date"] ?? json["register_date"]).toString()),
        profileModifyDate: json["profile_modify_date"] == null ||
                json["profile_modify_date"].toString() == ""
            ? null
            : DateTime.tryParse(json["profile_modify_date"].toString()),
        profileDeviceId: json["profile_device_id"] ?? json["device_id"],
        deviceIdCount: json["device_id_count"],
        profileLastLogin: json["profile_last_login"] == null ||
                json["profile_last_login"].toString().isEmpty
            ? null
            : DateTime.parse(json["profile_last_login"]),
        profileLoginFlag: json["profile_login_flag"],
        profilePackageCategory: json["profile_package_category"],
        profileValidityEnds: json["profile_validity_ends"] == null ||
                json["profile_validity_ends"].toString().isEmpty
            ? null
            : DateTime.parse(json["profile_validity_ends"]),
        profileApproved: json["profile_approved"],
        sNotification: json["s_notification"],
        sEmail: json["s_email"],
        sSms: json["s_sms"],
        sWhatsapp: json["s_whatsapp"],
        schoolName: json["school_name"],
        schoolCity: json["school_city"],
        collageName: json["collage_name"],
        collageCity: json["collage_city"],
        briefFatherProfession: json["brief_father_profession"],
        briefFamilyHistory: json["brief_family_history"],
        briefAfterTenYears: json["brief_after_ten_years"],
        profileMarriedStatus: json["profile_married_status"],
        paymentAmount: json["payment_amount"],
        paymentMethod: json["payment_method"],
        paymentDate: json["payment_date"],
        paymentReference: json["payment_reference"],
        paymentReceived: json["payment_received"],
        paymentEmailCount: json["payment_email_count"],
        emailVerifiedAt: json["email_verified_at"],
        emailSent: json["email_sent"],
        token: json["token"],
        pv: json["pv"],
        profileNote: json["profile_note"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        createdBy: json["created_by"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        updatedBy: json["updated_by"],
        budgetCategories: json["budget__categories"] == null
            ? null
            : BudgetCategories.fromJson(json["budget__categories"]),
        budgetCategories1: json["budget__categories1"] == null
            ? null
            : BudgetCategories.fromJson(json["budget__categories1"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profile_first_name": profileFirstName,
        "email": email,
        "profile_password": profilePassword,
        "profile_gender": profileGender,
        "profile_height": profileHeight,
        "profile_date_of_birth":
            "${profileDateOfBirth!.year.toString().padLeft(4, '0')}-${profileDateOfBirth!.month.toString().padLeft(2, '0')}-${profileDateOfBirth!.day.toString().padLeft(2, '0')}",
        "profile_time_of_birth": profileTimeOfBirth,
        "profile_place_of_birth": profilePlaceOfBirth,
        "profile_education_catogery": profileEducationCatogery,
        "profile_education_qualification": profileEducationQualification,
        "profile_eduqualification_other": profileEduqualificationOther,
        "profile_profession": profileProfession,
        "profile_profession_org_name": profileProfessionOrgName,
        "profile_profession_org_type": profileProfessionOrgType,
        "profile_profession_annual_net_income":
            profileProfessionAnnualNetIncome,
        "profile_profession_others": profileProfessionOthers,
        "profile_father_full_name": profileFatherFullName,
        "profile_mother_full_name": profileMotherFullName,
        "profile_married_brother": profileMarriedBrother,
        "profile_unmarried_brother": profileUnmarriedBrother,
        "profile_married_sister": profileMarriedSister,
        "profile_unmarried_sister": profileUnmarriedSister,
        "profile_main_contact_full_name": profileMainContactFullName,
        "profile_main_contact_num": profileMainContactNum,
        "profile_alternate_contact_full_name": profileAlternateContactFullName,
        "profile_alternate_contact_num": profileAlternateContactNum,
        "profile_current_resid_address": profileCurrentResidAddress,
        "profile_num_of_years_at_this_address": profileNumOfYearsAtThisAddress,
        "profile_house_type": profileHouseType,
        "profile_present_city": profilePresentCity,
        "profile_have_married_before": profileHaveMarriedBefore,
        "profile_divorce_status": profileDivorceStatus,
        "profile_spouse_died": profileSpouseDied,
        "profile_children_num_from_prev_marriage":
            profileChildrenNumFromPrevMarriage,
        "profile_children_with": profileChildrenWith,
        "profile_comunity_name": profileComunityName,
        "profile_gotra": profileGotra,
        "profile_marry_in_comunity": profileMarryInComunity,
        "profile_will_marry_in_same_gotra": profileWillMarryInSameGotra,
        "profile_is_manglik": profileIsManglik,
        "profile_will_marry_manglink": profileWillMarryManglink,
        "profile_will_match_ganna": profileWillMatchGanna,
        "profile_spouse_can_be_older_by": profileSpouseCanBeOlderBy,
        "profile_spouse_can_be_younger_by": profileSpouseCanBeYoungerBy,
        "profile_bride_permitted_to_work_after_marriage":
            profileBridePermittedToWorkAfterMarriage,
        "profile_place_of_resid_after_marriage":
            profilePlaceOfResidAfterMarriage,
        "profile_budget_category_id": profileBudgetCategoryId,
        "profile_groom_budget_category_id": profileGroomBudgetCategoryId,
        "profile_full_length_photo_file_name": profileFullLengthPhotoFileName,
        "profile_full_length_photo": profileFullLengthPhoto,
        "profile_full_face_photo_file_name": profileFullFacePhotoFileName,
        "profile_physical_disablity": profilePhysicalDisablity,
        "profile_samaj_id": profileSamajId,
        "profile_type": profileType,
        "profile_view_flag": profileViewFlag,
        "profile_registration_date": profileRegistrationDate?.toIso8601String(),
        "profile_modify_date": profileModifyDate?.toIso8601String(),
        "profile_device_id": profileDeviceId,
        "device_id_count": deviceIdCount,
        "profile_last_login": profileLastLogin?.toIso8601String(),
        "profile_login_flag": profileLoginFlag,
        "profile_package_category": profilePackageCategory,
        "profile_validity_ends":
            "${profileValidityEnds!.year.toString().padLeft(4, '0')}-${profileValidityEnds!.month.toString().padLeft(2, '0')}-${profileValidityEnds!.day.toString().padLeft(2, '0')}",
        "profile_approved": profileApproved,
        "s_notification": sNotification,
        "s_email": sEmail,
        "s_sms": sSms,
        "s_whatsapp": sWhatsapp,
        "school_name": schoolName,
        "school_city": schoolCity,
        "collage_name": collageName,
        "collage_city": collageCity,
        "brief_father_profession": briefFatherProfession,
        "brief_family_history": briefFamilyHistory,
        "brief_after_ten_years": briefAfterTenYears,
        "profile_married_status": profileMarriedStatus,
        "payment_amount": paymentAmount,
        "payment_method": paymentMethod,
        "payment_date": paymentDate,
        "payment_reference": paymentReference,
        "payment_received": paymentReceived,
        "payment_email_count": paymentEmailCount,
        "email_verified_at": emailVerifiedAt,
        "email_sent": emailSent,
        "token": token,
        "pv": pv,
        "profile_note": profileNote,
        "created_at": createdAt?.toIso8601String(),
        "created_by": createdBy,
        "updated_at": updatedAt?.toIso8601String(),
        "updated_by": updatedBy,
        "budget__categories": budgetCategories?.toJson(),
        "budget__categories1": budgetCategories1?.toJson(),
      };
}

class BudgetCategories {
  int? id;
  String? ranges;
  String? filterIds;
  int? sort;
  DateTime? createdAt;
  dynamic updatedAt;

  BudgetCategories({
    this.id,
    this.ranges,
    this.filterIds,
    this.sort,
    this.createdAt,
    this.updatedAt,
  });

  BudgetCategories copyWith({
    int? id,
    String? ranges,
    String? filterIds,
    int? sort,
    DateTime? createdAt,
    dynamic updatedAt,
  }) =>
      BudgetCategories(
        id: id ?? this.id,
        ranges: ranges ?? this.ranges,
        filterIds: filterIds ?? this.filterIds,
        sort: sort ?? this.sort,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory BudgetCategories.fromJson(Map<String, dynamic> json) =>
      BudgetCategories(
        id: json["id"],
        ranges: json["ranges"],
        filterIds: json["filter_ids"],
        sort: json["sort"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ranges": ranges,
        "filter_ids": filterIds,
        "sort": sort,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt,
      };
}
