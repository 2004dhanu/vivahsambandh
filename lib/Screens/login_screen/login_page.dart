import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/home_controller.dart';
import '../../models/user_data_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/shared_pref_helper.dart';
import '../../vivah_app/core/services/session_manager.dart';
import '../../vivah_app/core/services/firebase_notification_service.dart';
import '../../vivah_app/models/user_model.dart';
import '../../vivah_app/views/legal/legal_webview_screen.dart';
import '../home_screen/home_page.dart';
import '../sign_up_screen/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  HomeController homeController = Get.put(HomeController());
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool hidePassword = true.obs;

  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    //EasyLoading.dismiss();
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: formKey,
          child: Stack(
            children: [
              // Background Image with Premium Dark Pink Gradient Overlay
              Container(
                width: Get.width,
                height: Get.height,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/image/loginPage.jpg',
                      width: Get.width,
                      height: Get.height,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      width: Get.width,
                      height: Get.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ConstHelper.darkRedColor.withOpacity(0.85),
                            ConstHelper.orangeDarkColor.withOpacity(0.9),
                            ConstHelper.orangeColor.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: Get.height * 0.06,
                        ),
                        Center(
                          child: Container(
                            height: Get.width / 2.4,
                            width: Get.width / 2.4,
                            decoration: BoxDecoration(
                              color: ConstHelper.whiteColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/image/vs_app_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Get.width / 20,
                        ),
                        Text(
                          'AGRAWAL SAMAJ VIKAS TRUST',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: ConstHelper.whiteColor,
                            fontSize: Get.width * 0.062,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.04,
                        ),
                        Container(
                          padding: EdgeInsets.all(Get.width * 0.05),
                          decoration: BoxDecoration(
                            color: ConstHelper.whiteColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ConstHelper.whiteColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login'.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: ConstHelper.whiteColor,
                                  fontSize: Get.width * 0.05,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: Get.width / 20,
                              ),
                              TextFormField(
                                controller: txtUsername,
                                cursorColor: ConstHelper.whiteColor,
                                style: GoogleFonts.inter(
                                  fontSize: Get.width * 0.042,
                                  color: ConstHelper.whiteColor,
                                ),
                                focusNode: usernameFocusNode,
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Please enter userId';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: ConstHelper.whiteColor.withOpacity(0.6),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: ConstHelper.whiteColor.withOpacity(0.6),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width / 25,
                                    vertical: 16,
                                  ),
                                  labelText: 'User ID',
                                  errorStyle: GoogleFonts.inter(
                                    fontSize: Get.width * 0.035,
                                    color: ConstHelper.whiteColor,
                                  ),
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: Get.width * 0.038,
                                    color: ConstHelper.whiteColor.withOpacity(0.9),
                                  ),
                                  prefixIcon: SizedBox(
                                    height: Get.width / 20,
                                    width: Get.width / 20,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/image/personSVG.svg',
                                        height: Get.width / 20,
                                        width: Get.width / 20,
                                        fit: BoxFit.contain,
                                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.width / 20,
                              ),
                              TextFormField(
                                controller: txtPassword,
                                style: GoogleFonts.inter(
                                  color: ConstHelper.whiteColor,
                                  fontSize: Get.width * 0.042,
                                ),
                                maxLength: 12,
                                cursorColor: ConstHelper.whiteColor,
                                focusNode: passwordFocusNode,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: hidePassword.value,
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: ConstHelper.whiteColor.withOpacity(0.6),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: ConstHelper.whiteColor.withOpacity(0.6),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: GoogleFonts.inter(
                                    fontSize: Get.width * 0.035,
                                    color: ConstHelper.whiteColor,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: Get.width / 25,
                                    vertical: 16,
                                  ),
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.inter(
                                    fontSize: Get.width * 0.038,
                                    color: ConstHelper.whiteColor.withOpacity(0.9),
                                  ),
                                  prefixIcon: SizedBox(
                                      height: Get.width / 20,
                                      width: Get.width / 20,
                                      child: Center(
                                          child: SvgPicture.asset(
                                            'assets/image/passwordSVG.svg',
                                            height: Get.width / 20,
                                            width: Get.width / 20,
                                            fit: BoxFit.contain,
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          ))),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      hidePassword.value = !hidePassword.value;
                                    },
                                    icon: hidePassword.value
                                        ? Image.asset(
                                      'assets/image/eyeVisibility.png',
                                      height: Get.width / 20,
                                      width: Get.width / 20,
                                      fit: BoxFit.contain,
                                      color: ConstHelper.whiteColor.withOpacity(0.8),
                                    )
                                        : SvgPicture.asset(
                                      'assets/image/eyeNoVisibleSVG.svg',
                                      height: Get.width / 20,
                                      width: Get.width / 20,
                                      fit: BoxFit.contain,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.width / 12,
                              ),
                            GestureDetector(
                              onTap: () async {
                                EasyLoading.show(
                                  status: ConstHelper.pleaseWaitMsg,
                                );
                                await Future.delayed(
                                  Duration(
                                    milliseconds: 200,
                                  ),
                                );
                                usernameFocusNode.unfocus();
                                passwordFocusNode.unfocus();
                                if (!(await ConstHelper.checkInternet())) {
                                  EasyLoading.dismiss();
                                  ConstHelper.errorDialog(
                                    text: ConstHelper.internetMsg,
                                    seconds: 10,
                                  );
                                } else {
                                  ///523
                                  ///asvt50965
                                  if (txtUsername.text.trim().isEmpty) {
                                    EasyLoading.dismiss();
                                    usernameFocusNode.requestFocus();
                                  } else if (txtPassword.text.trim().isEmpty) {
                                    EasyLoading.dismiss();
                                    passwordFocusNode.requestFocus();
                                  }

                                  if (formKey.currentState!.validate()) {
                                    try {
                                      String? token;
                                      try {
                                        if (Platform.isIOS) {
                                          token = await FirebaseMessaging.instance.getAPNSToken();
                                          debugPrint('APNS Token: $token');
                                        } else {
                                          token = await FirebaseNotificationService.instance.getFcmToken();
                                          debugPrint('FCM Token: $token');
                                        }
                                      } catch (e) {
                                        debugPrint('Error getting token: $e');
                                      }

                                      if (token == null || token.trim().isEmpty || token == 'android' || token.trim() == 'r' || token.trim().length < 5 || token.contains('test_dev') || token.contains('android_dev_')) {
                                        token = await FirebaseNotificationService.instance.getFcmToken();
                                      }

                                      homeController.firebaseFCMToken.value = token;
                                      log("Token : $token");
                                      log("Token : ${homeController.firebaseFCMToken.value}");

                                      await ApiHelper.apiHelper
                                          .loginUser(
                                        profileId: txtUsername.text.toString(),
                                        password: txtPassword.text.trim(),
                                        deviceId: token,
                                      )
                                          .then(
                                            (userData) async {
                                          if (userData.isNotEmpty) {
                                            if (userData['code'] == 200) {
                                              UserDataModel userDataModel =
                                              UserDataModel.fromJson(
                                                  userData);

                                              debugPrint('userDataModel: ${userDataModel.data}');
                                              debugPrint(userDataModel.data?.token ??
                                                  "");
                                              SharedPrefHelper.sharedPreferences
                                                  .setBool(
                                                'login',
                                                true,
                                              );
                                              SharedPrefHelper.sharedPreferences
                                                  .setString(
                                                'userData',
                                                jsonEncode(userDataModel),
                                              );
                                              try {
                                                final u = userDataModel.data?.user;
                                                final dynamic paymentDetails = userData['payment_details'] ?? userDataModel.paymentDetails;
                                                final userModel = UserModel(
                                                  id: u?.id ?? int.tryParse(txtUsername.text) ?? 0,
                                                  name: u?.name ?? '',
                                                  mobile: u?.profileMainContactNum ?? '',
                                                  gender: u?.profileGender,
                                                  userType: int.tryParse(u?.profileType?.toString() ?? '1') ?? 1,
                                                  status: 'Approved',
                                                  faceImage: u?.profileFullFacePhotoFileName,
                                                  userCurrentCity: u?.profilePresentCity,
                                                  paymentDetails: paymentDetails,
                                                );
                                                await SessionManager.instance.saveSession(
                                                  user: userModel,
                                                  token: userDataModel.data?.token,
                                                );
                                              } catch (_) {}
                                              await homeController
                                                  .getUserData();
                                              EasyLoading.dismiss();
                                              homeController
                                                  .advancedDrawerController =
                                                  AdvancedDrawerController();
                                              Get.off(
                                                const HomePage(),
                                              );
                                              Get.snackbar(
                                                "Success",
                                                "Login Successfully",
                                                snackPosition:
                                                SnackPosition.BOTTOM,
                                              );
                                            } else {
                                              EasyLoading.dismiss();
                                              Get.snackbar(
                                                "Error! 1",
                                                userData['msg'] ??
                                                    ConstHelper
                                                        .somethingErrorMsg,
                                                snackPosition:
                                                SnackPosition.BOTTOM,
                                              );
                                            }
                                          } else {
                                            EasyLoading.dismiss();
                                            Get.snackbar(
                                              "Error! 2",
                                              'Unauthorised.',
                                              snackPosition:
                                              SnackPosition.BOTTOM,
                                            );
                                          }
                                        },
                                      );
                                    } catch (error) {
                                      EasyLoading.dismiss();
                                      debugPrint('Error3: $error');
                                      Get.snackbar(
                                        "Error! 3",
                                        error.toString(),
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    }
                                  } else {
                                    EasyLoading.dismiss();
                                  }
                                }
                              },
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  gradient: ConstHelper.premiumPinkGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ConstHelper.orangeColor.withOpacity(0.35),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                  vertical: Get.width / 26,
                                ),
                                child: Text(
                                  'Login'.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: ConstHelper.whiteColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Get.width * 0.046,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Get.width / 12,
                            ),
                            Center(
                              child: Text(
                                "Don't have an account?",
                                style: GoogleFonts.inter(
                                  color: ConstHelper.whiteColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                  fontSize: Get.width * 0.038,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 6),
                            Center(
                              child: InkWell(
                                onTap: () async {
                                  EasyLoading.show(status: 'Please wait...');
                                  await Future.delayed(
                                    const Duration(
                                      milliseconds: 100,
                                    ),
                                  );
                                  try {
                                    if (await ConstHelper.checkInternet()) {
                                      homeController.communityDataList.value =
                                      await ApiHelper.apiHelper
                                          .getCommunityDataList();
                                      homeController.budgetCateModel.value =
                                      await ApiHelper.apiHelper
                                          .getBudgetCate();
                                      await homeController.getDropDownData();
                                      homeController
                                          .gotraDataListCommunityIdWise
                                          .value = [];
                                      homeController.educationDataList.value =
                                      await ApiHelper.apiHelper
                                          .getEducationDataList();
                                      Get.to(
                                        const SignUpPage(),
                                      );
                                      EasyLoading.dismiss();
                                    } else {
                                      EasyLoading.dismiss();
                                      ConstHelper.errorDialog(
                                        text: ConstHelper.internetMsg,
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
                                },
                                child: Text(
                                  "Join us today!",
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Get.width * 0.046,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => Get.to(() => const LegalWebViewScreen(initialTabIndex: 0)),
                                  child: Text(
                                    'Privacy Policy',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white70,
                                    ),
                                  ),
                                ),
                                const Text('  •  ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                InkWell(
                                  onTap: () => Get.to(() => const LegalWebViewScreen(initialTabIndex: 1)),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Get.width / 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
