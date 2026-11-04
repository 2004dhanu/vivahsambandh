import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controllers/home_controller.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/shimmer_loading.dart';
import '../home_screen/members_data_show_page.dart';

class MyShortlistedPage extends StatefulWidget {
  const MyShortlistedPage({super.key});

  @override
  State<MyShortlistedPage> createState() => _MyShortlistedPageState();
}

class _MyShortlistedPageState extends State<MyShortlistedPage> {
  HomeController homeController = Get.put(HomeController());
  RxBool startLoad = true.obs;

  Future<void> getAllMembersData() async {
    startLoad.value = true;
    try {
      homeController.allShortlistedDataList.value =
          await ApiHelper.apiHelper.getAllShortlistedDataList();
      startLoad.value = false;
    } catch (error) {
      homeController.allShortlistedDataList.value = [];
      startLoad.value = false;
    }

    startLoad.value = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    getAllMembersData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Shortlisted",
            style: TextStyle(
              fontSize: Get.width * 0.055,
              color: ConstHelper.blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(
              'assets/image/drawerIconSVG.svg',
              height: Get.width / 18,
              width: Get.width / 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: ConstHelper.whiteColor,
          surfaceTintColor: ConstHelper.whiteColor,
          elevation: 10,
          shadowColor: ConstHelper.greyColor.withOpacity(0.1),
          actions: [
            IconButton(
              onPressed: () async {
                Get.back();
                await Future.delayed(
                  const Duration(
                    milliseconds: 300,
                  ),
                );
                homeController.advancedDrawerController.hideDrawer();
              },
              icon: SvgPicture.asset(
                'assets/image/homeSVG.svg',
                height: Get.width / 18,
                width: Get.width / 18,
                color: ConstHelper.orangeColor,
              ),
            ),
          ],
          // elevation: 3,
          // shadowColor: Colors.grey.shade50.withOpacity(0.3),
        ),
        backgroundColor: ConstHelper.whiteColor,
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
                : homeController.allShortlistedDataList.isEmpty
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
                                    'No shortlisted profiles yet! browse and shortlist now.',
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
                        itemCount: homeController.allShortlistedDataList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              homeController.selectedMembersData.value =
                                  homeController.allShortlistedDataList[index];
                              homeController.profileShorted.value = true;
                              Get.to(
                                MembersDataShowPage(),
                                transition: Transition.fadeIn,
                              );
                            },
                            child: Container(
                              width: Get.width,
                              margin: EdgeInsets.fromLTRB(
                                Get.width / 30,
                                index == 0 ? Get.width / 15 : Get.width / 23,
                                Get.width / 30,
                                homeController.allShortlistedDataList.length !=
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
                                                        imageUrl: homeController.allShortlistedDataList[index].profileFullFacePhotoFileName == null ||
                                                                homeController
                                                                    .allShortlistedDataList[index]
                                                                    .profileFullFacePhotoFileName!
                                                                    .trim()
                                                                    .isEmpty
                                                            ? ConstHelper.profileImagePath
                                                            : '${ConstHelper.userImagesPath}${homeController.allShortlistedDataList[index].profileFullFacePhotoFileName!}',
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
                                                        '${homeController.allShortlistedDataList[index].id == null || homeController.allShortlistedDataList[index].id == 0 ? 'Id not available' : homeController.allShortlistedDataList[index].id!} - ${homeController.allShortlistedDataList[index].name == null || homeController.allShortlistedDataList[index].name!.trim().isEmpty ? ConstHelper.nameNotAvailableMsg : homeController.allShortlistedDataList[index].name}',
                                                        style: TextStyle(
                                                          color: ConstHelper
                                                              .orangeDarkColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              Get.width * 0.04,
                                                        ),
                                                      ),
                                                      // Text(
                                                      //   homeController.allShortlistedDataList[index].profileFatherFullName == null || homeController.allShortlistedDataList[index].profileFatherFullName!.trim().isEmpty ? ConstHelper.fatherNameNotAvailableMsg : homeController.allShortlistedDataList[index].profileFatherFullName!,
                                                      //   style: TextStyle(
                                                      //     color: ConstHelper.greyColor,
                                                      //     fontWeight: FontWeight.w500,
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
                                                                      .blackColor,
                                                                  fontSize:
                                                                      Get.width *
                                                                          0.035,
                                                                ),
                                                              ),
                                                              Text(
                                                                homeController.allShortlistedDataList[index].profileDateOfBirth ==
                                                                            null ||
                                                                        homeController.allShortlistedDataList[index].profileDateOfBirth!.year <=
                                                                            0
                                                                    ? '-'
                                                                    : DateFormat('dd | MMM | yyyy').format(homeController
                                                                        .allShortlistedDataList[
                                                                            index]
                                                                        .profileDateOfBirth!),
                                                                style:
                                                                    TextStyle(
                                                                  color: ConstHelper
                                                                      .blackColor
                                                                      .withOpacity(
                                                                          0.7),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      Get.width *
                                                                          0.035,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                Get.width / 30,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'EDU : ',
                                                                style:
                                                                    TextStyle(
                                                                  color: ConstHelper
                                                                      .blackColor,
                                                                  fontSize:
                                                                      Get.width *
                                                                          0.035,
                                                                ),
                                                              ),
                                                              Text(
                                                                homeController.allShortlistedDataList[index].profileEducationQualification ==
                                                                            null ||
                                                                        homeController
                                                                            .allShortlistedDataList[
                                                                                index]
                                                                            .profileEducationQualification!
                                                                            .trim()
                                                                            .isEmpty
                                                                    ? '-'
                                                                    : homeController
                                                                        .allShortlistedDataList[
                                                                            index]
                                                                        .profileEducationQualification!,
                                                                style:
                                                                    TextStyle(
                                                                  color: ConstHelper
                                                                      .blackColor
                                                                      .withOpacity(
                                                                          0.7),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize:
                                                                      Get.width *
                                                                          0.035,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Profession : ',
                                                            style: TextStyle(
                                                              color: ConstHelper
                                                                  .blackColor,
                                                              fontSize:
                                                                  Get.width *
                                                                      0.035,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              homeController.allShortlistedDataList[index].profileProfession ==
                                                                          null ||
                                                                      homeController
                                                                          .allShortlistedDataList[
                                                                              index]
                                                                          .profileProfession!
                                                                          .trim()
                                                                          .isEmpty
                                                                  ? '-'
                                                                  : homeController
                                                                      .allShortlistedDataList[
                                                                          index]
                                                                      .profileProfession!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: ConstHelper
                                                                    .blackColor
                                                                    .withOpacity(
                                                                        0.7),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    Get.width *
                                                                        0.035,
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
                                          ),
                                          // SvgPicture.asset('assets/image/menuVerticalIconSVG.svg',height: Get.width/25,width: Get.width/25,),
                                          SizedBox(
                                            width: Get.width / 90,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (homeController
                                              .allShortlistedDataList[index]
                                              .profileHaveMarriedBefore !=
                                          null &&
                                      homeController
                                              .allShortlistedDataList[index]
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
                      ),
          ),
        ),
      ),
    );
  }
}
