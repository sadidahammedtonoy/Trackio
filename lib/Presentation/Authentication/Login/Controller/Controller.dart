import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';
import 'package:sadid/App/routes.dart';

class loginController extends GetxController {
  var password = true.obs;
  var language = "English".obs;

  void toggleLanguage() {
    if (Get.locale?.languageCode == 'en') {
      Get.updateLocale(const Locale('bn', 'BD'));
      language.value = "Bangla";
    } else {
      Get.updateLocale(const Locale('en', 'US'));
      language.value = "English";
    }
  }

  Future<void> loginWithEmailPassword({required String email, required String password}) async {
    AppLoader.show();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      AppLoader.hide();
      Get.offAllNamed(routes.navbar_screen);
    } on FirebaseAuthException catch (e) {
      AppLoader.hide();
      AppSnackbar.show(e.message ?? "Login Failed".tr);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("An unexpected error occurred.".tr);
    }
  }

  Future<void> signInWithGoogle() async {
    AppLoader.show();
    try {
      // If the app is crashing on Google Sign-In, it's often due to a
      // configuration issue. Please ensure the following:
      // 1. You have a `google-services.json` file in your `android/app` directory.
      // 2. The SHA-1 fingerprint of your app is registered in your Firebase project settings.
      //    For release builds, you'll need to add the release SHA-1 as well.
      // 3. If you are authenticating with Firebase, you may need to provide the
      //    web client ID to the GoogleSignIn constructor to get an idToken.
      //    final GoogleSignIn _googleSignIn = GoogleSignIn(serverClientId: 'YOUR_WEB_CLIENT_ID');
      //    You can find this ID in your google-services.json file (client_type: 3).

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        AppLoader.hide();
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      AppLoader.hide();
      Get.offAllNamed(routes.navbar_screen);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Google Sign-In Failed: ".tr + e.toString());
    }
  }

  Future<void> signInWithApple() async {
    AppLoader.show();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Correctly create the AuthCredential
      final credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);
      AppLoader.hide();
      Get.offAllNamed(routes.navbar_screen);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Apple Sign-In Failed: ".tr + e.toString());
    }
  }


  Future<void> loginAsGuest() async {
    AppLoader.show();
    try {
      await FirebaseAuth.instance.signInAnonymously();
      AppLoader.hide();
      Get.offAllNamed(routes.navbar_screen);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Guest login failed.".tr);
    }
  }
}
