import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/snakbar.dart';

class ForgotPasswordController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final isLoading = false.obs;

  Future<void> resetPasswordWithProviderCheck(String email) async {
    final mail = email.trim().toLowerCase();

    if (mail.isEmpty) {
      AppSnackbar.show("Please enter your email".tr);
      return;
    }

    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(mail);
    if (!ok) {
      AppSnackbar.show("Please enter a valid email".tr);
      return;
    }

    isLoading.value = true;
    try {
      // ✅ 1) Check Firestore user by email
      final snap = await _db
          .collection("users")
          .where("email", isEqualTo: mail)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        AppSnackbar.show("No account exists with this email.".tr);
        return;
      }

      final data = snap.docs.first.data();
      final provider = (data["provider"] ?? "").toString();

      // ✅ 2) If Google account → no reset
      if (provider == "google") {
        AppSnackbar.show("This email is registered with Google. Please sign in with Google.".tr);
        return;
      }

      // ✅ 3) If Email/Password account → send reset
      if (provider == "password") {
        await _auth.sendPasswordResetEmail(email: mail);
        Get.offAndToNamed(routes.login_screen);
        AppSnackbar.show("Reset link sent. Check inbox/spam.".tr);
        return;
      }

      // ✅ 4) Unknown provider
      Get.snackbar("Not supported", "This account uses: $provider");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Failed", e.message ?? "Could not send reset email.".tr);
    } catch (e) {
      AppSnackbar.show("Something went wrong. Please try again.".tr);
    } finally {
      isLoading.value = false;
    }
  }
}
