import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/home_controller.dart';
import '../screens/home_screen/home_page.dart';
import 'const_helper.dart';
import 'shared_pref_helper.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool isChecking = false;
  HomeController homeController = Get.put(HomeController());

  /// Timer for 5 seconds to check connection
  @override
  void initState() {
    super.initState();
    /*Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) checkConnection();
    });*/
  }

  /// check network connection
  Future<void> checkConnection() async {
    setState(() => isChecking = true);
    if (await NetworkConnectivity.checkInternet()) {

      debugPrint("Internet connection found");
      try {
        EasyLoading.show(status: ConstHelper.pleaseWaitMsg);

        final login =
            SharedPrefHelper.sharedPreferences.getBool('login') ?? false;
        if (!mounted) return;

        EasyLoading.dismiss();
        if (login) {
          Get.off(const HomePage());
        } else {
          Get.offNamed('getStarted');
        }
      } catch (e) {
        setState(() => isChecking = false);
        EasyLoading.dismiss();
        if (mounted) {
          Get.offNamed('getStarted');
        }
      } finally {
        setState(() => isChecking = false);
      }
    } else {
      Get.snackbar(
        "No Internet",
        "Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/img_no_internet.png',
                  width: Get.width * 0.05,
                  height: Get.width * 0.05,
                  //  repeat: true,
                ),
                const SizedBox(height: 24),
                const Text(
                  "You're offline",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please check your internet connection to explore deco panel.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: isChecking ? null : checkConnection,
                  icon: const Icon(Icons.refresh),
                  label: isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Retry Connection"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                /* OutlinedButton.icon(
                  onPressed: () {
                  //  AppSettings.openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text("Open Internet Settings"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internet Connection Checking
class NetworkConnectivity {
  static Future<bool> checkInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.first == ConnectivityResult.none) return false;

    try {
      final result =
          await http.get(Uri.parse('https://www.google.com')).timeout(
                const Duration(seconds: 5),
              );
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
