import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sadid/App/routes.dart';

import '../../../../Core/snakbar.dart';

class MakePermanentController extends GetxController {
  // UI state
  final isGuest = true.obs; // you can set based on Firebase currentUser.isAnonymous
  final isLoading = false.obs;

  // form controllers
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final hidePass = true.obs;

  // optional info
  final displayEmail = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void onInit() {
    super.onInit();

    final user = _auth.currentUser;
    if (user != null) {
      isGuest.value = user.isAnonymous;
      displayEmail.value = user.email ?? '';
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }

  void _startLoading() => isLoading.value = true;
  void _stopLoading() => isLoading.value = false;

  bool _isValidEmail(String s) {
    final v = s.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
  }

  // -------------------------------
  // 1) Guest -> Permanent (Email)
  // -------------------------------
  Future<void> makePermanentWithEmail() async {
    final email = emailC.text.trim();
    final pass = passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      AppSnackbar.show("Email and password are required.");
      return;
    }
    if (!_isValidEmail(email)) {
      AppSnackbar.show("Invalid email address.");
      return;
    }
    if (pass.length < 6) {
      AppSnackbar.show("Password must be at least 6 characters.");
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      AppSnackbar.show("No user session found. Please login again.");
      return;
    }
    if (!user.isAnonymous) {
      AppSnackbar.show("This account is already permanent.");
      return;
    }

    _startLoading();
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: pass,
      );
      final result = await user.linkWithCredential(credential);


      isGuest.value = false;
      displayEmail.value = result.user?.email ?? email;

      AppSnackbar.show("Permanent account created!");
      Get.back();
      Get.offAllNamed(routes.navbar_screen);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        AppSnackbar.show("This email is already in use. Try logging in instead.");
      } else if (e.code == 'credential-already-in-use') {
        AppSnackbar.show("This credential is already linked to another account.");
      } else {
        AppSnackbar.show(e.message ?? "Failed. Try again.");
      }
    } catch (_) {
      AppSnackbar.show("Failed. Try again.");
    } finally {
      _stopLoading();
    }
  }

  // --------------------------------
  // 2) Guest -> Permanent (Google)
  // --------------------------------
  Future<void> makePermanentWithGoogle() async {
    final user = _auth.currentUser;
    if (user == null) {
      AppSnackbar.show("No user session found. Please login again.");
      return;
    }
    if (!user.isAnonymous) {
      AppSnackbar.show("This account is already permanent.");
      return;
    }

    _startLoading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // user cancelled
        _stopLoading();
        return;
      }

      final googleAuth = await googleUser.authentication;

      final googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔥 Link anonymous user to Google
      final result = await user.linkWithCredential(googleCredential);

      isGuest.value = false;
      displayEmail.value = result.user?.email ?? '';

      AppSnackbar.show("Google connected! Account is now permanent.");
      Get.back();
      Get.offAllNamed(routes.navbar_screen);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        AppSnackbar.show("This Google account is already linked to another user.");
      } else if (e.code == 'account-exists-with-different-credential') {
        AppSnackbar.show("An account already exists with the same email but different sign-in method.");
      } else {
        AppSnackbar.show(e.message ?? "Google sign-in failed.");
      }
    } catch (_) {
      AppSnackbar.show("Google sign-in failed.");
    } finally {
      _stopLoading();
    }
  }
}
