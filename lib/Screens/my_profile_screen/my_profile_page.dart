import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/shared_pref_helper.dart';
import '../login_screen/login_page.dart';
import '../my_shortlisted_screen/my_shortlisted_page.dart';
import 'edit_photo.dart';
import 'edit_profile_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final HomeController homeController = Get.put(HomeController());

  // 4 Tabs: 0: Personal, 1: Occupation, 2: Preferences, 3: Contact
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
    final user = homeController.userData.value;
    final face = (user.profileFullFacePhotoFileName != null &&
            user.profileFullFacePhotoFileName!.trim().isNotEmpty)
        ? user.profileFullFacePhotoFileName!
        : '';
    final length = (user.profileFullLengthPhotoFileName != null &&
            user.profileFullLengthPhotoFileName!.trim().isNotEmpty)
        ? (user.profileFullLengthPhoto ?? '')
        : '';
    ConstHelper.constHelper.showNetworkImageInDialog(imgPath: [face, length]);
  }

  Future<void> _shareProfile() async {
    try {
      final user = homeController.userData.value;
      final text =
          "Check out my profile on VivahSambandh: User ID: ${user.id ?? ''}, Name: ${user.name ?? ''}";
      final Uri uri = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(text)}");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ConstHelper.errorDialog(
          text: ConstHelper.somethingErrorMsg,
          seconds: 3,
        );
      }
    } catch (_) {
      ConstHelper.errorDialog(
        text: ConstHelper.somethingErrorMsg,
        seconds: 3,
      );
    }
  }

  void _onDeleteAccount() {
    deleteDialog(
      context,
      Get.height,
      Get.width,
      () async {
        await ApiHelper.apiHelper.postDeleteProfileApi().then((value) async {
          try {
            if (value.isNotEmpty) {
              if (value['code'] == 200) {
                final responseData = value;
                debugPrint(responseData.toString());
                if (responseData['code'] == 200) {
                  SharedPrefHelper.sharedPreferences.setBool(
                    'login',
                    false,
                  );
                  ConstHelper.successDialog(
                    text: jsonDecode(value)['msg'] ??
                        ConstHelper.dataDeletedSuccessfullyMsg,
                    seconds: 2,
                  );
                  Future.delayed(
                    const Duration(seconds: 1),
                    () {
                      return Get.offAll(
                        const LoginPage(),
                      );
                    },
                  );
                } else {
                  ConstHelper.errorDialog(
                    text: value['msg'] ?? ConstHelper.somethingWantWrongMsg,
                    seconds: 3,
                  );
                }
              } else {
                ConstHelper.errorDialog(
                  text: value['msg'] ?? ConstHelper.somethingWantWrongMsg,
                  seconds: 3,
                );
              }
            }
          } on TimeoutException catch (e) {
            ConstHelper.errorDialog(
              text: e.message.toString(),
              seconds: 3,
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8EF),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFE5097F),
                  size: 18,
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            "My Profile",
            style: TextStyle(
              fontSize: 18.5,
              color: Color(0xFF1E2448),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: _shareProfile,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8EF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.share_outlined,
                    color: Color(0xFFE5097F),
                    size: 18,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: InkWell(
                onTap: () {
                  Get.to(Editprofilepage());
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8EF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFFE5097F),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFFF0F0F5),
              height: 1,
            ),
          ),
        ),
        body: Obx(
          () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildTopProfileCard(),
                const SizedBox(height: 14),
                _buildQuickActionsRow(),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 12),
                _buildTabContent(),
                const SizedBox(height: 18),
                _buildCreatedUpdatedDatePill(),
                const SizedBox(height: 16),
                _buildBottomActionButtons(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top Header Profile Card
  Widget _buildTopProfileCard() {
    final user = homeController.userData.value;
    final dob = user.profileDateOfBirth;
    final ageStr = _calculateAgeString(dob);
    final dobFormatted = (dob == null || dob.year <= 0)
        ? '-'
        : DateFormat('dd MMM yyyy').format(dob);

    final city = (user.profilePresentCity != null &&
            user.profilePresentCity!.trim().isNotEmpty)
        ? user.profilePresentCity!.trim()
        : (user.profileCurrentResidAddress != null &&
                user.profileCurrentResidAddress!.trim().isNotEmpty)
            ? user.profileCurrentResidAddress!.trim()
            : 'Not Specified';

    final heightStr = user.profileHeight == null
        ? '-'
        : convertInchesToFeetInch(user.profileHeight?.toInt() ?? 0);

    final genderStr = (user.profileGender != null &&
            user.profileGender!.trim().isNotEmpty)
        ? user.profileGender!.trim()
        : 'Male';

    final name = (user.name == null || user.name!.trim().isEmpty)
        ? ConstHelper.nameNotAvailableMsg
        : user.name!.trim();

    final photoName = user.profileFullFacePhotoFileName;
    final photoUrl = (photoName == null || photoName.trim().isEmpty)
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${photoName.trim()}';

    final userId = (user.id == null || user.id == 0) ? '-' : user.id.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo with Edit badge
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5097F),
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const ShimmerLoading.rectangular(
                            width: 90, height: 90),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/image/imageNotFound.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: InkWell(
                  onTap: () {
                    Get.to(EditPhotoPage());
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5097F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User ID & Profile Completed pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EF),
                        borderRadius: BorderRadius.circular(10),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF00C853),
                            size: 12,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Profile Completed >',
                            style: TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1E2448),
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Date of Birth & Age
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
                        ageStr.isNotEmpty
                            ? '$dobFormatted ($ageStr)'
                            : dobFormatted,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // City & Height
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: Color(0xFFE5097F),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        city,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.height_rounded,
                      size: 14,
                      color: Color(0xFFE5097F),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      heightStr,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Gender
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: Color(0xFFE5097F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      genderStr,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5 Quick Action Buttons Row
  Widget _buildQuickActionsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFFE5097F),
            bgColor: const Color(0xFFFCE4EC),
            label: 'View Photos',
            onTap: _openGallery,
          ),
          _buildQuickActionItem(
            icon: Icons.share_rounded,
            iconColor: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            label: 'Share Profile',
            onTap: _shareProfile,
          ),
          _buildQuickActionItem(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFA000),
            bgColor: const Color(0xFFFFF8E1),
            label: 'Shortlist',
            onTap: () {
              Get.to(const MyShortlistedPage());
            },
          ),
          _buildQuickActionItem(
            icon: Icons.error_outline_rounded,
            iconColor: const Color(0xFF1976D2),
            bgColor: const Color(0xFFE3F2FD),
            label: 'Report',
            onTap: () {
              ConstHelper.successDialog(
                text: "Support and feedback request received.",
                seconds: 3,
              );
            },
          ),
          _buildQuickActionItem(
            icon: Icons.visibility_off_rounded,
            iconColor: const Color(0xFF7B1FA2),
            bgColor: const Color(0xFFF3E5F5),
            label: 'Hide Profile',
            onTap: () {
              ConstHelper.successDialog(
                text: "Profile privacy settings updated.",
                seconds: 3,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
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

  // 4 Tabs: Personal | Occupation | Preferences | Contact
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabPill(
            index: 0,
            title: 'Personal',
            icon: Icons.person_rounded,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 1,
            title: 'Occupation',
            icon: Icons.work_rounded,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 2,
            title: 'Preferences',
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(width: 8),
          _buildTabPill(
            index: 3,
            title: 'Contact',
            icon: Icons.phone_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedTabIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          selectedTabIndex.value = index;
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE5097F) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE5097F)
                  : const Color(0xFFE5E7EB),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4A4A68),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Content Switcher
  Widget _buildTabContent() {
    switch (selectedTabIndex.value) {
      case 0:
        return _buildPersonalTab();
      case 1:
        return _buildOccupationTab();
      case 2:
        return _buildPreferencesTab();
      case 3:
        return _buildContactTab();
      default:
        return _buildPersonalTab();
    }
  }

  // Tab 0: Personal (Personal Information + Family Details + Earlier Marriage)
  Widget _buildPersonalTab() {
    final user = homeController.userData.value;
    final dob = user.profileDateOfBirth;
    final dobFormatted = (dob == null || dob.year <= 0)
        ? '-'
        : DateFormat('dd MMM yyyy').format(dob);

    final heightFormatted = user.profileHeight == null
        ? '-'
        : convertInchesToFeetInch(user.profileHeight?.toInt() ?? 0);

    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.person_outline_rounded,
          title: "Personal Information",
          data: [
            {"Date of Birth": dobFormatted},
            {
              "Time of Birth": normalizeTime(user.profileTimeOfBirth ?? "")
            },
            {"Place of Birth": user.profilePlaceOfBirth ?? "-"},
            {"Height": heightFormatted},
            {"Gender": user.profileGender ?? "-"},
            {"Email": user.email ?? "-"},
            {
              "Physical Disability": user.profilePhysicalDisablity ?? "-"
            },
          ],
        ),
        _buildSectionCard(
          icon: Icons.groups_rounded,
          title: "Family Details",
          data: [
            {"Father's Name": user.profileFatherFullName ?? "-"},
            {"Mother's Name": user.profileMotherFullName ?? "-"},
            {"Mobile (Father)": user.profileMainContactNum ?? "-"},
            {"Mobile (Mother)": user.profileAlternateContactNum ?? "-"},
            {
              "Brother":
                  "M - ${user.profileMarriedBrother ?? '0'}   Un-M - ${user.profileUnmarriedBrother ?? '0'}"
            },
            {
              "Sister":
                  "M - ${user.profileMarriedSister ?? '0'}   Un-M - ${user.profileUnmarriedSister ?? '0'}"
            },
            {
              "Current Address (${user.profileHouseType ?? '-'} - ${user.profileNumOfYearsAtThisAddress ?? '-'})":
                  user.profileCurrentResidAddress ?? "-"
            },
          ],
        ),
        if ((user.profileHaveMarriedBefore ?? "").toString().toLowerCase() !=
            "no")
          _buildSectionCard(
            icon: Icons.favorite_border_rounded,
            title: "Earlier Marriage",
            data: [
              {
                "Is Married Before": user.profileHaveMarriedBefore ?? "-"
              },
              (user.profileHaveMarriedBefore ?? "")
                          .toString()
                          .toLowerCase() ==
                      "yes and divorced"
                  ? {"Divorce Status": user.profileDivorceStatus ?? "-"}
                  : {"When Spouse Died?": user.profileSpouseDied ?? "-"},
              {
                "Num. Of Children From Prev. Marriage":
                    user.profileChildrenNumFromPrevMarriage ?? "-"
              },
              {
                "Children with whom": user.profileChildrenWith ?? "-"
              },
            ],
          ),
      ],
    );
  }

  // Tab 1: Occupation (Occupation Details + Budget Info)
  Widget _buildOccupationTab() {
    final user = homeController.userData.value;

    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.work_outline_rounded,
          title: "Occupation Details",
          data: [
            {
              "Qualification": user.profileEducationQualification ?? "-"
            },
            {
              "Category": user.profileProfessionOrgType ?? "-"
            },
            {"Profession": user.profileProfession ?? "-"},
            {
              "Organization": user.profileProfessionOrgName ?? "-"
            },
            {"Org. Type": user.profileProfessionOrgType ?? "-"},
            {
              "Annual Income (In lacs)":
                  "${user.profileProfessionAnnualNetIncome ?? '-'}"
            },
          ],
        ),
        if (user.profileType?.toString() == "2" ||
            user.profileBudgetCategoryId != null ||
            user.profileGroomBudgetCategoryId != null)
          _buildSectionCard(
            icon: Icons.currency_rupee_rounded,
            title: "Budget Info (In lacs)",
            data: [
              {"Budget Bride": user.profileBudgetCategoryId ?? "-"},
              {"Budget Groom": user.profileGroomBudgetCategoryId ?? "-"},
            ],
          ),
      ],
    );
  }

  // Tab 2: Preferences (Kundali + Partner Preferences + Note)
  Widget _buildPreferencesTab() {
    final user = homeController.userData.value;

    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.auto_awesome_rounded,
          title: "Kundali",
          data: [
            {"Gotra": user.profileGotra ?? "-"},
            {"Matching Kundali": user.profileWillMatchGanna ?? "-"},
            {"Marry in same gotra": user.profileMarryInComunity ?? "-"},
            {"Are you Manglik?": user.profileIsManglik ?? "-"},
            {"Will you marry a Manglik?": user.profileWillMarryManglink ?? "-"},
          ],
        ),
        _buildSectionCard(
          icon: Icons.favorite_outline_rounded,
          title: "Partner Preferences",
          data: [
            {
              "P. Spouse can be elder (> yrs)":
                  user.profileSpouseCanBeOlderBy ?? "-"
            },
            {
              "P. Spouse can be younger (< yrs)":
                  user.profileSpouseCanBeYoungerBy ?? "-"
            },
            {
              "Bride permitted to work after marriage?":
                  user.profileBridePermittedToWorkAfterMarriage ?? "-"
            },
            {"Current city": user.collageCity ?? "-"},
            {
              "Resident after marriage":
                  user.profilePlaceOfResidAfterMarriage ?? "-"
            },
          ],
        ),
        if (user.profileNote != null && user.profileNote!.trim().isNotEmpty)
          _buildSectionCard(
            icon: Icons.note_alt_outlined,
            title: "Important Note",
            data: [
              {"Note": user.profileNote!.trim()},
            ],
          ),
      ],
    );
  }

  // Tab 3: Contact (Contact References)
  Widget _buildContactTab() {
    final user = homeController.userData.value;

    return Column(
      children: [
        _buildSectionCard(
          icon: Icons.contact_phone_outlined,
          title: "Contact References",
          data: [
            {
              "Name": user.profileMainContactFullName ?? "-"
            },
            {
              "Mobile": user.profileMainContactNum ?? "-"
            },
            {
              "Location": user.profileCurrentResidAddress ?? "-"
            },
          ],
        ),
      ],
    );
  }

  // Helper Widget for Row pastel icon
  Widget _buildRowIcon(String label) {
    final lower = label.toLowerCase();
    IconData iconData = Icons.info_outline_rounded;
    Color iconColor = const Color(0xFFE5097F);
    Color bgColor = const Color(0xFFFDE8EF);

    if (lower.contains('dob') || lower.contains('birth') || lower.contains('age')) {
      iconData = Icons.cake_outlined;
      iconColor = const Color(0xFFE5097F);
      bgColor = const Color(0xFFFDE8EF);
    } else if (lower.contains('time')) {
      iconData = Icons.access_time_rounded;
      iconColor = const Color(0xFF7C3AED);
      bgColor = const Color(0xFFF3E8FF);
    } else if (lower.contains('height')) {
      iconData = Icons.height_rounded;
      iconColor = const Color(0xFF5C6BC0);
      bgColor = const Color(0xFFEDE7F6);
    } else if (lower.contains('gender')) {
      iconData = Icons.person_outline_rounded;
      iconColor = const Color(0xFF1E88E5);
      bgColor = const Color(0xFFE3F2FD);
    } else if (lower.contains('email') || lower.contains('mail')) {
      iconData = Icons.mail_outline_rounded;
      iconColor = const Color(0xFFFB8C00);
      bgColor = const Color(0xFFFFF3E0);
    } else if (lower.contains('disability')) {
      iconData = Icons.accessible_rounded;
      iconColor = const Color(0xFF00897B);
      bgColor = const Color(0xFFE0F2F1);
    } else if (lower.contains('father') || lower.contains('mother') || lower.contains('parent') || lower.contains('name')) {
      iconData = Icons.person_rounded;
      iconColor = const Color(0xFF1976D2);
      bgColor = const Color(0xFFE3F2FD);
    } else if (lower.contains('mobile') || lower.contains('phone') || lower.contains('contact')) {
      iconData = Icons.phone_outlined;
      iconColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
    } else if (lower.contains('brother') || lower.contains('sister') || lower.contains('sibling')) {
      iconData = Icons.people_outline_rounded;
      iconColor = const Color(0xFF8E24AA);
      bgColor = const Color(0xFFF3E5F5);
    } else if (lower.contains('address') || lower.contains('place') || lower.contains('city') || lower.contains('resident') || lower.contains('location')) {
      iconData = Icons.place_outlined;
      iconColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE);
    } else if (lower.contains('qualif') || lower.contains('educat') || lower.contains('degree')) {
      iconData = Icons.school_outlined;
      iconColor = const Color(0xFF3949AB);
      bgColor = const Color(0xFFE8EAF6);
    } else if (lower.contains('profess') || lower.contains('occup') || lower.contains('work')) {
      iconData = Icons.work_outline_rounded;
      iconColor = const Color(0xFF00897B);
      bgColor = const Color(0xFFE0F2F1);
    } else if (lower.contains('organ') || lower.contains('category') || lower.contains('type')) {
      iconData = Icons.business_rounded;
      iconColor = const Color(0xFF6D4C41);
      bgColor = const Color(0xFFEFEBE9);
    } else if (lower.contains('income') || lower.contains('budget') || lower.contains('lacs') || lower.contains('salary')) {
      iconData = Icons.currency_rupee_rounded;
      iconColor = const Color(0xFF43A047);
      bgColor = const Color(0xFFE8F5E9);
    } else if (lower.contains('gotra')) {
      iconData = Icons.temple_hindu_outlined;
      iconColor = const Color(0xFFFFA000);
      bgColor = const Color(0xFFFFF8E1);
    } else if (lower.contains('kundali') || lower.contains('star') || lower.contains('rashi')) {
      iconData = Icons.auto_awesome_rounded;
      iconColor = const Color(0xFFAB47BC);
      bgColor = const Color(0xFFF3E5F5);
    } else if (lower.contains('manglik')) {
      iconData = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFF4511E);
      bgColor = const Color(0xFFFBE9E7);
    } else if (lower.contains('spouse') || lower.contains('partner') || lower.contains('marry') || lower.contains('bride')) {
      iconData = Icons.favorite_outline_rounded;
      iconColor = const Color(0xFFD81B60);
      bgColor = const Color(0xFFFCE4EC);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        size: 16,
        color: iconColor,
      ),
    );
  }

  // Styled Section Card matching the Mockup
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Map<String, String>> data,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F5), width: 1.2),
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
          // Header with Edit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8EF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: const Color(0xFFE5097F),
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
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
                InkWell(
                  onTap: () {
                    Get.to(Editprofilepage());
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            fontWeight: FontWeight.bold,
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

          // Data rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: data.asMap().entries.map((item) {
                final index = item.key;
                final entry = item.value;
                final label = entry.keys.first;
                final value = entry.values.first;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildRowIcon(label),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Color(0xFF4A4A68),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Text(
                            " :  ",
                            style: TextStyle(
                              color: Color(0xFF8C93A3),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              value.isNotEmpty ? value : "-",
                              style: const TextStyle(
                                color: Color(0xFF1E2448),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
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
                        indent: 42,
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

  // Profile Created & Update Date Soft Pill
  Widget _buildCreatedUpdatedDatePill() {
    final user = homeController.userData.value;
    final created = DateFormat("dd-MM-yyyy")
        .format(user.profileRegistrationDate ?? DateTime.now());
    final updated = DateFormat("dd-MM-yyyy")
        .format(user.profileModifyDate ?? DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCE4EC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 13,
            color: Color(0xFFE5097F),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              "Profile Created : $created   |   Update Date : $updated",
              style: const TextStyle(
                color: Color(0xFF4A4A68),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Dual Action Buttons: Edit Profile & Delete Account
  Widget _buildBottomActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Edit Profile Button
          Expanded(
            child: InkWell(
              onTap: () {
                Get.to(Editprofilepage());
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF1493), Color(0xFFE5097F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5097F).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Delete Account Button
          Expanded(
            child: InkWell(
              onTap: _onDeleteAccount,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5097F),
                    width: 1.4,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE5097F),
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Color(0xFFE5097F),
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Delete Confirmation Dialog (Preserved 100%)
  dynamic deleteDialog(
      BuildContext context, double height, double width, void Function()? onPressed) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8EF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Color(0xFFE5097F),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Delete Profile?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2448),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to delete your account? This action cannot be undone and will permanently erase your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5097F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE5097F), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFFE5097F),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global normalizeTime Helper (Exported and used across app)
String normalizeTime(String input) {
  try {
    final parts = input.trim().split(' ');
    if (parts.length != 2) throw const FormatException('Invalid format');

    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) throw const FormatException('Invalid time');

    final hour = timeParts[0].padLeft(2, '0');
    final minute = timeParts[1].padLeft(2, '0');
    final period = parts[1].toUpperCase();

    final normalized = '$hour:$minute $period';
    final parsed = DateFormat('hh:mm a').parse(normalized);
    return DateFormat('hh:mm a').format(parsed);
  } catch (e) {
    return 'Invalid Time';
  }
}
