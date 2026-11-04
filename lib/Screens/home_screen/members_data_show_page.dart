import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../models/members_data_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/shimmer_loading.dart';
import '../my_profile_screen/edit_profile_page.dart';
import '../my_profile_screen/my_profile_page.dart';

class MembersDataShowPage extends StatefulWidget {
  const MembersDataShowPage({super.key});

  @override
  State<MembersDataShowPage> createState() => _MembersDataShowPageState();
}

class _MembersDataShowPageState extends State<MembersDataShowPage> {
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!homeController.userDataWithToken.value.isSubscribed) {
        if (mounted) {
          Get.back();
          Get.snackbar(
            'Subscription Required',
            'Not subscribed',
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    });
  }

  final RxInt selectedTabIndex = 0.obs;

  String _calculateAgeString(DateTime? dob) {
    if (dob == null || dob.year <= 0) return '';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age yrs';
  }

  void _openGallery() {
    final member = homeController.selectedMembersData.value;
    final face = (member.profileFullFacePhotoFileName != null &&
            member.profileFullFacePhotoFileName!.trim().isNotEmpty)
        ? member.profileFullFacePhotoFileName!
        : '';
    final length = (member.profileFullLengthPhotoFileName != null &&
            member.profileFullLengthPhotoFileName!.trim().isNotEmpty)
        ? (member.profileFullLengthPhoto ?? '')
        : '';
    ConstHelper.constHelper.showNetworkImageInDialog(imgPath: [face, length]);
  }

  Future<void> _openWhatsApp() async {
    try {
      final String? phoneNumber =
          homeController.selectedMembersData.value.profileMainContactNum;
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        final Uri uri =
            Uri.parse('whatsapp://send?phone=+91${phoneNumber.trim()}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ConstHelper.errorDialog(
            text: ConstHelper.somethingErrorMsg,
            seconds: 10,
          );
        }
      } else {
        ConstHelper.errorDialog(
          text: ConstHelper.mobileNoNotAvailableMsg,
          seconds: 10,
        );
      }
    } catch (error) {
      ConstHelper.errorDialog(
        text: ConstHelper.somethingErrorMsg,
        seconds: 10,
      );
    }
  }

  Future<void> _toggleShortlist() async {
    EasyLoading.show(status: ConstHelper.pleaseWaitMsg);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!(await ConstHelper.checkInternet())) {
      EasyLoading.dismiss();
      ConstHelper.errorDialog(
        text: ConstHelper.internetMsg,
        seconds: 10,
      );
      return;
    }
    final memberId =
        (homeController.selectedMembersData.value.id ?? 0).toString();
    if (homeController.profileShorted.value) {
      try {
        final data = await ApiHelper.apiHelper
            .unSetMyShortlistProfile(profileId: memberId);
        List<MembersDataModel> list =
            await ApiHelper.apiHelper.getAllShortlistedDataList();
        homeController.allShortlistedDataList.value = list;
        homeController.profileShorted.value = list.any(
            (e) => e.id == homeController.selectedMembersData.value.id);
        EasyLoading.dismiss();
        if (data['code'] == 200) {
          ConstHelper.successDialog(
            text: data['msg'] ?? 'Profile Removed from Shortlist.',
            seconds: 10,
          );
        } else {
          ConstHelper.errorDialog(
            text: data['msg'] ?? ConstHelper.somethingErrorMsg,
            seconds: 10,
          );
        }
      } catch (error) {
        EasyLoading.dismiss();
        ConstHelper.errorDialog(
          text: ConstHelper.somethingErrorMsg,
          seconds: 10,
        );
      }
    } else {
      try {
        final data = await ApiHelper.apiHelper
            .setMyShortlistProfile(profileId: memberId);
        List<MembersDataModel> list =
            await ApiHelper.apiHelper.getAllShortlistedDataList();
        homeController.allShortlistedDataList.value = list;
        homeController.profileShorted.value = list.any(
            (e) => e.id == homeController.selectedMembersData.value.id);
        EasyLoading.dismiss();
        if (data['code'] == 200) {
          ConstHelper.successDialog(
            text: data['msg'] ?? 'Profile Shortlisted Successfully.',
            seconds: 10,
          );
        } else {
          ConstHelper.errorDialog(
            text: data['msg'] ?? ConstHelper.somethingErrorMsg,
            seconds: 10,
          );
        }
      } catch (error) {
        EasyLoading.dismiss();
        ConstHelper.errorDialog(
          text: ConstHelper.somethingErrorMsg,
          seconds: 10,
        );
      }
    }
  }

  void _reportProfile() {
    showFeedbackDialog(context, false, (val) async {
      if (!(await ConstHelper.checkInternet())) {
        ConstHelper.errorDialog(text: ConstHelper.internetMsg, seconds: 10);
      } else {
        try {
          EasyLoading.show(status: ConstHelper.pleaseWaitMsg);
          final msg = await ApiHelper.apiHelper.insertFeedback(
            profileId:
                homeController.selectedMembersData.value.id!.toString(),
            description: val,
          );
          EasyLoading.dismiss();
          if (msg.trim().isEmpty) {
            ConstHelper.errorDialog(
                text: ConstHelper.somethingErrorMsg, seconds: 10);
          } else {
            Get.back();
            Get.back();
            EasyLoading.showSuccess(msg);
          }
        } catch (_) {
          EasyLoading.dismiss();
          ConstHelper.errorDialog(
              text: ConstHelper.somethingErrorMsg, seconds: 10);
        }
      }
    });
  }

  void _hideProfile() {
    showFeedbackDialog(context, true, (val) async {
      if (!(await ConstHelper.checkInternet())) {
        ConstHelper.errorDialog(text: ConstHelper.internetMsg, seconds: 10);
      } else {
        try {
          EasyLoading.show(status: ConstHelper.pleaseWaitMsg);
          final msg = await ApiHelper.apiHelper.insertFeedback(
            profileId:
                homeController.selectedMembersData.value.id!.toString(),
            description: val,
          );
          EasyLoading.dismiss();
          if (msg.trim().isEmpty) {
            ConstHelper.errorDialog(
                text: ConstHelper.somethingErrorMsg, seconds: 10);
          } else {
            Get.back();
            Get.back();
            EasyLoading.showSuccess(msg);
          }
        } catch (_) {
          EasyLoading.dismiss();
          ConstHelper.errorDialog(
              text: ConstHelper.somethingErrorMsg, seconds: 10);
        }
      }
    });
  }

  Widget _buildQuickAction({
    required Widget iconWidget,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4A4A68),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProfileCard() {
    final member = homeController.selectedMembersData.value;
    final dob = member.profileDateOfBirth;
    final ageStr = _calculateAgeString(dob);
    final dobFormatted = (dob == null || dob.year <= 0)
        ? '-'
        : DateFormat('dd MMM yyyy').format(dob);
    final memberCity = (member.profilePresentCity != null &&
            member.profilePresentCity!.trim().isNotEmpty)
        ? member.profilePresentCity!.trim()
        : (member.profileCurrentResidAddress != null &&
                member.profileCurrentResidAddress!.trim().isNotEmpty)
            ? member.profileCurrentResidAddress!.trim()
            : 'Chennai';
    final education = (member.profileEducationQualification != null &&
            member.profileEducationQualification!.trim().isNotEmpty)
        ? member.profileEducationQualification!.trim()
        : '';
    final profession = (member.profileProfession != null &&
            member.profileProfession!.trim().isNotEmpty)
        ? member.profileProfession!.trim()
        : '';
    final userId =
        (member.id == null || member.id! <= 0) ? '-' : member.id.toString();
    final memberName = (member.name == null || member.name!.trim().isEmpty)
        ? ConstHelper.nameNotAvailableMsg
        : member.name!.trim();
    final photoName = member.profileFullFacePhotoFileName;
    final photoUrl = (photoName == null || photoName.trim().isEmpty)
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${photoName.trim()}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Circular Profile Photo with pink border and green badge
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5097F),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE5097F).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const ShimmerLoading.circular(width: 90, height: 90),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/image/imageNotFound.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Right: Profile info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'User ID: $userId',
                            style: const TextStyle(
                              color: Color(0xFFE5097F),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _toggleShortlist,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE8EF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              homeController.profileShorted.value
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: const Color(0xFFE5097F),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      memberName,
                      style: const TextStyle(
                        color: Color(0xFF1E2448),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFFE5097F),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            memberCity,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Color(0xFFE5097F),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$dobFormatted ($ageStr)',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (education.isNotEmpty && education != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              education,
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (profession.isNotEmpty && profession != '-')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profession,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                iconWidget: const Icon(Icons.photo_library_rounded,
                    color: Color(0xFFE5097F), size: 20),
                bgColor: const Color(0xFFFCE4EC),
                label: 'Gallery',
                onTap: _openGallery,
              ),
              _buildQuickAction(
                iconWidget: Image.asset(
                  'assets/image/whatsapp_outlined.png',
                  color: const Color(0xFF2E7D32),
                  height: 20,
                  width: 20,
                ),
                bgColor: const Color(0xFFE8F5E9),
                label: 'WhatsApp',
                onTap: _openWhatsApp,
              ),
              _buildQuickAction(
                iconWidget: Icon(
                  homeController.profileShorted.value
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFFA000),
                  size: 22,
                ),
                bgColor: const Color(0xFFFFF8E1),
                label: 'Shortlist',
                onTap: _toggleShortlist,
              ),

              _buildQuickAction(
                iconWidget: const Icon(Icons.visibility_off_rounded,
                    color: Color(0xFF7B1FA2), size: 21),
                bgColor: const Color(0xFFF3E5F5),
                label: 'Hide Profile',
                onTap: _hideProfile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Obx(
          () => Row(
            children: [
              _buildTabPill(
                  index: 0, title: 'Personal', icon: Icons.person_rounded),
              const SizedBox(width: 8),
              _buildTabPill(
                  index: 1, title: 'Occupation', icon: Icons.work_rounded),
              const SizedBox(width: 8),
              _buildTabPill(
                  index: 2, title: 'Family', icon: Icons.groups_rounded),
              const SizedBox(width: 8),
              _buildTabPill(
                  index: 3, title: 'Kundali', icon: Icons.star_rounded),
              const SizedBox(width: 8),
              _buildTabPill(
                  index: 4, title: 'Preferences', icon: Icons.favorite_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedTabIndex.value == index;
    return InkWell(
      onTap: () {
        selectedTabIndex.value = index;
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5097F) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE5097F) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE5097F).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4A4A68),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Column(
      children: [
        InfoCard(
          icon: 'assets/image/personWithRoundedSVG.svg',
          title: "Personal Information",
          data: [
            {
              'Date of Birth': homeController.selectedMembersData.value
                          .profileDateOfBirth ==
                      null ||
                  homeController
                          .selectedMembersData.value.profileDateOfBirth!.year <=
                      0
                  ? ConstHelper.naMsg
                  : DateFormat('dd | MMM | yyyy').format(homeController
                      .selectedMembersData.value.profileDateOfBirth!)
            },
            {
              'Time of Birth': homeController.selectedMembersData.value
                              .profileTimeOfBirth ==
                          null ||
                      homeController
                          .selectedMembersData.value.profileTimeOfBirth!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : normalizeTime(homeController
                          .selectedMembersData.value.profileTimeOfBirth ??
                      '')
            },
            {
              'Place of Birth': homeController.selectedMembersData.value
                              .profilePlaceOfBirth ==
                          null ||
                      homeController
                          .selectedMembersData.value.profilePlaceOfBirth!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : homeController
                      .selectedMembersData.value.profilePlaceOfBirth!
            },
            {
              'Height': homeController.selectedMembersData.value.profileHeight ==
                          null ||
                      homeController.selectedMembersData.value.profileHeight!
                          .toString()
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : convertInchesToFeetInch(homeController
                          .selectedMembersData.value.profileHeight
                          ?.toInt() ??
                      0),
            },
            {
              "Physical Disability (If any)": homeController.selectedMembersData
                              .value.profilePhysicalDisablity ==
                          null ||
                      homeController.selectedMembersData.value
                          .profilePhysicalDisablity!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : homeController
                      .selectedMembersData.value.profilePhysicalDisablity!
            },
          ],
        ),
        if ((homeController.selectedMembersData.value
                    .profileHaveMarriedBefore ??
                "")
            .toString()
            .toLowerCase() !=
            "no")
          Stack(
            alignment: Alignment.topRight,
            children: [
              InfoCard(
                icon: 'assets/image/kundaliSVG.svg',
                title: 'Earlier Marriage',
                data: [
                  {
                    'Is Married Before': homeController
                            .selectedMembersData.value.profileHaveMarriedBefore ??
                        "-"
                  },
                  (homeController.selectedMembersData.value
                                  .profileHaveMarriedBefore ??
                              "")
                          .toString()
                          .toLowerCase() ==
                          "yes and divorced"
                      ? {
                          "Divorce Status": homeController
                                  .selectedMembersData.value.profileDivorceStatus ??
                              "-"
                        }
                      : {
                          "When Spouse Died?": homeController
                                  .selectedMembersData.value.profileSpouseDied ??
                              "-"
                        },
                  {
                    "Num. Of Children From Prev. Marriage ": homeController
                            .selectedMembersData
                            .value
                            .profileChildrenNumFromPrevMarriage ??
                        "-"
                  },
                  {
                    "Children with whom": homeController
                            .selectedMembersData.value.profileChildrenWith ??
                        "-"
                  },
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  Get.height * 0.005,
                  Get.height * 0.019,
                  0,
                ),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Image.asset(
                    "assets/image/re-marriage.png",
                    height: Get.height * 0.06,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOccupationTab() {
    return Column(
      children: [
        InfoCard(
          icon: 'assets/image/occupationSVG.svg',
          title: 'Occupation Details',
          data: [
            {
              'Qualification': homeController.selectedMembersData.value
                              .profileEducationQualification ==
                          null ||
                      homeController.selectedMembersData.value
                          .profileEducationQualification!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : homeController
                      .selectedMembersData.value.profileEducationQualification!,
            },
            {
              'Profession': homeController
                              .selectedMembersData.value.profileProfession ==
                          null ||
                      homeController
                          .selectedMembersData.value.profileProfession!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : homeController
                      .selectedMembersData.value.profileProfession!,
            },
            {
              'Organization': homeController.selectedMembersData.value
                      .profileProfessionOrgName ??
                  ConstHelper.naMsg
            },
            {
              'Org. Type': homeController
                      .selectedMembersData.value.profileProfessionOrgType ??
                  ConstHelper.naMsg
            },
            {
              'Annual Income (In lacs)': homeController.selectedMembersData.value
                      .profileProfessionAnnualNetIncome
                      ?.toString() ??
                  ConstHelper.naMsg
            },
          ],
        ),
        if ((homeController.userData.value.profileType?.toString() == "2"))
          InfoCard(
            icon: 'assets/image/ruppeSVG.svg',
            title: 'Budget Info (In lacs)',
            data: [
              {
                'Budget Bride': homeController.selectedMembersData.value
                        .profileBudgetCategoryId ??
                    ConstHelper.naMsg
              },
              {
                'Budget Groom': homeController.selectedMembersData.value
                        .profileGroomBudgetCategoryId ??
                    ConstHelper.naMsg
              },
              {
                'Profile Created': DateFormat("dd-MM-yyyy").format(
                    homeController.selectedMembersData.value
                            .profileRegistrationDate ??
                        DateTime.now()),
              },
              {
                "Update Date": DateFormat("dd-MM-yyyy").format(
                    homeController
                            .selectedMembersData.value.profileModifyDate ??
                        DateTime.now()),
              },
            ],
          ),
      ],
    );
  }

  Widget _buildFamilyTab() {
    return Column(
      children: [
        InfoCard(
          icon: 'assets/image/familySVG.svg',
          title: 'Family Details',
          data: [
            {
              'Father Name': homeController.selectedMembersData.value
                      .profileFatherFullName ??
                  ConstHelper.naMsg
            },
            {
              'Mother Name': homeController.selectedMembersData.value
                      .profileMotherFullName ??
                  ConstHelper.naMsg
            },
            {
              "Mobile (Father)": homeController.selectedMembersData.value
                      .profileMainContactNum ??
                  ConstHelper.naMsg
            },
            {
              "Mobile (Mother)":
                  "${homeController.selectedMembersData.value.profileAlternateContactNum ?? ConstHelper.naMsg}"
            },
            {
              "Brother":
                  "M - ${homeController.selectedMembersData.value.profileMarriedBrother ?? ConstHelper.naMsg}   Un M - ${homeController.selectedMembersData.value.profileUnmarriedBrother ?? ConstHelper.naMsg}"
            },
            {
              "Sister":
                  "M - ${homeController.selectedMembersData.value.profileMarriedSister ?? ConstHelper.naMsg}   Un M - ${homeController.selectedMembersData.value.profileUnmarriedSister ?? ConstHelper.naMsg}"
            },
            {
              'Current Address (${homeController.selectedMembersData.value.profileHouseType ?? ConstHelper.naMsg} - ${homeController.selectedMembersData.value.profileNumOfYearsAtThisAddress ?? ConstHelper.naMsg})':
                  homeController.selectedMembersData.value
                          .profileCurrentResidAddress ??
                      ConstHelper.naMsg
            },
          ],
        ),
        InfoCard(
          icon: 'assets/image/partnerSVG.svg',
          title: 'Contact References',
          data: [
            {
              'Name': homeController.selectedMembersData.value
                      .profileMainContactFullName ??
                  ConstHelper.naMsg
            },
            {
              'Mobile': homeController
                      .selectedMembersData.value.profileMainContactNum ??
                  ConstHelper.naMsg
            },
            {
              "Location": homeController.selectedMembersData.value
                          .profileCurrentResidAddress ??
                  ConstHelper.naMsg
            },
          ],
        ),
      ],
    );
  }

  Widget _buildKundaliTab() {
    return InfoCard(
      icon: 'assets/image/kundaliSVG.svg',
      title: 'Kundali',
      data: [
        {
          'Gotra': homeController.selectedMembersData.value.profileGotra ??
              ConstHelper.naMsg
        },
        {
          'Matching kundali': homeController
                  .selectedMembersData.value.profileWillMatchGanna ??
              ConstHelper.naMsg
        },
        {
          "Marry in same gotra": homeController
                  .selectedMembersData.value.profileMarryInComunity ??
              ConstHelper.naMsg
        },
        {
          "Are you Manglik?": homeController
                  .selectedMembersData.value.profileIsManglik ??
              ConstHelper.naMsg
        },
        {
          "Will you Marry A Manglik?": homeController
                  .selectedMembersData.value.profileWillMarryManglink ??
              ConstHelper.naMsg
        },
      ],
    );
  }

  Widget _buildPreferencesTab() {
    return Column(
      children: [
        InfoCard(
          icon: 'assets/image/partnerSVG.svg',
          title: 'Partner Preferences',
          data: [
            {
              'P. Spouse can be elder(> yrs)': homeController
                      .selectedMembersData.value.profileSpouseCanBeOlderBy ??
                  ConstHelper.naMsg
            },
            {
              'P. Spouse can be younger(< yrs)': homeController
                      .selectedMembersData.value.profileSpouseCanBeYoungerBy ??
                  ConstHelper.naMsg
            },
            {
              "Bride permitted to work after marriage?": homeController
                      .selectedMembersData
                      .value
                      .profileBridePermittedToWorkAfterMarriage ??
                  ConstHelper.naMsg
            },
            {
              "Current city":
                  homeController.selectedMembersData.value.collageCity ??
                      ConstHelper.naMsg
            },
            {
              "Resident after marriage": homeController.selectedMembersData
                      .value.profilePlaceOfResidAfterMarriage ??
                  ConstHelper.naMsg
            },
          ],
        ),
        InfoCard(
          icon: 'assets/image/aboutMeRoundedSVG.svg',
          title: 'Important Note',
          data: [
            {
              'Note': homeController.selectedMembersData.value.profileNote ==
                          null ||
                      homeController.selectedMembersData.value.profileNote!
                          .trim()
                          .isEmpty
                  ? ConstHelper.naMsg
                  : homeController.selectedMembersData.value.profileNote!,
            },
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(homeController.selectedMembersData.value.profileMainContactNum ?? "");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E2448),
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1E2448),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _reportProfile();
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF1E2448),
              ),
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFFF0F0F5),
              height: 1,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFBF8F9),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopProfileCard(),
                const SizedBox(height: 6),
                _buildTabBar(),
                const SizedBox(height: 10),
                Obx(() {
                  switch (selectedTabIndex.value) {
                    case 0:
                      return _buildPersonalTab();
                    case 1:
                      return _buildOccupationTab();
                    case 2:
                      return _buildFamilyTab();
                    case 3:
                      return _buildKundaliTab();
                    case 4:
                      return _buildPreferencesTab();
                    default:
                      return _buildPersonalTab();
                  }
                }),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showFeedbackDialog(
    BuildContext context, bool isTrue, void Function(String val)? onPressed) {
  showDialog(
    barrierColor: Colors.black.withAlpha(77), // Adjust overlay color
    context: context,
    builder: (BuildContext context) {
      RxInt selectedOption = (-1).obs;
      return Dialog(
        insetPadding: EdgeInsets.zero, // Remove padding around the dialog
        alignment: Alignment.center, // Position the dialog at the bottom
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // Full-width dialog
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(204), // Dialog background color
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0), // Rounded top corners
            ),
          ),
          child: SingleChildScrollView(
            child: isTrue
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Text(
                  "Report/Block User".toUpperCase(),
                  style: TextStyle(
                    fontSize: Get.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(
                    vertical: MediaQuery.of(context).size.width * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Get.height * 0.005,
                      horizontal:
                      MediaQuery.of(context).size.width * 0.04),
                  child: Text(
                    "Blocked profiles won’t appear in your suggestions.",
                    style: TextStyle(
                        fontSize: Get.width * 0.045,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1),
                    textAlign: TextAlign.start,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: Get.height * 0.01,
                      horizontal:
                      MediaQuery.of(context).size.width * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onPressed!("Report and block user");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Profile Feedback".toUpperCase(),
                  style: TextStyle(
                    fontSize: Get.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).paddingSymmetric(
                    vertical: MediaQuery.of(context).size.width * 0.02),
                const Divider(
                  color: Colors.white,
                  thickness: 1.5,
                ).paddingSymmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                // Feedback Options
                Obx(() => Column(
                  children: [
                    RadioOption(
                      title: "Married/Engaged",
                      selectedOption: selectedOption.value,
                      value: 0,
                      onChanged: (value) {
                        selectedOption.value = value!;
                      },
                    ),
                    RadioOption(
                      title: "Duplicate Profile",
                      selectedOption: selectedOption.value,
                      value: 1,
                      onChanged: (value) {
                        selectedOption.value = value!;
                      },
                    ),
                    RadioOption(
                      title: "Incomplete Information",
                      selectedOption: selectedOption.value,
                      value: 2,
                      onChanged: (value) {
                        selectedOption.value = value!;
                      },
                    ),
                    RadioOption(
                      title: "Wrong Information",
                      selectedOption: selectedOption.value,
                      value: 3,
                      onChanged: (value) {
                        selectedOption.value = value!;
                      },
                    ),
                    RadioOption(
                      title: "Other Reason",
                      selectedOption: selectedOption.value,
                      value: 4,
                      onChanged: (value) {
                        selectedOption.value = value!;
                      },
                    ),
                  ],
                )),
                const Divider(
                  color: Colors.white,
                  thickness: 1.5,
                ).paddingSymmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                // Buttons
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                      MediaQuery.of(context).size.width * 0.04),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onPressed!(selectedOption.value == 0
                                ? "Married/Engaged"
                                : selectedOption.value == 1
                                ? "Duplicate Profile"
                                : selectedOption.value == 2
                                ? "Incomplete Information"
                                : selectedOption.value == 3
                                ? "Wrong Information"
                                : "Other Reason");
                          }, // Handle Send

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // Disclaimer
                /*Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "*User will be removed from list after feedback.",
                          style: TextStyle(
                            fontSize: Get.width * 0.045,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),*/
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Custom Radio Option Widget
class RadioOption extends StatelessWidget {
  final String title;
  final int selectedOption;
  final int value;
  final ValueChanged<int?> onChanged;

  const RadioOption({
    super.key,
    required this.title,
    required this.selectedOption,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: Get.width * 0.04,
        ),
      ),
      leading: Radio<int>(
        value: value,
        groupValue: selectedOption,
        onChanged: onChanged,
        fillColor: const WidgetStatePropertyAll(Colors.white),
        activeColor: Colors.white,
      ),
      onTap: () => onChanged(value),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Widget? text;
  final List<Map<String, String>> data;
  final VoidCallback? onEdit;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.data,
    this.text,
    this.onEdit,
  });

  Widget _buildFieldIcon(String key) {
    final lowerKey = key.toLowerCase();
    IconData iconData = Icons.info_outline_rounded;
    Color iconColor = const Color(0xFFE5097F);
    Color bgColor = const Color(0xFFFDE8EF);

    if (lowerKey.contains('dob') || lowerKey.contains('birth') || lowerKey.contains('age')) {
      iconData = Icons.cake_outlined;
      iconColor = const Color(0xFFE5097F);
      bgColor = const Color(0xFFFDE8EF);
    } else if (lowerKey.contains('blood')) {
      iconData = Icons.water_drop_outlined;
      iconColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE);
    } else if (lowerKey.contains('height')) {
      iconData = Icons.height_rounded;
      iconColor = const Color(0xFF7E57C2);
      bgColor = const Color(0xFFEDE7F6);
    } else if (lowerKey.contains('weight')) {
      iconData = Icons.monitor_weight_outlined;
      iconColor = const Color(0xFF26A69A);
      bgColor = const Color(0xFFE0F2F1);
    } else if (lowerKey.contains('marit') || lowerKey.contains('status')) {
      iconData = Icons.favorite_border_rounded;
      iconColor = const Color(0xFFEC407A);
      bgColor = const Color(0xFFFCE4EC);
    } else if (lowerKey.contains('mother') || lowerKey.contains('tongue') || lowerKey.contains('language')) {
      iconData = Icons.translate_rounded;
      iconColor = const Color(0xFF42A5F5);
      bgColor = const Color(0xFFE3F2FD);
    } else if (lowerKey.contains('religion') || lowerKey.contains('caste') || lowerKey.contains('sub')) {
      iconData = Icons.temple_hindu_outlined;
      iconColor = const Color(0xFFFF9800);
      bgColor = const Color(0xFFFFF3E0);
    } else if (lowerKey.contains('rashi') || lowerKey.contains('raasi')) {
      iconData = Icons.nightlight_round;
      iconColor = const Color(0xFFAB47BC);
      bgColor = const Color(0xFFF3E5F5);
    } else if (lowerKey.contains('nakshatra') || lowerKey.contains('star')) {
      iconData = Icons.auto_awesome_rounded;
      iconColor = const Color(0xFFFFA726);
      bgColor = const Color(0xFFFFF8E1);
    } else if (lowerKey.contains('gotra') || lowerKey.contains('kula')) {
      iconData = Icons.group_work_outlined;
      iconColor = const Color(0xFF5C6BC0);
      bgColor = const Color(0xFFE8EAF6);
    } else if (lowerKey.contains('dosha') || lowerKey.contains('mangal')) {
      iconData = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFFF7043);
      bgColor = const Color(0xFFFBE9E7);
    } else if (lowerKey.contains('educat') || lowerKey.contains('degree') || lowerKey.contains('qualif')) {
      iconData = Icons.school_outlined;
      iconColor = const Color(0xFF5C6BC0);
      bgColor = const Color(0xFFE8EAF6);
    } else if (lowerKey.contains('occup') || lowerKey.contains('profess') || lowerKey.contains('work') || lowerKey.contains('designat')) {
      iconData = Icons.work_outline_rounded;
      iconColor = const Color(0xFF26A69A);
      bgColor = const Color(0xFFE0F2F1);
    } else if (lowerKey.contains('income') || lowerKey.contains('salary') || lowerKey.contains('package')) {
      iconData = Icons.account_balance_wallet_outlined;
      iconColor = const Color(0xFF43A047);
      bgColor = const Color(0xFFE8F5E9);
    } else if (lowerKey.contains('father') || lowerKey.contains('parent')) {
      iconData = Icons.person_outline_rounded;
      iconColor = const Color(0xFF1E88E5);
      bgColor = const Color(0xFFE3F2FD);
    } else if (lowerKey.contains('bro') || lowerKey.contains('sis') || lowerKey.contains('sibling')) {
      iconData = Icons.people_outline_rounded;
      iconColor = const Color(0xFF8E24AA);
      bgColor = const Color(0xFFF3E5F5);
    } else if (lowerKey.contains('phone') || lowerKey.contains('mobile') || lowerKey.contains('contact')) {
      iconData = Icons.phone_outlined;
      iconColor = const Color(0xFF00897B);
      bgColor = const Color(0xFFE0F2F1);
    } else if (lowerKey.contains('email') || lowerKey.contains('mail')) {
      iconData = Icons.mail_outline_rounded;
      iconColor = const Color(0xFFFB8C00);
      bgColor = const Color(0xFFFFF3E0);
    } else if (lowerKey.contains('address') || lowerKey.contains('locat') || lowerKey.contains('city') || lowerKey.contains('state') || lowerKey.contains('country')) {
      iconData = Icons.place_outlined;
      iconColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE);
    } else if (lowerKey.contains('diet') || lowerKey.contains('eat') || lowerKey.contains('food')) {
      iconData = Icons.restaurant_menu_rounded;
      iconColor = const Color(0xFF7CB342);
      bgColor = const Color(0xFFF1F8E9);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        size: 19,
        color: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF0F0F5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8EF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: icon is IconData
                        ? Icon(
                            icon as IconData,
                            color: const Color(0xFFE5097F),
                            size: 18,
                          )
                        : (icon is String && (icon as String).endsWith('.svg'))
                            ? SvgPicture.asset(
                                icon as String,
                                height: 18,
                                width: 18,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFE5097F),
                                  BlendMode.srcIn,
                                ),
                              )
                            : const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFE5097F),
                                size: 18,
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E2448),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (onEdit != null)
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: Color(0xFFE5097F),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Edit",
                            style: TextStyle(
                              color: Color(0xFFE5097F),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF4F4F8),
          ),
          // Rows Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((itemEntry) {
                final index = itemEntry.key;
                final entry = itemEntry.value;
                final fieldKey = entry.keys.first;
                final fieldValue = entry.values.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildFieldIcon(fieldKey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fieldKey,
                                  style: const TextStyle(
                                    color: Color(0xFF7A8299),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fieldValue.isNotEmpty ? fieldValue : "-",
                                  style: const TextStyle(
                                    color: Color(0xFF1E2448),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < data.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.6,
                        color: Color(0xFFF6F6FA),
                        indent: 48,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle headingTextStyle = TextStyle(
    color: ConstHelper.orangeColor,
    fontWeight: FontWeight.w600,
    fontSize: Get.width * 0.045,
    letterSpacing: 1);

TextStyle titleTextStyle = TextStyle(
  color: ConstHelper.blackColor.withAlpha(204),
  fontSize: Get.width * 0.04,
  fontWeight: FontWeight.w500,
);

TextStyle valueTextStyle = TextStyle(
  color: ConstHelper.blackColor,
  fontSize: Get.width * 0.04,
  fontWeight: FontWeight.w500,
);

Widget threeDotWidget() => Padding(
  padding: EdgeInsets.only(
    right: Get.width / 30,
    left: Get.width / 90,
  ),
  child: Text(
    ':',
    style: titleTextStyle,
  ),
);

Widget myDividerWidget() => Column(
  children: [
    SizedBox(
      height: Get.width / 20,
    ),
    Divider(
      color: ConstHelper.cementColor,
    ),
    SizedBox(
      height: Get.width / 20,
    ),
  ],
);
/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../models/members_data_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';

class MembersDataShowPage extends StatefulWidget {
  const MembersDataShowPage({super.key});

  @override
  State<MembersDataShowPage> createState() => _MembersDataShowPageState();
}

class _MembersDataShowPageState extends State<MembersDataShowPage> {
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!homeController.userDataWithToken.value.isSubscribed) {
        if (mounted) {
          Get.back();
          Get.snackbar(
            'Subscription Required',
            'Not subscribed',
            backgroundColor: const Color(0xFFD32F2F),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: TextStyle(
              fontSize: 20,
              color: ConstHelper.blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              Get.back();
              await Future.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
              homeController.advancedDrawerController.hideDrawer();
            },
            icon: Icon(
              Icons.arrow_back,
              size: Get.width / 18,
              color: ConstHelper.orangeColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: ConstHelper.whiteColor,
          surfaceTintColor: ConstHelper.whiteColor,
          elevation: 10,
          shadowColor: ConstHelper.greyColor.withAlpha(25),
          // elevation: 3,
          // shadowColor: Colors.grey.shade50.withAlpha(77),
        ),
        backgroundColor: ConstHelper.whiteColor,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width / 20,
          ),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Get.width / 25,
                  ),
                  // Center(
                  //   child: Container(
                  //     height: Get.width/1.6,
                  //     width: Get.width/1.6,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(12),
                  //       gradient: LinearGradient(
                  //         begin: Alignment.topCenter,
                  //         end: Alignment.bottomCenter,
                  //         colors: [
                  //         colors: [
                  //           ConstHelper.blackColor.withOpacity(0.8),
                  //           ConstHelper.orangeColor.withOpacity(0.8),
                  //         ],
                  //       ),
                  //     ),
                  //     padding: EdgeInsets.all(Get.width/80),
                  //     child: ClipRRect(
                  //       borderRadius: BorderRadius.circular(9),
                  //       child: CachedNetworkImage(
                  //         imageUrl: homeController.selectedMembersData.value.profilePhoto == null || homeController.selectedMembersData.value.profilePhoto!.trim().isEmpty ? ConstHelper.noProfileImagePath : '${ConstHelper.userImagesPath}${homeController.selectedMembersData.value.profilePhoto!}',
                  //         fit: BoxFit.cover,
                  //         placeholder: (context, url) => Container(
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(9),
                  //             color: ConstHelper.whiteColor,
                  //           ),
                  //           alignment: Alignment.center,
                  //           child: CircularProgressIndicator(color: ConstHelper.orangeColor,),
                  //         ),
                  //         errorWidget: (context, url, error) => Container(
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(9),
                  //             color: ConstHelper.whiteColor,
                  //           ),
                  //           child: Image.asset(
                  //             'assets/image/imageNotFound.png',
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: Get.width / 1.6,
                          width: Get.width / 1.6,
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: ConstHelper.orangeColor,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: homeController.selectedMembersData.value
                                              .profileFullFacePhotoFileName ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileFullFacePhotoFileName!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.profileImagePath
                                  : '${ConstHelper.userImagesPath}${homeController.selectedMembersData.value.profileFullFacePhotoFileName!}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const ShimmerLoading.rectangular(height: double.infinity),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: ConstHelper.whiteColor,
                                ),
                                child: Image.asset(
                                  'assets/image/imageNotFound.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 30,
                  ),
                  Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: ConstHelper.orangeColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width / 30,
                      vertical: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            ConstHelper.constHelper.showNetworkImageInDialog(
                              imgPath: homeController.selectedMembersData.value
                                              .profilePhoto ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profilePhoto!
                                          .trim()
                                          .isEmpty
                                  ? ''
                                  : homeController
                                      .selectedMembersData.value.profilePhoto!,
                            );
                          },
                          icon: Icon(
                            Icons.photo_outlined,
                            color: ConstHelper.whiteColor,
                            size: Get.width / 15,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            try {
                              if (homeController.selectedMembersData.value
                                          .profileMobile !=
                                      null ||
                                  homeController
                                      .selectedMembersData.value.profileMobile!
                                      .trim()
                                      .isNotEmpty) {
                                Uri uri = Uri.parse(
                                    'whatsapp://send?phone=+91 ${homeController.selectedMembersData.value.profileMobile}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  ConstHelper.errorDialog(
                                    text: ConstHelper.somethingErrorMsg,
                                    seconds: 10,
                                  );
                                }
                              } else {
                                ConstHelper.errorDialog(
                                  text: ConstHelper.mobileNoNotAvailableMsg,
                                  seconds: 10,
                                );
                              }
                            } catch (error) {
                              ConstHelper.errorDialog(
                                text: ConstHelper.somethingErrorMsg,
                                seconds: 10,
                              );
                            }
                          },
                          icon: Image.asset(
                            'assets/image/whatsapp_outlined.png',
                            color: ConstHelper.whiteColor,
                            height: Get.width / 15,
                            width: Get.width / 15,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            EasyLoading.show(
                              status: ConstHelper.pleaseWaitMsg,
                            );
                            await Future.delayed(
                              Duration(
                                milliseconds: 200,
                              ),
                            );
                            if (!(await ConstHelper.checkInternet())) {
                              EasyLoading.dismiss();
                              ConstHelper.errorDialog(
                                text: ConstHelper.internetMsg,
                                seconds: 10,
                              );
                            } else if (homeController.profileShorted.value) {
                              try {
                                await ApiHelper.apiHelper
                                    .unSetMyShortlistProfile(
                                  profileId: (homeController
                                              .selectedMembersData.value.id ??
                                          0)
                                      .toString(),
                                )
                                    .then(
                                  (data) async {
                                    List<MembersDataModel>
                                        allShortlistedDataList = await ApiHelper
                                            .apiHelper
                                            .getAllShortlistedDataList();
                                    homeController.profileShorted.value =
                                        allShortlistedDataList
                                            .where(
                                              (element) =>
                                                  element.id ==
                                                  homeController
                                                      .selectedMembersData
                                                      .value
                                                      .id,
                                            )
                                            .toList()
                                            .isNotEmpty;
                                    if (data['code'] == 200) {
                                      homeController
                                              .allShortlistedDataList.value =
                                          await ApiHelper.apiHelper
                                              .getAllShortlistedDataList();
                                      EasyLoading.dismiss();
                                      ConstHelper.successDialog(
                                        text: data['msg'] ??
                                            'Profile Removed from Shortlist.',
                                        seconds: 10,
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      ConstHelper.errorDialog(
                                        text: data['msg'] ??
                                            ConstHelper.somethingErrorMsg,
                                        seconds: 10,
                                      );
                                    }
                                  },
                                );
                              } catch (error) {
                                EasyLoading.dismiss();
                                ConstHelper.errorDialog(
                                  text: ConstHelper.somethingErrorMsg,
                                  seconds: 10,
                                );
                              }
                            } else {
                              try {
                                await ApiHelper.apiHelper
                                    .setMyShortlistProfile(
                                  profileId: (homeController
                                              .selectedMembersData.value.id ??
                                          0)
                                      .toString(),
                                )
                                    .then(
                                  (data) async {
                                    List<MembersDataModel>
                                        allShortlistedDataList = await ApiHelper
                                            .apiHelper
                                            .getAllShortlistedDataList();
                                    homeController.profileShorted.value =
                                        allShortlistedDataList
                                            .where(
                                              (element) =>
                                                  element.id ==
                                                  homeController
                                                      .selectedMembersData
                                                      .value
                                                      .id,
                                            )
                                            .toList()
                                            .isNotEmpty;
                                    if (data['code'] == 200) {
                                      EasyLoading.dismiss();
                                      ConstHelper.successDialog(
                                        text: data['msg'] ??
                                            'Profile Shortlisted Successfully.',
                                        seconds: 10,
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      ConstHelper.errorDialog(
                                        text: data['msg'] ??
                                            ConstHelper.somethingErrorMsg,
                                        seconds: 10,
                                      );
                                    }
                                  },
                                );
                              } catch (error) {
                                EasyLoading.dismiss();
                                ConstHelper.errorDialog(
                                  text: ConstHelper.somethingErrorMsg,
                                  seconds: 10,
                                );
                              }
                            }
                          },
                          icon: Icon(
                            homeController.profileShorted.value
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: ConstHelper.whiteColor,
                            size: Get.width / 11,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.person_off_outlined,
                            color: ConstHelper.whiteColor,
                            size: Get.width / 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Center(
                  //   child: Text(
                  //     homeController.selectedMembersData.value.name == null || homeController.selectedMembersData.value.name!.trim().isEmpty ? ConstHelper.nameNotAvailableMsg : homeController.selectedMembersData.value.name!,
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //       color: ConstHelper.blackColor,
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 20,
                  //     ),
                  //   ),
                  // ),
                  // Center(
                  //   child: Text.rich(
                  //     textAlign: TextAlign.center,
                  //     TextSpan(
                  //       children: [
                  //         TextSpan(
                  //           text: 'User ID : ',
                  //           style: TextStyle(
                  //             color: ConstHelper.blackColor,
                  //             fontWeight: FontWeight.w500,
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //         TextSpan(
                  //           text: homeController.selectedMembersData.value.token == null || homeController.selectedMembersData.value.token!.trim().isEmpty ? ConstHelper.naMsg : homeController.selectedMembersData.value.token!,
                  //           style: TextStyle(
                  //             color: ConstHelper.orangeColor,
                  //             fontWeight: FontWeight.w500,
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ]
                  //     )
                  //   ),
                  // ),
                  SizedBox(
                    height: Get.width / 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'User ID',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ConstHelper.blackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                        ),
                      ),
                      Text(
                        homeController.selectedMembersData.value.id == null ||
                                homeController.selectedMembersData.value.id == 0
                            ? ConstHelper.naMsg
                            : homeController.selectedMembersData.value.id!
                                .toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ConstHelper.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: Get.width*0.045,
                        ),
                      ),
                      Center(
                        child: Text(
                          homeController.selectedMembersData.value.name ==
                                      null ||
                                  homeController.selectedMembersData.value.name!
                                      .trim()
                                      .isEmpty
                              ? ConstHelper.nameNotAvailableMsg
                              : homeController.selectedMembersData.value.name!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ConstHelper.orangeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.width / 20,
                  ),

                  InfoCard(
                    icon: 'assets/image/personWithRoundedSVG.svg',
                    title: "Personal Information'",
                    data: [
                      {
                        'Date of Birth': homeController.selectedMembersData
                                        .value.profileDateOfBirth ==
                                    null ||
                                homeController.selectedMembersData.value
                                        .profileDateOfBirth!.year <=
                                    0
                            ? ConstHelper.naMsg
                            : DateFormat('dd | MMM | yyyy').format(
                                homeController.selectedMembersData.value
                                    .profileDateOfBirth!)
                      },
                      {
                        'Date of Time': homeController.selectedMembersData.value
                                        .profileTimeOfBirth ==
                                    null ||
                                homeController.selectedMembersData.value
                                    .profileTimeOfBirth!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : homeController
                                .selectedMembersData.value.profileTimeOfBirth!
                      },
                      {
                        'Place of Birth': homeController.selectedMembersData
                                        .value.profilePlaceOfBirth ==
                                    null ||
                                homeController.selectedMembersData.value
                                    .profilePlaceOfBirth!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : homeController
                                .selectedMembersData.value.profilePlaceOfBirth!
                      },
                      {
                        'Place of Birth': homeController.selectedMembersData
                                        .value.profilePlaceOfBirth ==
                                    null ||
                                homeController.selectedMembersData.value
                                    .profilePlaceOfBirth!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : homeController
                                .selectedMembersData.value.profilePlaceOfBirth!
                      },
                      {
                        'Height': homeController.selectedMembersData.value
                                        .profileHeight ==
                                    null ||
                                homeController
                                    .selectedMembersData.value.profileHeight!
                                    .toString()
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : '${homeController.selectedMembersData.value.profileHeight!} ft ${homeController.selectedMembersData.value.profileHeight!.toString().substring(1)} Inch',
                      },
                      {
                        "Physical Disability (If any)": homeController
                                        .selectedMembersData
                                        .value
                                        .profilePhysicalDisablity ==
                                    null ||
                                homeController.selectedMembersData.value
                                    .profilePhysicalDisablity!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : homeController.selectedMembersData.value
                                .profilePhysicalDisablity!
                      },
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/image/personWithRoundedSVG.svg',
                            height: Get.width / 25,
                            width: Get.width / 25,
                            color: ConstHelper.blackColor,
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Flexible(
                            child: Text(
                              'Personal Information',
                              style: headingTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 20,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Date of Birth',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileDateOfBirth ==
                                          null ||
                                      homeController.selectedMembersData.value
                                              .profileDateOfBirth!.year <=
                                          0
                                  ? ConstHelper.naMsg
                                  : DateFormat('dd | MMM | yyyy').format(
                                      homeController.selectedMembersData.value
                                          .profileDateOfBirth!),
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Date of Time',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileTimeOfBirth ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileTimeOfBirth!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileTimeOfBirth!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Place of Birth',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profilePlaceOfBirth ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profilePlaceOfBirth!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profilePlaceOfBirth!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Height',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileHeight ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileHeight!
                                          .toString()
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : '${homeController.selectedMembersData.value.profileHeight!} ft ${homeController.selectedMembersData.value.profileHeight!.toString().substring(1)} Inch',
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Physical Disability',
                                  style: titleTextStyle,
                                ),
                                Text(
                                  '(if any)',
                                  style: valueTextStyle,
                                ),
                              ],
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profilePhysicalDisablity ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profilePhysicalDisablity!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profilePhysicalDisablity!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      myDividerWidget(),
                    ],
                  ),
                  SizedBox(
                    height: Get.width / 60,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/image/occupationSVG.svg',
                            height: Get.width / 25,
                            width: Get.width / 25,
                            color: ConstHelper.blackColor,
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Flexible(
                            child: Text(
                              'Occupation Details',
                              style: headingTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 20,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Qualification',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileprofileEducationQualification ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileprofileEducationQualification!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileprofileEducationQualification!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Occupation',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileProfession ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileProfession!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileProfession!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Organization',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text(
                      //         ConstHelper.naMsg,
                      //         style: valueTextStyle,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Org. Type',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text(
                      //         ConstHelper.naMsg,
                      //         style: valueTextStyle,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Annual Income',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text(
                      //         ConstHelper.naMsg,
                      //         style: valueTextStyle,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      myDividerWidget(),
                    ],
                  ),
                  SizedBox(
                    height: Get.width / 60,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/image/familySVG.svg',
                            height: Get.width / 25,
                            width: Get.width / 25,
                            color: ConstHelper.blackColor,
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Flexible(
                            child: Text(
                              'Family Details',
                              style: headingTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 20,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Father Name',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileFatherFullName ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileFatherFullName!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileFatherFullName!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Mother Name',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text(
                      //         ConstHelper.naMsg,
                      //         style: valueTextStyle,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: homeController.selectedMembersData.value.profileFatherFullName == null || homeController.selectedMembersData.value.profileFatherFullName!.trim().isEmpty ? 0 : Get.width/90,),
                      // homeController.selectedMembersData.value.profileFatherFullName == null || homeController.selectedMembersData.value.profileFatherFullName!.trim().isEmpty ? SizedBox() : Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         homeController.selectedMembersData.value.profileFatherFullName!,
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text(
                      //         ConstHelper.naMsg,
                      //         style: valueTextStyle,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // // SizedBox(height: Get.width/90,),
                      // // Row(
                      // //   // crossAxisAlignment: CrossAxisAlignment.start,
                      // //   children: [
                      // //     Expanded(
                      // //       child: Text(
                      // //         'Suman Khautan',
                      // //         style: titleTextStyle,
                      // //       ),
                      // //     ),
                      // //     threeDotWidget(),
                      // //     Expanded(
                      // //       child: Text(
                      // //         '1213243567',
                      // //         style: valueTextStyle,
                      // //       ),
                      // //     ),
                      // //   ],
                      // // ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Brother',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text.rich(
                      //         TextSpan(
                      //           children: [
                      //             TextSpan(
                      //               text: 'M-${ConstHelper.naMsg}',
                      //               style: valueTextStyle,
                      //             ),
                      //             TextSpan(
                      //               text: '      ',
                      //               style: valueTextStyle,
                      //             ),
                      //             TextSpan(
                      //               text: 'Un M-${ConstHelper.naMsg}',
                      //               style: valueTextStyle,
                      //             ),
                      //           ]
                      //         )
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: Get.width/90,),
                      // Row(
                      //   // crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         'Sister',
                      //         style: titleTextStyle,
                      //       ),
                      //     ),
                      //     threeDotWidget(),
                      //     Expanded(
                      //       child: Text.rich(
                      //         TextSpan(
                      //           children: [
                      //             TextSpan(
                      //               text: 'M-${ConstHelper.naMsg}',
                      //               style: valueTextStyle,
                      //             ),
                      //             TextSpan(
                      //               text: '      ',
                      //               style: valueTextStyle,
                      //             ),
                      //             TextSpan(
                      //               text: 'Un M-${ConstHelper.naMsg}',
                      //               style: valueTextStyle,
                      //             ),
                      //           ]
                      //         )
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Current Address (Rent - 5yrs)',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profilePermanentAddress ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profilePermanentAddress!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profilePermanentAddress!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Native Place',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              ConstHelper.naMsg,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Community',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileComunityName ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileComunityName!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileComunityName!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Gotra',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileGotra ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileGotra!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController
                                      .selectedMembersData.value.profileGotra!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Reference Name',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileRefContactName ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileRefContactName!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileRefContactName!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Reference Mobile No',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileRefContactMobile ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileRefContactMobile!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileRefContactMobile!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 90,
                      ),
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Main Contact No',
                              style: titleTextStyle,
                            ),
                          ),
                          threeDotWidget(),
                          Expanded(
                            child: Text(
                              homeController.selectedMembersData.value
                                              .profileMainContactNum ==
                                          null ||
                                      homeController.selectedMembersData.value
                                          .profileMainContactNum!
                                          .trim()
                                          .isEmpty
                                  ? ConstHelper.naMsg
                                  : homeController.selectedMembersData.value
                                      .profileMainContactNum!,
                              style: valueTextStyle,
                            ),
                          ),
                        ],
                      ),
                      myDividerWidget(),
                    ],
                  ),
                  // SizedBox(height: Get.width/60,),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         SvgPicture.asset('assets/image/kundaliSVG.svg',height: Get.width/25,width: Get.width/25,color: ConstHelper.blackColor,),
                  //         SizedBox(width: Get.width/30,),
                  //         Flexible(
                  //           child: Text(
                  //             'Kundali',
                  //             style: headingTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/20,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Gotra',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             homeController.selectedMembersData.value.profileGotra == null || homeController.selectedMembersData.value.profileGotra!.trim().isEmpty ? ConstHelper.naMsg : homeController.selectedMembersData.value.profileGotra!,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Matching Janampatri',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Marry in Same Gotra',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Are you Manglik',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Will you Marry Manglik',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     myDividerWidget(),
                  //   ],
                  // ),
                  // SizedBox(height: Get.width/60,),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         SvgPicture.asset('assets/image/partnerSVG.svg',height: Get.width/25,width: Get.width/25,color: ConstHelper.blackColor,),
                  //         SizedBox(width: Get.width/30,),
                  //         Flexible(
                  //           child: Text(
                  //             'Partner Preference',
                  //             style: headingTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/20,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'P. Spouse Can Be',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'P. Spouse Can Be',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Desired Edu. of P. Spouse',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Bride Permitted To Work After Marriage',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Current City',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/90,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Resident After Marriage',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     myDividerWidget(),
                  //   ],
                  // ),
                  SizedBox(
                    height: Get.width / 60,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/image/aboutMeRoundedSVG.svg',
                            height: Get.width / 25,
                            width: Get.width / 25,
                            color: ConstHelper.blackColor,
                          ),
                          SizedBox(
                            width: Get.width / 30,
                          ),
                          Flexible(
                            child: Text(
                              'Important Note',
                              style: headingTextStyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Get.width / 20,
                      ),
                      Text(
                        homeController.selectedMembersData.value.profileNote ==
                                    null ||
                                homeController
                                    .selectedMembersData.value.profileNote!
                                    .trim()
                                    .isEmpty
                            ? ConstHelper.naMsg
                            : homeController
                                .selectedMembersData.value.profileNote!,
                        style: valueTextStyle,
                      ),
                      // myDividerWidget(),
                    ],
                  ),
                  // SizedBox(height: Get.width/60,),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         SvgPicture.asset('assets/image/ruppeSVG.svg',height: Get.width/25,width: Get.width/25,color: ConstHelper.blackColor,),
                  //         SizedBox(width: Get.width/30,),
                  //         Flexible(
                  //           child: Text(
                  //             'Budget Info',
                  //             style: headingTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(height: Get.width/20,),
                  //     Row(
                  //       // crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             'Budget',
                  //             style: titleTextStyle,
                  //           ),
                  //         ),
                  //         threeDotWidget(),
                  //         Expanded(
                  //           child: Text(
                  //             ConstHelper.naMsg,
                  //             style: valueTextStyle,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: Get.width/20,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SvgPicture.asset('assets/image/yagnArrowLeftSVG.svg',height: Get.width/30,width: Get.width/30,),
                  //     SizedBox(width: Get.width/30,),
                  //     SvgPicture.asset('assets/image/yagnSVG.svg',height: Get.width/4,width: Get.width/4,),
                  //     SizedBox(width: Get.width/30,),
                  //     SvgPicture.asset('assets/image/yagnArrowRightSVG.svg',height: Get.width/30,width: Get.width/30,),
                  //   ],
                  // ),
                  SizedBox(
                    height: Get.width / 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Widget? text;
  final List<Map<String, String>> data;

  const InfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.data,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon is IconData
                  ? Icon(
                      icon,
                      color: ConstHelper.orangeColor,
                      size: 24,
                    )
                  : SvgPicture.asset(
                      icon,
                      height: Get.width / 25,
                      width: Get.width / 25,
                      color: ConstHelper.orangeColor,
                    ),
              const SizedBox(width: 10),
              Text(
                title,
                style: headingTextStyle,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...data.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: text ??
                        Text(
                          entry.keys.first,
                          style: titleTextStyle,
                        ),
                  ),
                  Text(
                    ":  ",
                    style: titleTextStyle,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      entry.values.first,
                      style: valueTextStyle,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

TextStyle headingTextStyle = TextStyle(
  color: ConstHelper.blackColor,
  fontWeight: FontWeight.w600,
  fontSize: 14,
);

TextStyle titleTextStyle = TextStyle(
  color: ConstHelper.blackColor,
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

TextStyle valueTextStyle = TextStyle(
  color: ConstHelper.cementColor,
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

Widget threeDotWidget() => Padding(
      padding: EdgeInsets.only(
        right: Get.width / 30,
        left: Get.width / 90,
      ),
      child: Text(
        ':',
        style: titleTextStyle,
      ),
    );

Widget myDividerWidget() => Column(
      children: [
        SizedBox(
          height: Get.width / 20,
        ),
        Divider(
          color: ConstHelper.cementColor,
        ),
        SizedBox(
          height: Get.width / 20,
        ),
      ],
    );
*/