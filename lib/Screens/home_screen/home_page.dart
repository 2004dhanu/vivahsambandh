import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_controller.dart';
import '../../models/members_data_model.dart';
import '../../models/sponsors_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/shared_pref_helper.dart';
import '../../vivah_app/core/services/session_manager.dart';
import '../about_us_screen/about_us_page.dart';
import '../feedback_screen/feedback_page.dart';
import '../login_screen/login_page.dart';
import '../my_profile_screen/my_profile_page.dart';
import '../my_shortlisted_screen/my_shortlisted_page.dart';
import '../settings_screen/settings_page.dart';
import '../../vivah_app/views/legal/legal_webview_screen.dart';
import '../../vivah_app/views/payment/payment_history_screen.dart';
import 'members_data_show_page.dart';

RxBool maleFemale = true.obs;
RxInt totalMaleMembers = 0.obs;
RxInt totalFemaleMembers = 0.obs;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeController homeController = Get.put(HomeController());
  RxBool startLoad = true.obs;
  RxBool searchClick = false.obs;
  RxBool searchStart = false.obs;
  FocusNode searchFocusNode = FocusNode();
  TextEditingController txtSearch = TextEditingController();
  RxList<MembersDataModel> searchedMembersDataListGenderWise =
      <MembersDataModel>[].obs;
  List<String> educationSelected = [];
  bool _showUpdateBar = false;
  Future<void> _checkForUpdate() async {
  final newVersion = NewVersionPlus(
    androidId: "ags.matrimony.asvtbangalore",
  );

  final status = await newVersion.getVersionStatus();

  if (status == null) return;

  if (status.canUpdate && mounted) {
    setState(() {
      _showUpdateBar = true;
    });
  }
}

  Future<void> fetchAllData() async {
    await getUserData();
    await getAd();
    try {
      homeController.allShortlistedDataList.value =
          await ApiHelper.apiHelper.getAllShortlistedDataList();
    } catch (_) {}
    await getAllMembersData();
  }

  Future<void> getAd() async {
    await homeController.getSponData();
    if(!mounted) return;
    ImageDialog.show(context, homeController.sponItemList);
  }

  Future<void> getUserData() async {
    await homeController.getUserData();
  }

  Future<void> getAllMembersData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    homeController.selectedGotra.value = prefs.getString("gotra") ?? "";
    homeController.selectedGotra.value = prefs.getString("gotra") ?? "";
    homeController.yearlyIncomeStart.value =
        double.parse(prefs.getString("yearlyIncomeStart") ?? "1");
    homeController.yearlyIncomeEnd.value =
        double.parse(prefs.getString("yearlyIncomeEnd") ?? "300");
    homeController.selectedAgeStart.value =
        double.parse(prefs.getString("selectedAgeStart") ?? "18");
    homeController.selectedAgeEnd.value =
        double.parse(prefs.getString("selectedAgeEnd") ?? "56");
    homeController.selectedMaxHeightValue.value =
        (double.parse(prefs.getString("selectedMaxHeightValue") ?? "7") * 12)
            .toStringAsFixed(0);
    homeController.selectedMinHeightValue.value =
        (double.parse(prefs.getString("selectedMinHeightValue") ?? "4") * 12)
            .toStringAsFixed(0);
    homeController.marriedBeforeStatus.value =
        prefs.getString("marriedBeforeStatus") ?? "All";
    homeController.maglikStatus.value =
        prefs.getString("maglikStatus") ?? "All";
    homeController.selectAll.value = prefs.getString("selectAll") == "true"
        ? true
        : prefs.getString("selectAll") == "false"
            ? false
            : true;
    educationSelected = prefs.getStringList("eductionSelected") ?? [];
    debugPrint('educationSelected: ${educationSelected.length}');
    homeController.educationDataList.value =
        await ApiHelper.apiHelper.getEducationDataList();
    debugPrint('educationDataList: ${homeController.educationDataList.length}');
    if (educationSelected.isEmpty) {
      for (int i = 0; i < homeController.educationDataList.length; i++) {
        homeController.educationDataList[i]['selected'] = true;
        debugPrint('educationDataList: ${homeController.educationDataList[i]['selected']}');
      }
    } else if (homeController.educationDataList.length ==
        educationSelected.length) {
      for (int i = 0; i < homeController.educationDataList.length; i++) {
        homeController.educationDataList[i]['selected'] =
            educationSelected[i].toLowerCase() == "true";
        debugPrint('educationDataList: ${homeController.educationDataList[i]['selected']}');
      }
    } else {
      debugPrint(
          "Error: Mismatched list lengths. Ensure both lists have the same size.");
    }
    startLoad.value = true;
    txtSearch.clear();
    searchFocusNode.unfocus();
    searchClick.value = false;
    searchStart.value = false;
    try {
      List<String> educationCategory = [];
      for (int i = 0; i < homeController.educationDataList.length; i++) {
        debugPrint('educationDataList: ${homeController.educationDataList[i]['selected']}');
        if (homeController.educationDataList[i]['selected'] == true) {
          educationCategory.add(
              homeController.educationDataList[i]['education_name'] ?? '-');
        }
      }
      List<MembersDataModel> allMembersDataList = await ApiHelper.apiHelper
          .getAllMembersDataList(
              heightFrom: homeController.selectedMinHeightValue.value
                  .toString()
                  .split(".")[0]
                  .toString(),
              heightTo: homeController.selectedMaxHeightValue.value
                  .toString()
                  .split(".")[0]
                  .toString(),
              educationCategory: educationCategory,
              haveMarriedBefore:
                  homeController.marriedBeforeStatus.value.toLowerCase(),
              ageFrom: homeController.selectedAgeStart.value.toStringAsFixed(0),
              ageTo: homeController.selectedAgeEnd.value.toStringAsFixed(0),
              excludeGotra: homeController.selectedGotra.value.trim().isEmpty ||
                      homeController.selectedGotra.value == "-- Select Gotra --"
                  ? "No Exclude"
                  : homeController.selectedGotra.value,
              incomeFrom:
                  homeController.yearlyIncomeStart.value.toStringAsFixed(0),
              incomeTo: homeController.yearlyIncomeEnd.value.toStringAsFixed(0),
              isManglik: homeController.maglikStatus.value);
      debugPrint('allMembersDataList: ${allMembersDataList.length}');
      debugPrint('profileType: ${homeController.userData.value.profileType?.toString()}');
      if (homeController.userData.value.profileType?.toString() == "1") {
        homeController.allMembersDataListGenderWise.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  (homeController.userData.value.profileGender
                              ?.toString()
                              .trim()
                              .toLowerCase() ==
                          "Female".toLowerCase()
                      ? 'Male'.trim().toLowerCase()
                      : 'Female'.trim().toLowerCase()),
            )
            .toList();
        debugPrint('allMembersDataListGenderWise: ${homeController.allMembersDataListGenderWise.length}');
      } else {
        homeController.allMembersDataListGenderWise.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  (maleFemale.value
                      ? 'Male'.trim().toLowerCase()
                      : 'Female'.trim().toLowerCase()),
            )
            .toList();
        totalMaleMembers.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  'Male'.trim().toLowerCase(),
            )
            .toList()
            .length;
        totalFemaleMembers.value = allMembersDataList
            .where(
              (element) =>
                  element.profileGender.toString().trim().toLowerCase() ==
                  'Female'.trim().toLowerCase(),
            )
            .toList()
            .length;
      }
      searchedMembersDataListGenderWise.value =
          homeController.allMembersDataListGenderWise;
      startLoad.value = false;
    } catch (error) {
      homeController.allMembersDataListGenderWise.value = [];
      searchedMembersDataListGenderWise.value = [];
      startLoad.value = false;
    }
    startLoad.value = false;
  }

  void filterData(String searchValue) {
    // Backup the original data if it's not already backed up
    if (searchedMembersDataListGenderWise.isEmpty) {
      searchedMembersDataListGenderWise
          .assignAll(homeController.allMembersDataListGenderWise);
    }

    if (searchValue.isEmpty) {
      // Restore the original data when the search query is empty
      homeController.allMembersDataListGenderWise.value =
          List<MembersDataModel>.from(searchedMembersDataListGenderWise);
    } else {
      homeController.allMembersDataListGenderWise.value =
          searchedMembersDataListGenderWise.where((p0) {
        String dob =
            p0.profileDateOfBirth == null || p0.profileDateOfBirth!.year <= 0
                ? ''
                : DateFormat('dd | MMM | yyyy').format(p0.profileDateOfBirth!);
        return p0.id
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            p0.name
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            p0.profileFatherFullName
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            dob
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            p0.profileEducationQualification
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            p0.profilePresentCity
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase()) ||
            p0.profileCurrentResidAddress
                .toString()
                .trim()
                .toLowerCase()
                .contains(searchValue.trim().toLowerCase());
      }).toList();
    }
  }

  String _calculateAgeString(DateTime? dob) {
    if (dob == null || dob.year <= 0) return '';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age > 0 ? '$age yrs' : '';
  }

  Future<void> _openMemberDetails(MembersDataModel member) async {
    if (!homeController.userDataWithToken.value.isSubscribed) {
      Get.snackbar(
        'Subscription Required',
        'Not subscribed',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    EasyLoading.show(
      status: ConstHelper.pleaseWaitMsg,
    );
    await Future.delayed(
      const Duration(
        milliseconds: 200,
      ),
    );
    if (!(await ConstHelper.checkInternet())) {
      EasyLoading.dismiss();
      ConstHelper.errorDialog(
        text: ConstHelper.internetMsg,
        seconds: 10,
      );
    } else {
      homeController.selectedMembersData.value = member;
      try {
        List<MembersDataModel> allShortlistedDataList =
            await ApiHelper.apiHelper.getAllShortlistedDataList();
        homeController.allShortlistedDataList.value = allShortlistedDataList;
        homeController.profileShorted.value = allShortlistedDataList
            .where(
              (element) => element.id == member.id,
            )
            .toList()
            .isNotEmpty;
      } catch (_) {}
      homeController.selectedMembersData.value =
          await ApiHelper.apiHelper.getSelectedembersDataList(
              id: member.id.toString());
      Get.to(
        const MembersDataShowPage(),
        transition: Transition.fadeIn,
      )?.then((value) async => await getAllMembersData());
      EasyLoading.dismiss();
    }
    EasyLoading.dismiss();
  }

  Future<void> _toggleShortlist(MembersDataModel member) async {
    EasyLoading.show(status: ConstHelper.pleaseWaitMsg);
    try {
      bool isShort = homeController.allShortlistedDataList
          .any((e) => e.id == member.id);
      if (isShort) {
        await ApiHelper.apiHelper.unSetMyShortlistProfile(
            profileId: member.id.toString());
        homeController.allShortlistedDataList
            .removeWhere((e) => e.id == member.id);
        EasyLoading.showSuccess('Profile Removed from Shortlist.');
      } else {
        await ApiHelper.apiHelper.setMyShortlistProfile(
            profileId: member.id.toString());
        homeController.allShortlistedDataList.add(member);
        EasyLoading.showSuccess('Profile Shortlisted Successfully.');
      }
    } catch (e) {
      debugPrint("Shortlist error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }

  Widget _buildMemberCard(MembersDataModel member, int index) {
    final dob = member.profileDateOfBirth;
    final ageStr = _calculateAgeString(dob);
    final dobFormatted = (dob == null || dob.year <= 0)
        ? '-'
        : DateFormat('dd MMM yyyy').format(dob);
    final location = (member.profilePresentCity != null &&
            member.profilePresentCity!.trim().isNotEmpty)
        ? member.profilePresentCity!.trim()
        : 'Bangalore';
    final education = (member.profileEducationQualification == null ||
            member.profileEducationQualification!.trim().isEmpty)
        ? '-'
        : member.profileEducationQualification!.trim();
    final profession = (member.profileProfession == null ||
            member.profileProfession!.trim().isEmpty)
        ? '-'
        : member.profileProfession!.trim();

    return GestureDetector(
      onTap: () async {
        await _openMemberDetails(member);
      },
      child: Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: const Color(0xFFE5097F).withValues(alpha: 0.02),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            width: 0.8,
            color: const Color(0xFFF0F0F5),
          ),
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Bigger Profile Circular Image + ID badge below
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5097F),
                          width: 2.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: (member.profileFullFacePhotoFileName == null ||
                                  member.profileFullFacePhotoFileName!.trim().isEmpty)
                              ? ConstHelper.profileImagePath
                              : '${ConstHelper.userImagesPath}${member.profileFullFacePhotoFileName!}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerLoading.circular(),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/image/imageNotFound.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8EF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (member.id == null || member.id == 0)
                            ? '-'
                            : member.id.toString(),
                        style: const TextStyle(
                          color: Color(0xFFE5097F),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Vertical accent bar with gradient (thinner)
                Container(
                  width: 2,
                  height: 122,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE91E63),
                        Color(0xFF9C27B0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Member details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        (member.name == null ||
                                member.name!.trim().isEmpty)
                            ? ConstHelper.nameNotAvailableMsg
                            : member.name!.trim(),
                        style: const TextStyle(
                          color: Color(0xFF1E2448),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Info lines (DOB, EDU, Profession) & Shortlist Heart
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                // Date of Birth & Age
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 13,
                                      color: Color(0xFFE5097F),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "$dobFormatted${ageStr.isNotEmpty ? '  ($ageStr)' : ''}",
                                        style: const TextStyle(
                                          color: Color(0xFF555566),
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
                                // Education
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      size: 14,
                                      color: Color(0xFFE5097F),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        education,
                                        style: const TextStyle(
                                          color: Color(0xFF555566),
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
                                // Profession
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.work_outline_rounded,
                                      size: 13,
                                      color: Color(0xFFE5097F),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        profession,
                                        style: const TextStyle(
                                          color: Color(0xFF555566),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Heart Icon for Shortlist
                          Obx(() {
                            final isShort = homeController.allShortlistedDataList
                                .any((e) => e.id == member.id);
                            return GestureDetector(
                              onTap: () async {
                                await _toggleShortlist(member);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6, top: 4),
                                child: Icon(
                                  isShort
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: const Color(0xFFE5097F),
                                  size: 22,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bottom Badges & View Profile Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // Location badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDE8EF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          size: 12,
                                          color: Color(0xFFE5097F),
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            location,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E2448),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // View Profile Button
                          GestureDetector(
                            onTap: () async {
                              await _openMemberDetails(member);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5097F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "View Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ],
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
            if (member.profileHaveMarriedBefore != null &&
                member.profileHaveMarriedBefore.toString().toLowerCase() != "no")
              Image.asset(
                "assets/image/re-marriage.png",
                height: Get.height * 0.045,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Obx(() {
      final user = homeController.userData.value;
      final userId = (user.id == null || user.id! <= 0)
          ? ConstHelper.naMsg
          : user.id.toString();
      final userName = (user.name == null || user.name!.trim().isEmpty)
          ? ConstHelper.nameNotAvailableMsg
          : user.name!.trim().toUpperCase();
      final userContact = (user.profileMainContactNum == null ||
              user.profileMainContactNum!.trim().isEmpty)
          ? ConstHelper.naMsg
          : user.profileMainContactNum!.trim();
      final photoName = user.profileFullFacePhotoFileName;
      final photoUrl = (photoName == null || photoName.trim().isEmpty)
          ? ConstHelper.profileImagePath
          : '${ConstHelper.userImagesPath}${photoName.trim()}';

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF880E4F), // Wine Pink
              Color(0xFFAD1457), // Deep Pink
              Color(0xFFC2185B), // Rich Pink
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFAD1457).withValues(alpha: 0.35),
              offset: const Offset(0, 6),
              blurRadius: 14,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Subtle decorative background circles
              Positioned(
                top: -30,
                right: -25,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: 25,
                right: -10,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Row: Logo & Brand Name
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/image/drawerWhiteSVG.svg',
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 8),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'vivah',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'sambandh',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Centered Circular Avatar with white border
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: photoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerLoading.circular(width: 78, height: 78),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.white,
                            child: Image.asset(
                              'assets/image/imageNotFound.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // User ID
                    Text(
                      'User ID : $userId',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // User Name
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Contact
                    Text(
                      'Contact : $userContact',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDE8EF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFFE5097F) : const Color(0xFF2D3142),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFE5097F) : const Color(0xFF2D3142),
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchmakerBanner() {
    return InkWell(
      onTap: () {
        homeController.advancedDrawerController.hideDrawer();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8EF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF8BBD0).withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Color(0xFFE5097F),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Find Your Right Match',
                    style: TextStyle(
                      color: Color(0xFF1E2448),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Connect with verified profiles and find your...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFE5097F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {
        ConstHelper.constHelper.areYouSureWantAlertDialog(
          title: 'Log out now?',
          description: 'Are you sure you want to log out?',
          onPressed: () async {
            Get.back();
            await SessionManager.instance.destroySession();
          },
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFF555555),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return InkWell(
      onTap: () {
        ConstHelper.constHelper.areYouSureWantAlertDialog(
          title: 'Delete Account?',
          description:
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
          onPressed: () async {
            Get.back();
            EasyLoading.show(status: ConstHelper.pleaseWaitMsg);
            try {
              await ApiHelper.apiHelper.postDeleteProfileApi();
            } catch (_) {}
            await SessionManager.instance.destroySession();
            EasyLoading.dismiss();
            Get.snackbar(
              'Account Deleted',
              'Your account has been deleted successfully.',
              backgroundColor: const Color(0xFFD32F2F),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_forever_outlined,
              color: Color(0xFFD32F2F),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Delete Account',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchAllData();
    super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkForUpdate();
  });
  }

  @override
  Widget build(BuildContext context) {
    // ImageDialog.show(context, homeController.sponItemList);
    EasyLoading.dismiss();
    debugPrint("token");
    debugPrint('userDataWithToken: ${homeController.userDataWithToken.value.data?.token ?? ""}');
    return SafeArea(
      child: AdvancedDrawer(
        backdrop: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
        controller: homeController.advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        childDecoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(-4, 4),
            ),
          ],
        ),
        drawer: Container(
          color: Colors.white,
          child: SafeArea(
            child: SizedBox(
              width: Get.width * 0.74,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                children: [
                  _buildDrawerHeader(),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    icon: Icons.home_rounded,
                    title: 'Home',
                    isSelected: true,
                    onTap: () {
                      homeController.advancedDrawerController.hideDrawer();
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline_rounded,
                    title: 'My Profile',
                    onTap: () async {
                      homeController.userData.value =
                          (await ApiHelper.apiHelper.fetchProfile())!;
                      Get.to(
                        const MyProfilePage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.bookmark_border_rounded,
                    title: 'My Shortlisted',
                    onTap: () {
                      Get.to(
                        const MyShortlistedPage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Payment History',
                    onTap: () {
                      homeController.advancedDrawerController.hideDrawer();
                      Get.to(
                        const PaymentHistoryScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Messages',
                    onTap: () {
                      EasyLoading.showInfo('Messages feature coming soon');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () async {
                      if (!homeController.userDataWithToken.value.isSubscribed) {
                        Get.snackbar(
                          'Subscription Required',
                          'Not subscribed',
                          backgroundColor: const Color(0xFFD32F2F),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      EasyLoading.show(
                        status: ConstHelper.pleaseWaitMsg,
                      );
                      await Future.delayed(
                        const Duration(
                          milliseconds: 200,
                        ),
                      );
                      if (!(await ConstHelper.checkInternet())) {
                        EasyLoading.dismiss();
                        ConstHelper.errorDialog(
                          text: ConstHelper.internetMsg,
                          seconds: 10,
                        );
                      } else {
                        try {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          homeController.selectedGotra.value =
                              prefs.getString("gotra") ?? "";
                          homeController.yearlyIncomeStart.value = double.parse(
                              prefs.getString("yearlyIncomeStart") ?? "1.0");
                          homeController.yearlyIncomeEnd.value = double.parse(
                              prefs.getString("yearlyIncomeEnd") ?? "300.0");
                          homeController.selectedAgeStart.value = double.parse(
                              prefs.getString("selectedAgeStart") ?? "18");
                          homeController.selectedAgeEnd.value = double.parse(
                              prefs.getString("selectedAgeEnd") ?? "50");
                          homeController.selectedMaxHeightValue.value =
                              prefs.getString("selectedMaxHeightValue") ??
                                  "7.0";
                          homeController.selectedMinHeightValue.value =
                              prefs.getString("selectedMinHeightValue") ??
                                  "4.0";
                          homeController.marriedBeforeStatus.value =
                              prefs.getString("marriedBeforeStatus") ?? "All";
                          homeController.maglikStatus.value =
                              prefs.getString("maglikStatus") ?? "All";
                          homeController.selectAll.value =
                              prefs.getString("selectAll") == "true"
                                  ? true
                                  : prefs.getString("selectAll") == "false"
                                      ? false
                                      : true;
                          educationSelected =
                              prefs.getStringList("eductionSelected") ??
                                  [];
                          homeController.educationDataList.value =
                              await ApiHelper.apiHelper.getEducationDataList();
                          debugPrint('educationDataList: ${homeController.educationDataList.length}');
                          if (educationSelected.isEmpty) {
                            for (int i = 0;
                                i < homeController.educationDataList.length;
                                i++) {
                              homeController.educationDataList[i]['selected'] =
                                  true;
                              debugPrint('educationDataList: ${homeController.educationDataList[i]['selected']}');
                            }
                          } else if (homeController.educationDataList.length ==
                              educationSelected.length) {
                            for (int i = 0;
                                i < homeController.educationDataList.length;
                                i++) {
                              homeController.educationDataList[i]['selected'] =
                                  educationSelected[i].toLowerCase() == "true";
                              debugPrint('educationDataList: ${homeController.educationDataList[i]['selected']}');
                            }
                          } else {
                            debugPrint(
                                "Error: Mismatched list lengths. Ensure both lists have the same size.");
                          }
                          homeController.gotraDataList.clear();
                          homeController.gotraDataList
                              .add("-- Select Gotra --");
                          await ApiHelper.apiHelper.getGotraDataList().then(
                            (value) {
                              homeController.gotraDataList.addAll(value);
                            },
                          );
                          homeController.selectedGotra.value =
                              "-- Select Gotra --";
                          debugPrint('gotraDataList: ${homeController.gotraDataList}');
                          Get.to(
                            const SettingsPage(),
                            transition: Transition.rightToLeft,
                          );
                          EasyLoading.dismiss();
                        } catch (error) {
                          debugPrint('Error: $error');
                          EasyLoading.dismiss();
                          ConstHelper.errorDialog(
                            text: ConstHelper.somethingErrorMsg,
                            seconds: 10,
                          );
                        }
                      }
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.rate_review_outlined,
                    title: 'Feedback',
                    onTap: () {
                      Get.to(
                        const FeedbackPage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Us',
                    onTap: () async {
                      await homeController.getSamaj();
                      Get.to(
                        const AboutUsPage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Get.to(
                        () => const LegalWebViewScreen(initialTabIndex: 0),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {
                      Get.to(
                        () => const LegalWebViewScreen(initialTabIndex: 1),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildMatchmakerBanner(),
                  const SizedBox(height: 4),
                  _buildLogoutButton(),
                  const SizedBox(height: 4),
                  _buildDeleteAccountButton(),
                ],
              ),
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (searchClick.value) {
                  txtSearch.clear();
                  searchFocusNode.unfocus();
                  searchClick.value = false;
                  searchStart.value = false;
                } else {
                  homeController.advancedDrawerController.showDrawer();
                }
              },
              icon: Obx(() => searchClick.value
                  ? Icon(
                      Icons.arrow_back_ios_rounded,
                      size: Get.width / 15,
                      color: ConstHelper.orangeColor,
                    )
                  : const Icon(
                      Icons.grid_view_rounded,
                      size: 26,
                      color: Color(0xFF1E2448),
                    )),
            ),
            title: Obx(
              () => searchClick.value
                  ? TextField(
                      focusNode: searchFocusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: ConstHelper.greyColor.withAlpha(77),
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: ConstHelper.greyColor.withAlpha(77),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5097F),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: Get.width / 30,
                        ),
                        hintText: 'Search....',
                        hintStyle: TextStyle(
                          color: ConstHelper.greyColor.withAlpha(179),
                        ),
                      ),
                      onChanged: (value) {
                        filterData(value);
                        searchStart.value = value.trim().isNotEmpty;
                      },
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "vivah",
                              style: TextStyle(
                                fontSize: Get.width * 0.055,
                                color: const Color(0xFFE5097F),
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              "sambandh",
                              style: TextStyle(
                                fontSize: Get.width * 0.055,
                                color: const Color(0xFF1E2448),
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Verified Profiles • Trusted Community",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
            centerTitle: true,
            backgroundColor: ConstHelper.whiteColor,
            surfaceTintColor: ConstHelper.whiteColor,
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8EF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (searchClick.value) {
                      txtSearch.clear();
                      searchFocusNode.unfocus();
                      searchStart.value = false;
                    } else {
                      searchFocusNode.requestFocus();
                    }

                    searchClick.value = !searchClick.value;
                  },
                  icon: Obx(
                    () => Icon(
                      searchClick.value
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      color: const Color(0xFFE5097F),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFBF8F9),
          body: RefreshIndicator(
            onRefresh: () async {
              await getAllMembersData();
            },
            color: ConstHelper.orangeColor,
            backgroundColor: ConstHelper.whiteColor,
            child: Obx(
              () => startLoad.value
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: MemberListShimmer(),
                    )
                  : /* searchStart.value
                      ? searchedMembersDataListGenderWise.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: Get.height / 2.5,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Get.width * 0.04),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Oops! No data found. Try again later or contact admin.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: ConstHelper.orangeDarkColor,
                                            fontSize: Get.width * 0.05,
                                            letterSpacing: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount:
                                  searchedMembersDataListGenderWise.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _openMemberDetails(searchedMembersDataListGenderWise[index]),
                                  child: Container(
                                    width: Get.width,
                                    margin: EdgeInsets.fromLTRB(
                                      Get.width / 30,
                                      index == 0
                                          ? Get.width / 15
                                          : Get.width / 23,
                                      Get.width / 30,
                                      searchedMembersDataListGenderWise
                                                  .length !=
                                              (index + 1)
                                          ? 0
                                          : Get.width / 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ConstHelper.whiteColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                      border: Border.all(
                                        width: 0.3,
                                        color: ConstHelper.greyColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: Get.width / 30,
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 4,
                                                        decoration: BoxDecoration(
                                                          gradient: ConstHelper.premiumPinkGradient,
                                                          borderRadius: const BorderRadius.horizontal(
                                                            right: Radius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: Get.width / 30,
                                                      ),
                                                      Container(
                                                        width: Get.width / 4.8,
                                                        height: Get.width / 4.8,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          gradient: ConstHelper.premiumPinkGradient,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: ConstHelper.orangeColor.withOpacity(0.15),
                                                              blurRadius: 6,
                                                              offset: const Offset(0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        padding: const EdgeInsets.all(2),
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                          padding: const EdgeInsets.all(1),
                                                          child: ClipOval(
                                                            child: CachedNetworkImage(
                                                              imageUrl: searchedMembersDataListGenderWise[index].profileFullFacePhotoFileName == null ||
                                                                      searchedMembersDataListGenderWise[index]
                                                                          .profileFullFacePhotoFileName!
                                                                          .trim()
                                                                          .isEmpty
                                                                  ? ConstHelper.profileImagePath
                                                                  : '${ConstHelper.userImagesPath}${searchedMembersDataListGenderWise[index].profileFullFacePhotoFileName!}',
                                                              fit: BoxFit.cover,
                                                              placeholder: (context, url) => const ShimmerLoading.circular(),
                                                              errorWidget: (context, url, error) => Container(
                                                                decoration: const BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  color: Colors.white,
                                                                ),
                                                                child: Image.asset(
                                                                  'assets/image/imageNotFound.png',
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: Get.width / 30,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '${searchedMembersDataListGenderWise[index].id == null || searchedMembersDataListGenderWise[index].id == 0 ? 'Id not available' : searchedMembersDataListGenderWise[index].id!} - ${searchedMembersDataListGenderWise[index].name == null || searchedMembersDataListGenderWise[index].name!.trim().isEmpty ? ConstHelper.nameNotAvailableMsg : searchedMembersDataListGenderWise[index].name}',
                                                              style: TextStyle(
                                                                color: ConstHelper
                                                                    .orangeDarkColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    Get.width *
                                                                        0.04,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   searchedMembersDataListGenderWise[
                                                            //                       index]
                                                            //                   .profileFatherFullName ==
                                                            //               null ||
                                                            //           searchedMembersDataListGenderWise[
                                                            //                   index]
                                                            //               .profileFatherFullName!
                                                            //               .trim()
                                                            //               .isEmpty
                                                            //       ? ConstHelper
                                                            //           .fatherNameNotAvailableMsg
                                                            //       : searchedMembersDataListGenderWise[
                                                            //               index]
                                                            //           .profileFatherFullName!,
                                                            //   style: TextStyle(
                                                            //     color: ConstHelper
                                                            //         .greyColor,
                                                            //     fontWeight:
                                                            //         FontWeight.w500,
                                                            //     fontSize: 12,
                                                            //   ),
                                                            // ),
                                                            Row(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'DOB : ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: ConstHelper
                                                                            .blackColor
                                                                            .withOpacity(0.8),
                                                                        fontSize:
                                                                            Get.width *
                                                                                0.035,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      searchedMembersDataListGenderWise[index].profileDateOfBirth == null ||
                                                                              searchedMembersDataListGenderWise[index].profileDateOfBirth!.year <=
                                                                                  0
                                                                          ? '-'
                                                                          : DateFormat('dd | MMM | yyyy')
                                                                              .format(searchedMembersDataListGenderWise[index].profileDateOfBirth!),
                                                                      style:
                                                                          TextStyle(
                                                                        color: ConstHelper
                                                                            .blackColor,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            Get.width *
                                                                                0.035,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      Get.width /
                                                                          30,
                                                                ),
                                                                Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Text(
                                                                        'EDU : ',
                                                                        style:
                                                                            TextStyle(
                                                                          color: ConstHelper
                                                                              .blackColor
                                                                              .withOpacity(0.8),
                                                                          fontSize:
                                                                              Get.width * 0.035,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          searchedMembersDataListGenderWise[index].profileEducationQualification == null || searchedMembersDataListGenderWise[index].profileEducationQualification!.trim().isEmpty
                                                                              ? '-'
                                                                              : searchedMembersDataListGenderWise[index].profileEducationQualification!,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                ConstHelper.blackColor,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                Get.width * 0.035,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),

                                                            Expanded(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Profession : ',
                                                                    style:
                                                                        TextStyle(
                                                                      color: ConstHelper
                                                                          .blackColor
                                                                          .withOpacity(
                                                                              0.8),
                                                                      fontSize:
                                                                          Get.width *
                                                                              0.035,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      searchedMembersDataListGenderWise[index].profileProfession == null ||
                                                                              searchedMembersDataListGenderWise[index].profileProfession!.trim().isEmpty
                                                                          ? '-'
                                                                          : searchedMembersDataListGenderWise[index].profileProfession!,
                                                                      style:
                                                                          TextStyle(
                                                                        color: ConstHelper
                                                                            .blackColor,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            Get.width *
                                                                                0.035,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                */ /*SvgPicture.asset(
                                            'assets/image/menuVerticalIconSVG.svg',
                                            height: Get.width / 25,
                                            width: Get.width / 25,
                                          ),
                                          SizedBox(
                                            width: Get.width / 90,
                                          ),*/ /*
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (searchedMembersDataListGenderWise[
                                                        index]
                                                    .profileHaveMarriedBefore !=
                                                null &&
                                            searchedMembersDataListGenderWise[
                                                        index]
                                                    .profileHaveMarriedBefore
                                                    .toString()
                                                    .toLowerCase() !=
                                                "no")
                                          Image.asset(
                                            "assets/image/re-marriage.png",
                                            height: Get.height * 0.06,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                      :*/
                  homeController.allMembersDataListGenderWise.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: Get.height / 2.5,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.04),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Oops! No data found. Try again later or contact admin.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ConstHelper.orangeDarkColor,
                                        fontSize: Get.width * 0.05,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: homeController
                              .allMembersDataListGenderWise.length,
                          itemBuilder: (context, index) {
                            return _buildMemberCard(
                              homeController.allMembersDataListGenderWise[index],
                              index,
                            );
                          },
                        ),
            ),
          ),
          bottomNavigationBar: (homeController.userData.value.profileType
                      ?.toString() ==
                  "2")
              ? IntrinsicHeight(
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          color: ConstHelper.orangeColor.withAlpha(64),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        margin: EdgeInsets.only(
                          top: Get.width / 60,
                          bottom: Get.width / 30,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (!maleFemale.value) {
                                  maleFemale.value = true;
                                  await getAllMembersData();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: maleFemale.value
                                      ? ConstHelper.orangeColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: Get.width / 40,
                                  horizontal: Get.width / 25,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/image/maleIconSVG.svg',
                                      height: Get.width / 30,
                                      width: Get.width / 30,
                                      colorFilter: ColorFilter.mode(
                                        maleFemale.value
                                            ? ConstHelper.whiteColor
                                            : ConstHelper.orangeColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width / 60,
                                    ),
                                    Text(
                                      //profile_gender
                                      'Male ${totalMaleMembers.value}',
                                      style: TextStyle(
                                        color: maleFemale.value
                                            ? ConstHelper.whiteColor
                                            : ConstHelper.orangeColor,
                                        fontSize: Get.width * 0.04,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (maleFemale.value) {
                                  maleFemale.value = false;
                                  await getAllMembersData();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !maleFemale.value
                                      ? ConstHelper.orangeColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: Get.width / 40,
                                  horizontal: Get.width / 25,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/image/femaleIconSVG.svg',
                                      height: Get.width / 30,
                                      width: Get.width / 30,
                                      colorFilter: ColorFilter.mode(
                                        maleFemale.value
                                            ? ConstHelper.orangeColor
                                            : ConstHelper.whiteColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(
                                      width: Get.width / 60,
                                    ),
                                    Text(
                                      'Female ${totalFemaleMembers.value}',
                                      style: TextStyle(
                                        color: maleFemale.value
                                            ? ConstHelper.orangeColor
                                            : ConstHelper.whiteColor,
                                        fontSize: Get.width * 0.04,
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
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}

class ImageDialog {
  static Future<void> show(BuildContext context, List<SponsorItem> imageUrls,
      {int initialIndex = 0}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "ImageDialog",
      barrierColor: Colors.black.withAlpha(204),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          children: [
            Spacer(),
            SizedBox(
              height: Get.height * 0.05,
            ),
            CarouselSlider.builder(
              itemCount: imageUrls.length,
              options: CarouselOptions(
                initialPage: initialIndex,
                enableInfiniteScroll: true,
                enlargeCenterPage: false,
                autoPlay: imageUrls.length != 1 ? true : false,
                height: Get.height * 0.75,
                viewportFraction: 1.1,
              ),
              itemBuilder: (context, index, realIndex) {
                return InteractiveViewer(
                  child: Image.network(
                    ConstHelper.sponsorImgPath + (imageUrls[index].image ?? ""),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            Spacer(),
          ],
        );
      },
    );
  }
}
