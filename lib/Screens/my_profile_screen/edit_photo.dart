import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controllers/home_controller.dart';
import '../../Utils/api_helper.dart';
import '../../Utils/const_helper.dart';
import '../../Utils/shimmer_loading.dart';
import '../../Utils/photo_view_page.dart';

class EditPhotoPage extends StatefulWidget {
  const EditPhotoPage({super.key});

  @override
  State<EditPhotoPage> createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  HomeController homeController = Get.find<HomeController>();

  RxString photoFacePath = ''.obs;
  RxString photoPath = ''.obs;

  getData() {
    photoPath.value = homeController
                    .userData.value.profileFullLengthPhotoFileName ==
                null ||
            homeController.userData.value.profileFullLengthPhotoFileName!
                .trim()
                .isEmpty
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${homeController.userData.value.profileFullLengthPhoto!}';
    photoFacePath.value = homeController
                    .userData.value.profileFullFacePhotoFileName ==
                null ||
            homeController.userData.value.profileFullFacePhotoFileName!
                .trim()
                .isEmpty
        ? ConstHelper.profileImagePath
        : '${ConstHelper.userImagesPath}${homeController.userData.value.profileFullFacePhotoFileName!}';
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    print(photoPath.value);
    print(photoFacePath.value);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Update Photos",
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
            icon: Icon(
              Icons.arrow_back,
              size: Get.width / 13,
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
        body: Obx(
          () => GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Get.width / 30,
                  ),
                  SizedBox(
                    height: Get.width / 2.3,
                    width: Get.width / 2.3,
                    child: Stack(
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (photoFacePath.trim().isNotEmpty) {
                                Get.to(
                                  PhotoViewPage(imagePath: photoFacePath.value),
                                );
                              }
                            },
                            child: Container(
                              height: Get.width / 2.3,
                              width: Get.width / 2.3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: ConstHelper.orangeColor,
                                ),
                              ),
                              child: photoFacePath.trim().isNotEmpty ||
                                      photoFacePath.value.isNotEmpty
                                  ? photoFacePath.value.startsWith('http')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: photoFacePath.value,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const ShimmerLoading.rectangular(height: double.infinity),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: ConstHelper.whiteColor,
                                              ),
                                              child: Image.asset(
                                                'assets/image/imageNotFound.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Image.file(
                                          File(photoFacePath.value),
                                          height: Get.height,
                                          width: Get.width,
                                        )
                                  : Center(
                                      child: SvgPicture.asset(
                                        'assets/image/personWithRoundedSVG.svg',
                                        height: Get.width / 3.5,
                                        width: Get.width / 3.5,
                                        fit: BoxFit.contain,
                                        colorFilter: ColorFilter.mode(
                                          ConstHelper.cementColor,
                                          BlendMode.srcIn,
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
                              right: Get.width / 100,
                              bottom: Get.width / 100,
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
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            )),
                                        padding: EdgeInsets.all(
                                          Get.width / 30,
                                        ),
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
                                            SizedBox(
                                              height: Get.width / 30,
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    var path = await ConstHelper
                                                        .constHelper
                                                        .pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                    );
                                                    if (path.isNotEmpty) {
                                                      photoFacePath.value =
                                                          path;
                                                    }
                                                    if (photoFacePath
                                                        .trim()
                                                        .isNotEmpty) {
                                                      Get.back();
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .camera_alt_rounded,
                                                        color: ConstHelper
                                                            .orangeColor,
                                                        size: Get.width / 18,
                                                      ),
                                                      Text(
                                                        'Camera',
                                                        style: TextStyle(
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize:
                                                              Get.width * 0.04,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: Get.width / 20,
                                                ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    var path = await ConstHelper
                                                        .constHelper
                                                        .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                    if (path.isNotEmpty) {
                                                      photoFacePath.value =
                                                          path;
                                                    }
                                                    if (photoFacePath
                                                        .trim()
                                                        .isNotEmpty) {
                                                      Get.back();
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.photo_rounded,
                                                        color: ConstHelper
                                                            .orangeColor,
                                                        size: Get.width / 18,
                                                      ),
                                                      Text(
                                                        'Gallery',
                                                        style: TextStyle(
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize:
                                                              Get.width * 0.04,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                  SizedBox(
                    height: Get.width / 40,
                  ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                      child: Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (photoPath.trim().isNotEmpty) {
                                  Get.to(
                                    PhotoViewPage(imagePath: photoPath.value),
                                  );
                                }
                              },
                              child: Container(
                                // height: Get.width / 1,
                                //width: Get.width / 1,
                                margin: EdgeInsets.all(0.8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: ConstHelper.orangeColor,
                                  ),
                                ),
                                child: photoPath.trim().isNotEmpty ||
                                        photoPath.value.isNotEmpty
                                    ? photoPath.value.startsWith('http')
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9),
                                            child: CachedNetworkImage(
                                              imageUrl: photoPath.value,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => const ShimmerLoading.rectangular(height: double.infinity),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(9),
                                                  color: ConstHelper.whiteColor,
                                                ),
                                                child: Image.asset(
                                                  'assets/image/imageNotFound.png',
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            File(photoPath.value),
                                            height: Get.height,
                                            width: Get.width,
                                          )
                                    : Center(
                                        child: SvgPicture.asset(
                                          'assets/image/personWithRoundedSVG.svg',
                                          height: Get.width / 3.5,
                                          width: Get.width / 3.5,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            ConstHelper.cementColor,
                                            BlendMode.srcIn,
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
                                right: Get.width / 100,
                                bottom: Get.width / 100,
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
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(
                                            Get.width / 30,
                                          ),
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
                                              SizedBox(
                                                height: Get.width / 30,
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var path =
                                                          await ConstHelper
                                                              .constHelper
                                                              .pickImage(
                                                        source:
                                                            ImageSource.camera,
                                                      );
                                                      if (path.isNotEmpty) {
                                                        photoPath.value = path;
                                                      }
                                                      if (photoPath
                                                          .trim()
                                                          .isNotEmpty) {
                                                        Get.back();
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .camera_alt_rounded,
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          size: Get.width / 18,
                                                        ),
                                                        Text(
                                                          'Camera',
                                                          style: TextStyle(
                                                            color: ConstHelper
                                                                .orangeColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                Get.width *
                                                                    0.04,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: Get.width / 20,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var path =
                                                          photoPath.value =
                                                              await ConstHelper
                                                                  .constHelper
                                                                  .pickImage(
                                                        source:
                                                            ImageSource.gallery,
                                                      );
                                                      if (path.isNotEmpty) {
                                                        photoPath.value = path;
                                                      }
                                                      if (photoPath
                                                          .trim()
                                                          .isNotEmpty) {
                                                        Get.back();
                                                      }
                                                      setState(() {});
                                                    },
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons.photo_rounded,
                                                          color: ConstHelper
                                                              .orangeColor,
                                                          size: Get.width / 18,
                                                        ),
                                                        Text(
                                                          'Gallery',
                                                          style: TextStyle(
                                                            color: ConstHelper
                                                                .orangeColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                Get.width *
                                                                    0.04,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                  ),
                  SizedBox(
                    height: Get.width / 40,
                  ),
                  (photoPath.value.startsWith('http') &&
                          photoFacePath.value.startsWith('http'))
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Get.width / 8,
                          ),
                          child: InkWell(
                            onTap: () async {
                              await ApiHelper.apiHelper
                                  .editProfilePhoto(
                                fullPhoto: photoPath.value.startsWith('http')
                                    ? ""
                                    : photoPath.value,
                                facePhoto:
                                    photoFacePath.value.startsWith('http')
                                        ? ""
                                        : photoFacePath.value,
                              )
                                  .then(
                                (value) {
                                  Get.back();
                                  ConstHelper.successDialog(
                                    text: 'Profile Updated Successfully',
                                    seconds: 10,
                                  );
                                },
                              );
                              homeController.userData.value =
                                  (await ApiHelper.apiHelper.fetchProfile())!;
                            },
                            child: Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: ConstHelper.orangeColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                vertical: Get.width / 30,
                              ),
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  color: ConstHelper.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Get.width * 0.045,
                                ),
                              ),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: Get.width / 40,
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
