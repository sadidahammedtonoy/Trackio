import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';
import '../../../Features/caregories/Controller/Controller.dart';

class loginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var password = true.obs;

  /// UI toggle (English / বাংলা)
  var language = "English".obs;

  @override
  void onInit() {
    super.onInit();

    final code = Get.locale?.languageCode ?? 'en';

    language = (code == 'bn') ? "বাংলা".obs : "English".obs;
  }

  /// Optional loader flag (you already use it in google sign-in)
  final isLoading = false.obs;

  // -------------------- Language Helpers --------------------

  void toggleLanguage() {
    if (language.value == "English") {
      language.value = "বাংলা";
    } else {
      language.value = "English";
    }

    // Update only locally (no firebase here, because user may not be logged in yet)
    Get.updateLocale(
      language.value == "English"
          ? const Locale('en', 'US')
          : const Locale('bn', 'BD'),
    );
  }

  DocumentReference<Map<String, dynamic>> _langDoc(String uid) {
    return _db.collection('users').doc(uid).collection('settings').doc('app');
  }

  Locale _localeFromToggle() {
    return (language.value == "বাংলা")
        ? const Locale('bn', 'BD')
        : const Locale('en', 'US');
  }

  /// ✅ After successful login:
  /// 1) If firebase has saved language -> apply it
  /// 2) else -> save current toggle language
  /// 3) Navigate to home
  Future<void> applyOrSaveLanguageAndContinue(User user) async {
    final fallbackLocale = _localeFromToggle();

    try {
      final doc = await _langDoc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        final langCode = (data["languageCode"] ?? "en").toString();
        final countryCode = (data["countryCode"] ?? "US").toString();

        Get.updateLocale(Locale(langCode, countryCode));
      } else {
        // No saved language -> save current toggle selection
        Get.updateLocale(fallbackLocale);

        await _langDoc(user.uid).set({
          "languageCode": fallbackLocale.languageCode,
          "countryCode": fallbackLocale.countryCode,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // If firebase fails, just apply local toggle
      Get.updateLocale(fallbackLocale);
    }

    // Continue
    Get.offAllNamed(routes.navbar_screen);
  }

  // -------------------- Guest Login --------------------

  Future<void> loginAsGuest() async {
    try {
      AppLoader.show(message: "Signing in as guest...".tr);

      final UserCredential credential = await _auth.signInAnonymously();
      final User? user = credential.user;

      if (user == null) {
        AppSnackbar.show("Anonymous user is null".tr);
        throw Exception("Anonymous user is null");
      }
      if (!user.isAnonymous) {
        AppSnackbar.show("User is not anonymous".tr);
        throw Exception("User is not anonymous");
      }

      // Apply local language immediately (guest has no firebase settings)
      Get.updateLocale(_localeFromToggle());

      AppLoader.hide();
      AppSnackbar.show("Logged in as guest".tr);
      Get.find<caregoriesController>().addDefaultCategories();

      // Navigate
      Get.offAllNamed(routes.navbar_screen);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Unable to continue as guest. Please try again.".tr);
    }
  }

  // -------------------- Email/Password Login --------------------

  Future<User?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    AppLoader.show(message: "Logging in...".tr);

    try {
      final e = email.trim();
      final p = password.trim();

      if (e.isEmpty || p.isEmpty) {
        AppSnackbar.show("Email and password are required.".tr);
        return null;
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: e,
        password: p,
      );

      AppLoader.hide();

      final user = result.user;
      if (user == null) {
        AppSnackbar.show("Login failed. Please try again.".tr);
        return null;
      }

      AppSnackbar.show("Logged in successfully".tr);

      // ✅ Apply saved language or save current toggle, then navigate
      await applyOrSaveLanguageAndContinue(user);

      return user;
    } on FirebaseAuthException catch (e) {
      print("I am here ${e.code}");
      AppLoader.hide();
      if (e.code == 'user-not-found') {
        AppSnackbar.show("No user found with this email.".tr);
        return null;
      }

      if (e.code == 'invalid-email') {
        AppSnackbar.show("Invalid email address.".tr);
        return null;
      }

      if (e.code == 'invalid-credential') {
        AppSnackbar.show("This email is not linked to any account.".tr);
        return null;
      }

      if (e.code == 'user-disabled') {
        AppSnackbar.show("This account has been disabled.".tr);
        return null;
      }

      if (e.code == 'too-many-requests') {
        AppSnackbar.show("Too many attempts. Try again later.".tr);
        return null;
      }

      if (e.code == 'network-request-failed') {
        AppSnackbar.show("No internet connection.".tr);
        return null;
      }

      if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        AppSnackbar.show("Incorrect password.".tr);
        return null;
      }

      AppSnackbar.show(e.message ?? "Login failed.".tr);
      return null;
    } catch (_) {
      AppSnackbar.show("Something went wrong. Please try again.".tr);
      return null;
    } finally {
      AppLoader.hide();
    }
  }

  // -------------------- Google Sign-in --------------------

  Future<UserCredential?> signInWithGoogle() async {
    isLoading.value = true;

    try {
      // 1) Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // 2) Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3) Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        AppSnackbar.show("Google sign-in failed.".tr);
        return null;
      }

      // ✅ Detect new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser == true;
      if (isNewUser) {
        Get.find<caregoriesController>().addDefaultCategories();
      }

      // 4) Save / update user in Firestore
      await _db.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": user.displayName ?? "",
        "email": user.email?.toLowerCase(),
        "photoUrl": user.photoURL,
        "provider": "google",
        "updatedAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppSnackbar.show("Signed in with Google.".tr);

      // ✅ Apply saved language or save current toggle, then navigate
      await applyOrSaveLanguageAndContinue(user);

      return userCredential;
    } on FirebaseAuthException catch (_) {
      AppSnackbar.show("Google Sign-In Failed".tr);
      return null;
    } catch (_) {
      AppSnackbar.show("Something went wrong. Try again.".tr);
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
