import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/snakbar.dart';
import 'package:sadid/Data/Repository/DataRepository.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DataRepository _repository = Get.find<DataRepository>();

  final RxBool isLoggedIn = false.obs;
  final RxBool isGuest = false.obs;
  final RxBool isNewUser = false.obs;
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final User? user = _auth.currentUser;

    // ✅ 1) Set language FIRST from Local DB (Offline First)
    await _setLanguage();

    // ✅ 2) Detect user state
    if (user == null) {
      isNewUser.value = true;
      isLoggedIn.value = false;
      isGuest.value = false;
      await checkInternetOrShowOffline();
      debugPrint("User status: NEW USER");
    } else if (user.isAnonymous) {
      isGuest.value = true;
      isLoggedIn.value = false;
      isNewUser.value = false;
      await checkInternetOrShowOffline();
      debugPrint("User status: GUEST USER");
    } else {
      isLoggedIn.value = true;
      isGuest.value = false;
      isNewUser.value = false;
      await checkInternetOrShowOffline();
      debugPrint("User status: LOGGED IN USER");
    }

    // ⏱ 3) Delay then navigate
    Future.delayed(const Duration(milliseconds: 700), _handleNextAction);
  }

  /// 🌍 Language logic - Now uses Repository (Offline First)
  Future<void> _setLanguage() async {
    try {
      final settings = await _repository.getSettings();
      final locale = Locale(settings.languageCode, settings.countryCode);
      Get.updateLocale(locale);
    } catch (e) {
      // Fallback to default
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void _handleNextAction() {
    if (isLoggedIn.value || isGuest.value) {
      Get.offAllNamed(routes.navbar_screen);
    } else {
      Get.offAllNamed(routes.login_screen);
    }
  }

  Future<void> checkInternetOrShowOffline() async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasNetwork = connectivity != ConnectivityResult.none;

    if (!hasNetwork) {
      isOffline.value = true;
      AppSnackbar.show("You're using Trackio offline. Please connect to the internet.");
      return;
    }

    final hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      isOffline.value = true;
      AppSnackbar.show("You're using Trackio offline. Please connect to the internet.");
    }
  }
}
