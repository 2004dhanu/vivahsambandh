// Define the enum
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum PermittedAfterMarriageType {
  yesBusinessOrService,
  yesBusinessOnly,
  yesPrivateServiceOnly,
  yesGovtServiceOnly,
  no,
  flexibleToDiscuss,
}

// Map enum values to strings
extension PermittedAfterMarriageTypeExtension on PermittedAfterMarriageType {
  String get displayValue {
    switch (this) {
      case PermittedAfterMarriageType.yesBusinessOrService:
        return 'Yes (Business or Service)';
      case PermittedAfterMarriageType.yesBusinessOnly:
        return 'Yes (Business only)';
      case PermittedAfterMarriageType.yesPrivateServiceOnly:
        return 'Yes (Private Service only)';
      case PermittedAfterMarriageType.yesGovtServiceOnly:
        return 'Yes (Govt. Service only)';
      case PermittedAfterMarriageType.no:
        return 'No';
      case PermittedAfterMarriageType.flexibleToDiscuss:
        return 'We are flexible to discuss this';
    }
  }
}

class PartnerPreferences {
  RxString marrySameGotra = ''.obs; // Default empty string
  RxString willYouMatchingGanna = ''.obs; // Default empty string
  RxString areYouManglik = ''.obs; // Default empty string
  RxString areYouMarryAManglik = ''.obs; // Default empty string
  RxString spouseOlderBy = ''.obs; // Default empty string
  RxString spouseYoungerBy = ''.obs; // Default empty string
  RxString budgetOfBride = ''.obs; // Default empty string
  RxString budgetOfGroom = ''.obs; // Default empty string
  RxString bridePermittedWork = ''.obs; // Default empty string
  RxString comPref = ''.obs; // Default empty string
  RxString divorceStatus = ''.obs; // Default empty string
  RxString childrenWith = ''.obs; // Default empty string
  Rx<TextEditingController> placeOfResidenceAfterMarriage =
      TextEditingController().obs;
  Rx<TextEditingController> yearAtTheAdd = TextEditingController().obs;
  Rx<TextEditingController> childrenCon = TextEditingController().obs;

  PartnerPreferences();
}
