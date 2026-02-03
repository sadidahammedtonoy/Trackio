import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sadid/App/routes.dart';

import '../../../Core/loading.dart';
import '../../../Core/snakbar.dart';

class loginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var passswprd = true.obs;

  /// UI toggle (English / বাংলা)
  var language = "English".obs;

  @override
  void onInit() {
    super.onInit();

    final code = Get.locale?.languageCode ?? 'en';

    language = (code == 'bn')
        ? "বাংলা".obs
        : "English".obs;
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
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('app');
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
      AppLoader.show(message: "Signing in as guest...");

      final UserCredential credential = await _auth.signInAnonymously();
      final User? user = credential.user;

      if (user == null) throw Exception("Anonymous user is null");
      if (!user.isAnonymous) throw Exception("User is not anonymous");

      // Apply local language immediately (guest has no firebase settings)
      Get.updateLocale(_localeFromToggle());

      AppLoader.hide();
      AppSnackbar.show("Logged in as guest");

      // Navigate
      Get.offAllNamed(routes.navbar_screen);
    } catch (e, s) {
      AppLoader.hide();
      print("Guest login error: $e");
      print(s);
      AppSnackbar.show("Unable to continue as guest. Please try again.");
    }
  }

  // -------------------- Email/Password Login --------------------

  Future<User?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    AppLoader.show(message: "Logging in...");

    try {
      final e = email.trim();
      final p = password.trim();

      if (e.isEmpty || p.isEmpty) {
        AppSnackbar.show("Email and password are required.");
        return null;
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: e,
        password: p,
      );

      final user = result.user;
      if (user == null) {
        AppSnackbar.show("Login failed. Please try again.");
        return null;
      }

      AppSnackbar.show("Logged in successfully");

      // ✅ Apply saved language or save current toggle, then navigate
      await applyOrSaveLanguageAndContinue(user);

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AppSnackbar.show("No user found with this email.");
        return null;
      }

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        AppSnackbar.show("Incorrect password.");
        return null;
      }

      if (e.code == 'invalid-email') {
        AppSnackbar.show("Invalid email address.");
        return null;
      }

      if (e.code == 'user-disabled') {
        AppSnackbar.show("This account has been disabled.");
        return null;
      }

      if (e.code == 'too-many-requests') {
        AppSnackbar.show("Too many attempts. Try again later.");
        return null;
      }

      if (e.code == 'network-request-failed') {
        AppSnackbar.show("No internet connection.");
        return null;
      }

      AppSnackbar.show(e.message ?? "Login failed.");
      return null;
    } catch (_) {
      AppSnackbar.show("Something went wrong. Please try again.");
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
        AppSnackbar.show("Google sign-in failed.");
        return null;
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

      AppSnackbar.show("Signed in with Google 🎉");

      // ✅ Apply saved language or save current toggle, then navigate
      await applyOrSaveLanguageAndContinue(user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Google Sign-In Failed", _authError(e));
      return null;
    } catch (_) {
      Get.snackbar("Error", "Something went wrong. Try again.");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return "This email is already registered with another sign-in method.";
      case 'network-request-failed':
        return "No internet connection.";
      case 'user-disabled':
        return "This account has been disabled.";
      default:
        return e.message ?? "Google sign-in failed.";
    }
  }
}
