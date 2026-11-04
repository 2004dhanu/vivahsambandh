import 'package:flutter/material.dart';

class MemberItemModel {
  final int id;
  final String name;
  final String gender;
  final String? dateOfBirth;
  final String? heightFeet;
  final String? heightInch;
  final String? userCurrentCity;
  String? multipleCity; // mutable for in-place updates
  final String? userAddress;
  final String? marriedBefore;
  final String? faceImage;
  final int userType;
  String status; // mutable for in-place UI updates upon status change
  final int? educationId;
  final String? educationName;
  final int? professionId;
  final String? professionName;
  final int? communityId;
  final String? communityName;
  final int? gotraId;
  final String? gotraName;
  final String? marryInCommunity;
  final String? marryMultiCommunity;
  final String? contactName;
  final String? mobile;
  final String? alternateContactName;
  final String? alternateMobileNo;
  final String? email;
  final String? physicalDisability;
  final String? registerDate;

  final String? timeOfBirth;
  final String? placeOfBirth;
  final String? fullImage;
  final String? companyName;
  final String? companyType;
  final String? annualIncome;
  final String? fatherName;
  final String? motherName;
  final String? brotherMarried;
  final String? brotherUnMarried;
  final String? sisterMarried;
  final String? sisterUnMarried;
  final String? houseType;
  final String? divorceStatus;
  final String? childrenFromPriorMarriage;
  final String? childrenWith;
  final String? willMarrySameGotra;
  final String? isManglik;
  final String? willMarryManglik;
  final String? userSummary;
  final String? remarks;
  final dynamic paymentDetails;

  MemberItemModel({
    required this.id,
    required this.name,
    required this.gender,
    this.dateOfBirth,
    this.heightFeet,
    this.heightInch,
    this.userCurrentCity,
    this.multipleCity,
    this.userAddress,
    this.marriedBefore,
    this.faceImage,
    required this.userType,
    required this.status,
    this.educationId,
    this.educationName,
    this.professionId,
    this.professionName,
    this.communityId,
    this.communityName,
    this.gotraId,
    this.gotraName,
    this.marryInCommunity,
    this.marryMultiCommunity,
    this.contactName,
    this.mobile,
    this.alternateContactName,
    this.alternateMobileNo,
    this.email,
    this.physicalDisability,
    this.registerDate,
    this.timeOfBirth,
    this.placeOfBirth,
    this.fullImage,
    this.companyName,
    this.companyType,
    this.annualIncome,
    this.fatherName,
    this.motherName,
    this.brotherMarried,
    this.brotherUnMarried,
    this.sisterMarried,
    this.sisterUnMarried,
    this.houseType,
    this.divorceStatus,
    this.childrenFromPriorMarriage,
    this.childrenWith,
    this.willMarrySameGotra,
    this.isManglik,
    this.willMarryManglik,
    this.userSummary,
    this.remarks,
    this.paymentDetails,
  });

  String get heightDisplay {
    final feet = heightFeet ?? '0';
    final inch = heightInch ?? '0';
    if (feet == '0' && inch == '0') return 'Not specified';
    return '$feet ft $inch in';
  }

  String get ageDisplay {
    if (dateOfBirth == null || dateOfBirth!.isEmpty) return '';
    try {
      final dob = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age > 0 ? '$age yrs' : '';
    } catch (_) {
      return '';
    }
  }

  String getImageUrl(String? baseUserImageUrl) {
    if (faceImage == null || faceImage!.isEmpty) {
      return '';
    }
    final base = (baseUserImageUrl != null && baseUserImageUrl.isNotEmpty)
        ? baseUserImageUrl
        : 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
    return base.endsWith('/') ? '$base$faceImage' : '$base/$faceImage';
  }

  String getFullImageUrl(String? baseUserImageUrl) {
    if (fullImage == null || fullImage!.isEmpty) {
      return getImageUrl(baseUserImageUrl);
    }
    final base = (baseUserImageUrl != null && baseUserImageUrl.isNotEmpty)
        ? baseUserImageUrl
        : 'https://vivahsambandh.com/crmapi/public/assets/images/users_images/';
    return base.endsWith('/') ? '$base$fullImage' : '$base/$fullImage';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50); // Green
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'hold':
        return const Color(0xFF2196F3); // Blue
      case 'married':
        return const Color(0xFF9C27B0); // Purple
      case 'cancel':
        return const Color(0xFFE53935); // Red
      default:
        return Colors.grey;
    }
  }

  factory MemberItemModel.fromJson(Map<String, dynamic> json) {
    String? eduName;
    if (json['education'] is Map) {
      eduName = json['education']['education_name']?.toString();
    }

    String? profName;
    if (json['profession'] is Map) {
      profName = json['profession']['profession_name']?.toString();
    }

    String? commName;
    if (json['community'] is Map) {
      commName = json['community']['community_name']?.toString();
    }

    String? gName;
    if (json['gotra'] is Map) {
      gName = json['gotra']['gotra_name']?.toString();
    }

    return MemberItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString(),
      heightFeet: json['height_feet']?.toString(),
      heightInch: json['height_inch']?.toString(),
      userCurrentCity: json['user_current_city']?.toString(),
      multipleCity: json['multiple_city']?.toString() ?? json['user_current_city']?.toString(),
      userAddress: json['user_address']?.toString(),
      marriedBefore: json['married_before']?.toString(),
      faceImage: json['face_image']?.toString(),
      userType: json['user_type'] is int
          ? json['user_type']
          : int.tryParse(json['user_type']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'Pending',
      educationId: json['education_id'] is int
          ? json['education_id']
          : int.tryParse(json['education_id']?.toString() ?? ''),
      educationName: eduName,
      professionId: json['profession_id'] is int
          ? json['profession_id']
          : int.tryParse(json['profession_id']?.toString() ?? ''),
      professionName: profName,
      communityId: json['community_id'] is int
          ? json['community_id']
          : int.tryParse(json['community_id']?.toString() ?? ''),
      communityName: commName,
      gotraId: json['gotra_id'] is int
          ? json['gotra_id']
          : int.tryParse(json['gotra_id']?.toString() ?? ''),
      gotraName: gName,
      marryInCommunity: json['marry_in_community']?.toString(),
      marryMultiCommunity: json['marry_multi_community']?.toString(),
      contactName: json['contact_name']?.toString(),
      mobile: json['mobile']?.toString(),
      alternateContactName: json['alternate_contact_name']?.toString(),
      alternateMobileNo: json['alternate_mobile_no']?.toString(),
      email: json['email']?.toString(),
      physicalDisability: json['physical_disablity']?.toString(),
      registerDate: json['register_date']?.toString(),
      timeOfBirth: json['time_of_birth']?.toString(),
      placeOfBirth: json['place_of_birth']?.toString(),
      fullImage: json['full_image']?.toString(),
      companyName: json['company_name']?.toString(),
      companyType: json['company_type']?.toString(),
      annualIncome: json['annual_income']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      brotherMarried: json['brother_married']?.toString(),
      brotherUnMarried: json['brother_un_married']?.toString(),
      sisterMarried: json['sister_married']?.toString(),
      sisterUnMarried: json['sister_un_married']?.toString(),
      houseType: json['house_type']?.toString(),
      divorceStatus: json['divorce_status']?.toString(),
      childrenFromPriorMarriage: json['children_from_prior_marriage']?.toString(),
      childrenWith: json['children_with']?.toString(),
      willMarrySameGotra: json['will_marry_same_gotra']?.toString(),
      isManglik: json['is_manglik']?.toString(),
      willMarryManglik: json['will_marry_manglik']?.toString(),
      userSummary: json['user_summary']?.toString(),
      remarks: json['remarks']?.toString(),
      paymentDetails: json['payment_details'] ?? json['payments'] ?? json['paymentDetails'],
    );
  }
}
