import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoggedIn = false.obs;
  final RxBool isGuest = false.obs;
  final RxBool isNewUser = false.obs;

  @override
  void onInit() {
    super.onInit();
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
}
