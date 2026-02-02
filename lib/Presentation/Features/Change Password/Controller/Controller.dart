import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/loading.dart';

import '../../../../Core/snakbar.dart';

class changePasswordController extends GetxController {

  var oldPassword = true.obs;
  var newPassword = true.obs;
  var confirmPassword = true.obs;



  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Optional: basic validation (avoid Firebase call)
    if (currentPassword.trim().isEmpty || newPassword.trim().isEmpty) {
      AppSnackbar.show("Please fill in all fields.");
      return;
    }

    if (newPassword.trim().length < 6) {
      AppSnackbar.show("New password must be at least 6 characters.");
      return;
    }

    AppLoader.show(message: "Updating password...");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.show("No user is logged in.");
        return;
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        AppSnackbar.show("Password change not available for this account.");
        return;
      }

      // 🔐 Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 Update password
      await user.updatePassword(newPassword.trim());

      // ✅ Success: close loader first, then go back, then show message
      AppLoader.hide();
      Get.back(); // go back only on success
      AppSnackbar.show("Password changed successfully");

    } on FirebaseAuthException catch (e) {
      AppLoader.hide();

      // Wrong current password (reauth)
      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        AppSnackbar.show("Current password doesn't match. Please try again.");
        return;
      }

      if (e.code == 'weak-password') {
        AppSnackbar.show("New password is too weak (min 6 characters).");
        return;
      }

      if (e.code == 'requires-recent-login') {
        AppSnackbar.show("Session expired. Please log in again and retry.");
        return;
      }

      AppSnackbar.show(e.message ?? "Password update failed. Please try again.");
    } catch (_) {
      AppLoader.hide();
      AppSnackbar.show("Something went wrong. Please try again.");
    }
  }




}