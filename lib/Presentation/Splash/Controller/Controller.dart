import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/snakbar.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // ✅ 1) Detect user state
    if (user == null) {
      isNewUser.value = true;
      isLoggedIn.value = false;
      isGuest.value = false;
      debugPrint("User status: NEW USER");
    } else if (user.isAnonymous) {
      isGuest.value = true;
      isLoggedIn.value = false;
      isNewUser.value = false;
      debugPrint("User status: GUEST USER");
    } else {
      isLoggedIn.value = true;
      isGuest.value = false;
      isNewUser.value = false;
      debugPrint("User status: LOGGED IN USER");
    }

    // ✅ 2) Set language from Firebase (Direct Firestore fetch)
    await _setLanguage();

    // ✅ 3) Network check
    await checkInternetOrShowOffline();

    // ⏱ 4) Delay then navigate
    Future.delayed(const Duration(milliseconds: 700), _handleNextAction);
  }

  /// 🌍 Language logic - Now uses Firebase directly
  Future<void> _setLanguage() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.updateLocale(const Locale('bn', 'BD'));
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['languageCode'] != null) {
          final locale = Locale(
            data['languageCode'],
            data['countryCode'] ?? '',
          );
          Get.updateLocale(locale);
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching settings from Firebase: $e");
    }

    // Fallback to default
    Get.updateLocale(const Locale('bn', 'BD'));
  }

  void _handleNextAction() {
    if (isLoggedIn.value || isGuest.value) {
      Get.offAllNamed(routes.navbar_screen);
    } else {
      Get.offAllNamed(routes.login_screen);
    }
  }

  Future<void> checkInternetOrShowOffline() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
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
