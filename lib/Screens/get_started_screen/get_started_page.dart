import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/home_controller.dart';
import '../../models/user_data_model.dart';
import '../../utils/api_helper.dart';
import '../../utils/const_helper.dart';
import '../../utils/firebase_helper.dart';
import '../../utils/shared_pref_helper.dart';
import '../home_screen/home_page.dart';
import '../login_screen/login_page.dart';
import '../../vivah_app/views/auth/otp_login_screen.dart';
import '../../vivah_app/core/services/firebase_notification_service.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    Timer(
      const Duration(
        seconds: 10,
      ),
      () => Get.off(
        const OtpLoginScreen(),
      ),
    );

    /* bool login = SharedPrefHelper.sharedPreferences.getBool('login') ?? false;
    Timer(
      Duration(
        seconds: login ? 2 : 10,
      ),
      () async {
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
        } else {
          try {
            homeController.firebaseFCMToken.value =
                await FirebaseHelper.firebaseHelper.getFirebaseToken();
            if (login) {
              await homeController.getUserData();
              await ApiHelper.apiHelper
                  .loginUser(
                profileId:
                    (homeController.userDataWithToken.value.data?.user == null
                        ? '0'
                        : (homeController.userDataWithToken.value.data?.user?.profileMainContactNum ??
                           homeController.userDataWithToken.value.data?.user?.id?.toString() ??
                           '0')),
                password:
                    (homeController.userDataWithToken.value.data?.user == null
                        ? '0'
                        : homeController.userDataWithToken.value.data?.user
                                ?.profilePassword ??
                            '0'),
                deviceId: homeController.firebaseFCMToken.value.isNotEmpty && homeController.firebaseFCMToken.value != 'r'
                    ? homeController.firebaseFCMToken.value
                    : await FirebaseNotificationService.instance.getFcmToken(),
              )
                  .then(
                (userData) async {
                  if (userData.isNotEmpty) {
                    if (userData['code'] == 200) {
                      UserDataModel userDataModel =
                          UserDataModel.fromJson(userData);
                      SharedPrefHelper.sharedPreferences.setString(
                        'userData',
                        jsonEncode(userDataModel),
                      );
                      await homeController.getUserData();
                      EasyLoading.dismiss();
                      Get.off(
                        const HomePage(),
                      );
                    } else {
                      EasyLoading.dismiss();
                      Get.off(
                        const HomePage(),
                      );
                    }
                  } else {
                    EasyLoading.dismiss();
                    Get.off(
                      const HomePage(),
                    );
                  }
                },
              );
              // await homeController.getUserData().then((value) async {
              //   if(homeController.firebaseFCMToken.value.substring(0,50) == (homeController.userDataWithToken.value.user == null ? '' : homeController.userDataWithToken.value.user?.profileDeviceId))
              //   {
              //     EasyLoading.dismiss();
              //     Get.off(const HomePage(),);
              //   }
              //   else if(homeController.firebaseFCMToken.trim().isNotEmpty) {
              //     await ApiHelper.apiHelper.loginUser(profileId: (homeController.userDataWithToken.value.user == null ? '0' : homeController.userDataWithToken.value.user?.profileDeviceId ?? '0'), password: (homeController.userDataWithToken.value.user == null ? '0' : homeController.userDataWithToken.value.user?.profileCpassword ?? '0'), deviceId: homeController.firebaseFCMToken.value.substring(0,50),).then((userData) {
              //       if(userData.isNotEmpty)
              //       {
              //         if(userData['code'] == 200)
              //         {
              //           UserDataModel userDataModel = UserDataModel.fromJson(userData['data'] ?? {});
              //           SharedPrefHelper.sharedPreferences.setString('userData', jsonEncode(userDataModel),);
              //           EasyLoading.dismiss();
              //           Get.off(const HomePage(),);
              //         }
              //         else
              //         {
              //           EasyLoading.dismiss();
              //           Get.off(const HomePage(),);
              //         }
              //       }
              //       else
              //       {
              //         EasyLoading.dismiss();
              //         Get.off(const HomePage(),);
              //       }
              //     },);
              //   }
              //   else
              //   {
              //     EasyLoading.dismiss();
              //     Get.off(const HomePage(),);
              //   }
              // },);
            } else {
              EasyLoading.dismiss();
              Get.off(
                const LoginPage(),
              );
            }
          } catch (error) {
            if (login) {
              EasyLoading.dismiss();
              Get.off(
                const HomePage(),
              );
            } else {
              EasyLoading.dismiss();
              Get.off(
                const LoginPage(),
              );
            }
          }
        }
      },
    );*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstHelper.whiteColor,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width / 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /* SizedBox(
                  height: Get.width,
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: Get.width / 6.5,
                            ),
                            DottedBorder(
                              color: ConstHelper.cementColor,
                              borderType: BorderType.Circle,
                              child: Container(
                                height: Get.width / 1.5,
                                width: Get.width / 1.5,
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(
                                  Get.width / 9,
                                ),
                                child: DottedBorder(
                                  color: ConstHelper.cementColor,
                                  borderType: BorderType.Circle,
                                  child: Container(
                                    height: Get.width / 1.5,
                                    width: Get.width / 1.5,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(
                                      Get.width / 10,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ConstHelper.darkRedColor,
                                          width: 1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        // borderRadius: BorderRadius.circular(1000),
                                        child: Image.asset(
                                          'assets/image/vs_app_logo.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: CircularAnimation(
                          radius: 70,
                          images: [
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted3.jpg',
                                height: Get.width / 12,
                                width: Get.width / 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 22,
                              width: Get.width / 22,
                              decoration: BoxDecoration(
                                color: ConstHelper.blackColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted4.jpg',
                                height: Get.width / 12,
                                width: Get.width / 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 22,
                              width: Get.width / 22,
                              decoration: BoxDecoration(
                                color: ConstHelper.blackColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted5.jpg',
                                height: Get.width / 12,
                                width: Get.width / 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 22,
                              width: Get.width / 22,
                              decoration: BoxDecoration(
                                color: ConstHelper.orangeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          animationDuration: Duration(seconds: 20),
                        ),
                      ),
                      Center(
                        child: CircularAnimation(
                          radius: 120,
                          images: [
                            Container(
                              height: Get.width / 12,
                              width: Get.width / 12,
                              decoration: BoxDecoration(
                                color: ConstHelper.blackColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted1.jpg',
                                height: Get.width / 8,
                                width: Get.width / 8,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 12,
                              width: Get.width / 12,
                              decoration: BoxDecoration(
                                color: ConstHelper.orangeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted2.jpg',
                                height: Get.width / 8,
                                width: Get.width / 8,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 12,
                              width: Get.width / 12,
                              decoration: BoxDecoration(
                                color: ConstHelper.blackColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted6.jpg',
                                height: Get.width / 8,
                                width: Get.width / 8,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: Get.width / 12,
                              width: Get.width / 12,
                              decoration: BoxDecoration(
                                color: ConstHelper.orangeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            ClipOval(
                              // borderRadius: BorderRadius.circular(1000),
                              child: Image.asset(
                                'assets/image/getStarted7.jpg',
                                height: Get.width / 8,
                                width: Get.width / 8,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                          animationDuration: Duration(seconds: 20),
                        ),
                      ),
                    ],
                  ),
                ),*/
                SizedBox(
                  height: Get.height * 0.08,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ConstHelper.whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/image/vs_app_logo.png",
                    width: Get.width / 2.2,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                Center(
                  child: Text(
                    "Find Your Perfect Match\nEffortless Bride & Groom Search!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      color: ConstHelper.darkRedColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Get.width * 0.065,
                      height: 1.3,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 18,
                ),
                Center(
                  child: Text(
                    "Find your ideal life partner effortlessly with our smart matchmaking app! Verified profiles, personalized matches, and seamless search—love begins here!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: ConstHelper.lightBlackColor.withOpacity(0.8),
                      fontSize: Get.width * 0.04,
                      letterSpacing: 0.2,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.08,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Get.width / 12,
                  ),
                  child: GestureDetector(
                    onTap: () async {
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
                      } else {
                        bool login = SharedPrefHelper.sharedPreferences
                            .getBool('login') ??
                            false;
                        try {
                          homeController.firebaseFCMToken.value =
                          await FirebaseHelper.firebaseHelper
                              .getFirebaseToken();
                          if (login) {
                            await homeController.getUserData();
                            await ApiHelper.apiHelper
                                .loginUser(
                              profileId: (homeController
                                  .userDataWithToken.value.data?.user ==
                                  null
                                  ? '0'
                                  : (homeController.userDataWithToken.value.data
                                  ?.user?.profileMainContactNum ??
                                  homeController.userDataWithToken.value.data
                                  ?.user?.id?.toString() ??
                                  '0')),
                              password: (homeController
                                  .userDataWithToken.value.data?.user ==
                                  null
                                  ? '0'
                                  : homeController.userDataWithToken.value.data
                                  ?.user?.profilePassword ??
                                  '0'),
                              deviceId: homeController.firebaseFCMToken.value.isNotEmpty && homeController.firebaseFCMToken.value != 'r'
                                  ? homeController.firebaseFCMToken.value
                                  : await FirebaseNotificationService.instance.getFcmToken(),
                            )
                                .then(
                                  (userData) async {
                                if (userData.isNotEmpty) {
                                    if (userData['code'] == 200) {
                                      UserDataModel userDataModel =
                                      UserDataModel.fromJson(userData);
                                      SharedPrefHelper.sharedPreferences
                                          .setString(
                                        'userData',
                                        jsonEncode(userDataModel),
                                      );
                                      await homeController.getUserData();
                                      EasyLoading.dismiss();
                                      Get.off(
                                        const HomePage(),
                                      );
                                    } else {
                                      EasyLoading.dismiss();
                                      Get.off(
                                        const HomePage(),
                                      );
                                    }
                                  } else {
                                    EasyLoading.dismiss();
                                    Get.off(
                                      const HomePage(),
                                    );
                                  }
                                },
                              );
                          } else {
                            EasyLoading.dismiss();
                            Get.off(
                              const OtpLoginScreen(),
                            );
                          }
                        } catch (error) {
                          if (login) {
                            EasyLoading.dismiss();
                            Get.off(
                              const HomePage(),
                            );
                          } else {
                            EasyLoading.dismiss();
                            Get.off(
                              const OtpLoginScreen(),
                            );
                          }
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
                        'Begin Your Search',
                        style: GoogleFonts.inter(
                          color: ConstHelper.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Get.width * 0.046,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.width / 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircularAnimation extends StatefulWidget {
  final List<Widget> images;
  final Duration animationDuration;
  final double radius;

  const CircularAnimation({
    super.key, required this.images,
    required this.animationDuration,
    required this.radius});

  @override
  CircularAnimationState createState() => CircularAnimationState();
}

class CircularAnimationState extends State<CircularAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  RxDouble animationValue = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller)
      ..addListener(() {
        // print('SS ${_animation.value}');
        animationValue.value = _animation.value;
        // setState(() {});
//         _controller.repeat();
      })
      ..addStatusListener((status) {
        _controller.repeat();
      });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Stack(
        children: [
          for (int i = 0; i < widget.images.length; i++)
            OrbitingImage(
              radius: widget.radius, // adjust the radius as needed
              angle: animationValue.value + (i * 2 * pi / widget.images.length),
              child: widget.images[i],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class OrbitingImage extends StatelessWidget {
  final double radius;
  final double angle;
  final Widget child;

  const OrbitingImage({
    super.key,
    required this.radius,
    required this.angle,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(radius * cos(angle), radius * sin(angle)),
      child: child,
    );
  }
}
