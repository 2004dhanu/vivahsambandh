import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/home_controller.dart';
import '../../utils/const_helper.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "About Us",
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
          shadowColor: ConstHelper.greyColor.withAlpha(25),
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
                colorFilter: ColorFilter.mode(
                  ConstHelper.orangeColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
          // elevation: 3,
          // shadowColor: Colors.grey.shade50.withOpacity(0.3),
        ),
        backgroundColor: ConstHelper.whiteColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: Get.width / 15,
              ),
              Center(
                child: Image.asset(
                  'assets/image/vs_app_logo.png',
                  height: Get.width / 1.6,
                  width: Get.width / 1.6,
                ),
              ),
              SizedBox(
                height: Get.width / 20,
              ),
              Text(
                homeController.samajModel.value.data?.name ?? "",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: ConstHelper.orangeColor,
                    fontSize: Get.height / 35,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.04),
                child: Text(
                  homeController.samajModel.value.data?.description ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ConstHelper.blackColor,
                      fontSize: Get.height / 55,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 1),
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              commonAboutUsWidget(
                onTap: () async {
                  // Extract and validate the phone number
                  final String? contactNumber =
                      homeController.samajModel.value.data?.mainContactNumber;

                  if (contactNumber != null && contactNumber.isNotEmpty) {
                    // Trim whitespace and ensure the number is in the correct format
                    final String formattedNumber =
                        contactNumber.replaceAll(RegExp(r'\s+'), '');
                    final Uri uri = Uri.parse('tel:$formattedNumber');

                    // Check if the dial pad can be launched
                    await launchUrl(
                      uri,
                      mode: LaunchMode
                          .externalApplication, // Ensures it opens in a browser like Chrome
                    );
                  }
                },
                title:
                    homeController.samajModel.value.data?.mainContactNumber ??
                        "",
                imageIconData: Icons.call_rounded,
                isIcon: true,
                context: context,
              ),
              commonAboutUsWidget(
                onTap: () async {
                  // Define the email details
                  final String recipient =
                      homeController.samajModel.value.data?.emailId ?? "";
                  final String subject = Uri.encodeComponent("vivahsambandh mail");

                  // Create the mailto URI
                  final Uri uri =
                      Uri.parse('mailto:$recipient?subject=$subject');

                  // Check if the email client can be launched
                  await launchUrl(
                    uri,
                    mode: LaunchMode
                        .externalApplication, // Ensures it opens in a browser like Chrome
                  );
                },
                title: homeController.samajModel.value.data?.emailId ?? "",
                imageIconData: Icons.email_outlined,
                isIcon: true,
                context: context,
              ),
              commonAboutUsWidget(
                onTap: () async {
                  final String url =
                      homeController.samajModel.value.data?.samajWebsite ?? "";

                  // Parse the URL
                  final Uri uri = Uri.parse(url);
                  await launchUrl(
                    uri,
                    mode: LaunchMode
                        .externalApplication, // Ensures it opens in a browser like Chrome
                  );
                },
                title: homeController.samajModel.value.data?.samajWebsite ?? "",
                imageIconData: Icons.public,
                isIcon: true,
                context: context,
              ),
              commonAboutUsWidget(
                onTap: () async {
                  final String address =
                      homeController.samajModel.value.data?.address ?? "";

                  // Encode the address for URL compatibility
                  final String encodedAddress = Uri.encodeComponent(address);

                  // Construct the Google Maps URL
                  final Uri googleMapsUri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$encodedAddress');

                  // Check if the URL can be launched
                  await launchUrl(googleMapsUri,
                      mode: LaunchMode.externalApplication);
                },
                title: homeController.samajModel.value.data?.address ?? "",
                imageIconData: Icons.location_on_outlined,
                isIcon: true,
                context: context,
              ),
              // Container(
              //   width: Get.width,
              //   color: ConstHelper.greyColor.withOpacity(0.1),
              //   padding: EdgeInsets.symmetric(vertical: Get.width / 30,),
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Business Booster Club',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       color: ConstHelper.orangeColor,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
              // SizedBox(height: Get.width / 20,),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: Get.width / 30,),
              //   child: Text(
              //     'I am flexible, reliable and possess excellent time keeping skills. I am an enthusiastic, self-motivated, reliable, responsible and hard working person. I am a mature team worker and adaptable to all challenging situations. I am able to work well both in a team environment as well as using own initiative.',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       color: ConstHelper.blackColor,
              //       fontSize: 15,
              //     ),
              //   ),
              // ),
              // SizedBox(height: Get.width / 20,),
              // Container(
              //   width: Get.width,
              //   color: ConstHelper.greyColor.withOpacity(0.1),
              //   padding: EdgeInsets.symmetric(vertical: Get.width / 30,),
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Our Directors',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       color: ConstHelper.orangeColor,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
              // SizedBox(height: Get.width / 20,),
              // Center(
              //   child: SizedBox(
              //     width: Get.width / 3.6,
              //     child: Column(
              //       children: [
              //         Container(
              //           height: Get.width / 3.6,
              //           width: Get.width / 3.6,
              //           decoration: BoxDecoration(
              //             color: ConstHelper.whiteColor,
              //             shape: BoxShape.circle,
              //             boxShadow: [
              //               BoxShadow(
              //                 color: ConstHelper.greyColor.withOpacity(0.6),
              //                 offset: Offset(0, 1),
              //                 blurRadius: 1,
              //               ),
              //             ],
              //             image: DecorationImage(
              //                 fit: BoxFit.cover,
              //                 image: AssetImage(
              //                   'assets/image/applogo.png',
              //                 )
              //             ),
              //           ),
              //         ),
              //         SizedBox(height: Get.width / 60,),
              //         Text(
              //           'Bhupendra Kotwal',
              //           textAlign: TextAlign.center,
              //           style: TextStyle(
              //             color: ConstHelper.blackColor,
              //             fontSize: 16,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: Get.width / 20,),
              // GestureDetector(
              //   onTap: () {
              //     launchUrl(Uri.parse("https://ppmilan.in"));
              //   },
              //   child: Center(
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: ConstHelper.orangeColor,
              //         borderRadius: BorderRadius.circular(15),
              //       ),
              //       padding: EdgeInsets.symmetric(
              //         horizontal: Get.width / 12, vertical: Get.width / 50,),
              //       child: Text(
              //         'Know More',
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //           color: ConstHelper.whiteColor,
              //           fontSize: 16,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: Get.width / 15,),
            ],
          ),
        ),
      ),
    );
  }

  Widget commonAboutUsWidget(
      {bool isIcon = false,
      String? title,
      void Function()? onTap,
      dynamic imageIconData,
      BuildContext? context}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Get.height * 0.01, horizontal: Get.width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          !isIcon
              ? Image.asset(imageIconData)
              : Icon(
                  imageIconData,
                  color: ConstHelper.orangeColor,
                  size: Get.height * 0.04,
                ),
          SizedBox(
            width: Get.width * 0.04,
          ),
          Expanded(
            flex: 4,
            child: InkWell(
              onTap: onTap,
              child: Text(
                title ?? "",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: ConstHelper.blackColor,
                    fontSize: Get.width * 0.04,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
