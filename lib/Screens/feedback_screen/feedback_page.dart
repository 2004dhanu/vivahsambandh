import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  HomeController homeController = Get.put(HomeController());
  TextEditingController txtFeedback = TextEditingController();
  RxInt length = 0.obs;
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Feedback",
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
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Get.width / 30,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: Get.width / 20,
                  ),
                  Center(
                    child: Text(
                      "Help Us Improve",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: Get.width * 0.07,
                          color: ConstHelper.blackColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 60,
                  ),
                  Center(
                    child: Text(
                      "We Value Your Feedback/Input",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: Get.width * 0.04,
                          color: ConstHelper.lightBlackColor,
                          letterSpacing: 1),
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 20,
                  ),
                  /*  Center(
                    child: SvgPicture.asset(
                      'assets/image/feedbackPageSVG.svg',
                      height: Get.width/2,
                      width: Get.width/2,
                    ),
                  ),
                  SizedBox(height: Get.width/60,),*/
                  /*Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: ConstHelper.blackColor,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: ConstHelper.greyColor.withOpacity(0.5),
                          offset: const Offset(0, 5),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: Get.width / 30,
                      horizontal: Get.width / 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Feedback",
                            style: TextStyle(
                              fontSize: 16,
                              color: ConstHelper.whiteColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/image/dropDownSVG.svg',
                          height: Get.width / 22,
                          width: Get.width / 22,
                          color: ConstHelper.whiteColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 20,
                  ),*/
                  Container(
                    decoration: BoxDecoration(
                      color: ConstHelper.cementColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: TextFormField(
                      controller: txtFeedback,
                      focusNode: focusNode,
                      style: TextStyle(
                        fontSize: Get.width * 0.04,
                        color: ConstHelper.blackColor,
                        letterSpacing: 1,
                        height: 1.5,
                        //color: ConstHelper.cementColor,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(
                            color: ConstHelper.cementColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(
                            color: ConstHelper.cementColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(
                            color: ConstHelper.cementColor,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(Get.width / 25),
                        hintText: 'Share your thoughts here...',
                        hintStyle: TextStyle(
                          fontSize: Get.width * 0.04,
                          color: ConstHelper.lightBlackColor,
                          //letterSpacing: 1,
                          //color: ConstHelper.cementColor,
                          fontWeight: FontWeight.normal,
                        ),
                        counterText: '',
                      ),
                      maxLines: 8,
                      maxLength: 250,
                      onChanged: (value) {
                        length.value = value.length;
                      },
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 90,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => Text(
                        '${length.value}/250',
                        style: TextStyle(
                          color: ConstHelper.blackColor,
                          fontSize: Get.width * 0.035,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Get.width / 8,
                    ),
                    child: InkWell(
                      onTap: () async {
                        focusNode.unfocus();
                        if (txtFeedback.text.trim().isEmpty) {
                          ConstHelper.errorDialog(
                            text: 'Please enter the feedback...',
                            seconds: 10,
                          );
                          focusNode.requestFocus();
                        } else if (!(await ConstHelper.checkInternet())) {
                          ConstHelper.errorDialog(
                            text: ConstHelper.internetMsg,
                            seconds: 10,
                          );
                        } else {
                          try {
                            EasyLoading.show(
                              status: ConstHelper.pleaseWaitMsg,
                            );
                            await Future.delayed(
                              const Duration(
                                milliseconds: 100,
                              ),
                            );
                            await ApiHelper.apiHelper
                                .insertFeedback(
                              profileId:
                                  homeController.userData.value.id.toString(),
                              description: txtFeedback.text,
                            )
                                .then(
                              (msg) {
                                EasyLoading.dismiss();
                                if (msg.trim().isEmpty) {
                                  txtFeedback.clear();
                                  length.value = 0;
                                  ConstHelper.errorDialog(
                                    text: ConstHelper.somethingErrorMsg,
                                    seconds: 10,
                                  );
                                } else {
                                  txtFeedback.clear();
                                  length.value = 0;
                                  Get.back();
                                  homeController.advancedDrawerController
                                      .hideDrawer();
                                  if(!mounted) return;
                                  showToastWidget(
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 50),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(179),
                                        // Semi-transparent black background
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white, size: 28),
                                          const SizedBox(width: 14),
                                          Flexible(
                                            child: Text(
                                              msg,
                                              style: TextStyle(
                                                color:
                                                    Colors.white, // White text
                                                fontSize: Get.width * 0.045,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    context: this.context,
                                    duration: const Duration(seconds: 2),
                                    // Short duration for simple toasts
                                    animation: StyledToastAnimation.fade,
                                    // Simple fade animation
                                    reverseAnimation: StyledToastAnimation.fade,
                                    position: StyledToastPosition.bottom,
                                    // Toast appears at the bottom
                                    animDuration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    reverseCurve: Curves.easeOut,
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
                      child: Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: ConstHelper.orangeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          vertical: Get.width / 30,
                        ),
                        child: Text(
                          'Submit',
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
