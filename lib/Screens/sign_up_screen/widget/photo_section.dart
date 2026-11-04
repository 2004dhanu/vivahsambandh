import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/const_helper.dart';
import '../../../utils/photo_view_page.dart';

class PhotoSection extends StatelessWidget {
  final String title;
  final RxString selectedPhotoPath;
  final BuildContext context;

  const PhotoSection({
    super.key,
    required this.title,
    required this.selectedPhotoPath,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: ConstHelper.whiteColor,
              fontWeight: FontWeight.w600,
              fontSize: Get.width * 0.035,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: Get.width / 30),
          Obx(() => Center(
                child: SizedBox(
                  height: Get.width / 2.3,
                  width: Get.width / 2.3,
                  child: Stack(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedPhotoPath.value.trim().isNotEmpty) {
                              Get.to(PhotoViewPage(
                                  imagePath: selectedPhotoPath.value));
                            }
                          },
                          child: Container(
                            height: Get.width / 2.3,
                            width: Get.width / 2.3,
                            decoration: BoxDecoration(
                              border: Border.all(color: ConstHelper.whiteColor),
                              shape: BoxShape.circle,
                              image: selectedPhotoPath.value.trim().isEmpty
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(
                                          File(selectedPhotoPath.value)),
                                    ),
                            ),
                            child: selectedPhotoPath.value.trim().isNotEmpty
                                ? null
                                : Center(
                                    child: SvgPicture.asset(
                                      'assets/image/personWithRoundedSVG.svg',
                                      height: Get.width / 3.5,
                                      width: Get.width / 3.5,
                                      fit: BoxFit.contain,
                                      colorFilter: ColorFilter.mode(
                                        ConstHelper.cementColor,
                                        BlendMode.srcIn, // ✅ replaces old "color"
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: Get.width / 50,
                            bottom: Get.width / 50,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return IntrinsicHeight(
                                    child: Container(
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: ConstHelper.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                      ),
                                      padding: EdgeInsets.all(Get.width / 30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Choose',
                                            style: TextStyle(
                                              color: ConstHelper.blackColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: Get.width * 0.05,
                                            ),
                                          ),
                                          SizedBox(height: Get.width / 30),
                                          Row(
                                            children: [
                                              _option(Icons.camera_alt_rounded,
                                                  'Camera', ImageSource.camera),
                                              SizedBox(width: Get.width / 20),
                                              _option(
                                                  Icons.photo_rounded,
                                                  'Gallery',
                                                  ImageSource.gallery),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ConstHelper.orangeColor,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(Get.width / 60),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: ConstHelper.whiteColor,
                                size: Get.width / 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _option(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        selectedPhotoPath.value =
            await ConstHelper.constHelper.pickImage(source: source);
        if (selectedPhotoPath.value.trim().isNotEmpty) {
          Get.back();
        }
      },
      child: Column(
        children: [
          Icon(icon, color: ConstHelper.orangeColor, size: Get.width / 18),
          Text(
            label,
            style: TextStyle(
              color: ConstHelper.orangeColor,
              fontWeight: FontWeight.w500,
              fontSize: Get.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

// Usage
/*print('membersDataModel: ${{
        'fname': membersDataModel.name,
        'gender': membersDataModel.profileGender,
        'dobs': DateFormat('yyyy-MM-dd')
            .format(membersDataModel.profileDateOfBirth ?? DateTime.now()),
        'birthtime': membersDataModel.profileTimeOfBirth,
        'placeofBirth': membersDataModel.profilePlaceOfBirth,
        'heightFeet': membersDataModel.profileHeight,
        'heightInch': membersDataModel.profileHeightInch,
        'email': membersDataModel.email,
        'eduqualification': membersDataModel.profileEducation,
        'eduqualification_other': "",
        'profession': membersDataModel.profileOccupation,
        'gotra': membersDataModel.profileGotra,
        'otherProfession': "",
        'businessName': "",
        'businessType': "",
        'compName': "",
        'compType': "",
        'incomeLakh': "",
        'community': membersDataModel.profileComunityName,
        'profile_physical_disablity': membersDataModel.profilePhysicalDisablity,
        'profile_marry_in_comunity': "",
        'fatherName': membersDataModel.profileFatherFullName,
        'brief_father_profession': "",
        'motherName': "",
        'marriedbrother': "",
        'unmarriedbrother': '',
        'isManglik': '',
        'sameGothra': '',
        'matchGanna': '',
        'marryManglik': '',
        'profile_mobile': membersDataModel.profileMobile,
        'profile_whatsapp': membersDataModel.profileWhatsapp,
        'mainContactNum': membersDataModel.profileMainContactNum,
        'mainContactName': "",
        'altContactName': membersDataModel.profileRefContactName,
        'alterCnctNum': membersDataModel.profileRefContactMobile,
        'profile_have_married_before':
            membersDataModel.profileHaveMarriedBefore,
        'profile_working_city': membersDataModel.profileWorkingCity,
        'resAddress': membersDataModel.profilePermanentAddress,
        'profile_note': membersDataModel.profileNote,
        'numYraddrs': "",
        'ownrent': "",
        'marriedBfor': "",
        'divorceStatus': "",
        'children': "",
        'childrenWith': "",
        'olderBy': "",
        'youngerBy': "",
        'resaftrMarrige': "",
        'workAftrMarrige': "",
        'groombudget': "",
        'bridebudget': "",
        'facePhoto': profilePhoto.isEmpty
            ? ''
            : await MultipartFile.fromFile(
                profilePhoto,
                filename: profilePhoto.split('/').isEmpty
                    ? null
                    : profilePhoto.split('/').last,
              ),
      }.toString()}');*/
