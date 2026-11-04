import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';

import 'screens/home_screen/home_page.dart';
import 'screens/login_screen/login_page.dart';
import 'screens/splash_screen/splash_common_page.dart';
import 'utils/const_helper.dart';
import 'utils/shared_pref_helper.dart';

import 'vivah_app/core/services/firebase_options.dart';
import 'vivah_app/views/auth/otp_login_screen.dart';
import 'vivah_app/views/register/register_screen.dart';
import 'vivah_app/views/home/vivah_home_screen.dart';
import 'vivah_app/core/services/firebase_notification_service.dart';
import 'vivah_app/views/admin/admin_dashboard_screen.dart';
import 'vivah_app/views/payment/payment_history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: VivahFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("❌ Firebase Initialization: $e");
    // Fallback initialize without options if already configured natively by google-services
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (_) {}
  }

  await SharedPrefHelper.sharedPrefHelper.initSharedPref();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  configLoading();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: ConstHelper.orangeDarkColor,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: ConstHelper.orangeDarkColor,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: ConstHelper.whiteColor,
  ));

  // Render app immediately to prevent any blank startup screen
  runApp(const MyApp());

  // Initialize notifications asynchronously in background
  try {
    FirebaseNotificationService.instance.initialize().then((_) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      debugPrint("✅ Firebase & Notifications initialized successfully with VivahSambandh project");
    }).catchError((e) {
      debugPrint("⚠️ Notification init notice: $e");
    });
  } catch (e) {
    debugPrint("⚠️ Notification service startup notice: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'vivahsambandh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: ConstHelper.orangeColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConstHelper.orangeColor,
          primary: ConstHelper.orangeColor,
          secondary: ConstHelper.orangeDarkColor,
          background: ConstHelper.whiteColor,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: ConstHelper.orangeDarkColor,
          foregroundColor: ConstHelper.whiteColor,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      navigatorKey: ConstHelper.navigatorKey,
      builder: EasyLoading.init(),
      routes: {
        '/': (p0) => const SplashCommonPage(),
        'getStarted': (p0) => const OtpLoginScreen(),
        'login': (p0) => const LoginPage(),
        'home': (p0) => const HomePage(),
        'otp_login': (p0) => const OtpLoginScreen(),
        'register': (p0) => const RegisterScreen(),
        'vivah_home': (p0) => const VivahHomeScreen(),
        'admin_dashboard': (p0) => const AdminDashboardScreen(),
        'payment_history': (p0) => const PaymentHistoryScreen(),
      },
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.doubleBounce
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 16.0
    ..progressColor = ConstHelper.orangeColor
    ..backgroundColor = ConstHelper.whiteColor
    ..indicatorColor = ConstHelper.orangeColor
    ..textColor = ConstHelper.darkRedColor
    ..maskColor = ConstHelper.darkRedColor.withOpacity(0.3)
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.custom
    ..dismissOnTap = false;
}