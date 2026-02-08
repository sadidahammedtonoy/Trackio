import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/snakbar.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoggedIn = false.obs;
  final RxBool isGuest = false.obs;
  final RxBool isNewUser = false.obs;
  final RxBool isOffline = false.obs;


  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {});
    _init();
  }

  Future<void> _init() async {
    final User? user = _auth.currentUser;

    // ✅ 1) Set language FIRST
    await _setLanguage(user);

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
    Future.delayed(const Duration(milliseconds: 1700), _handleNextAction);
  }

  /// 🌍 Language logic
  Future<void> _setLanguage(User? user) async {
    // ✅ DEFAULT = English
    Locale locale = const Locale('en', 'US');

    // Logged-in (non-guest) → try Firebase
    if (user != null && !user.isAnonymous) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('app')
            .get();

        if (doc.exists) {
          final data = doc.data();
          final lang = (data?['languageCode'] ?? 'en').toString();
          final country = (data?['countryCode'] ?? 'US').toString();
          locale = Locale(lang, country);
        }
      } catch (_) {
        // silently fall back to English
      }
    }

    // ✅ Apply locale
    Get.updateLocale(locale);
  }

  void _handleNextAction() {
    if (isLoggedIn.value || isGuest.value) {
      Get.offAllNamed(routes.navbar_screen);
    } else {
      Get.offAllNamed(routes.login_screen);
    }
  }


  Future<void> checkInternetOrShowOffline() async {
    // 1) Quick check: any network?
    final connectivity = await Connectivity().checkConnectivity();
    final hasNetwork = connectivity != ConnectivityResult.none;

    if (!hasNetwork) {
      isOffline.value = true;
      AppSnackbar.show("You're using Trackio offline. Please connect to the internet.");
    }

    // 2) Real check: can we reach internet?
    final hasInternet = await InternetConnectionChecker().hasConnection;
    if (!hasInternet) {
      isOffline.value = true;
      AppSnackbar.show("You're using Trackio offline. Please connect to the internet.");
    }
  }

}
