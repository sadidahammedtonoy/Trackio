import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../Core/snakbar.dart';

class changePasswordController extends GetxController {

  var oldPassword = true.obs;
  var newPassword = true.obs;
  var confirmPassword = true.obs;



  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No user is logged in.");
    }

    // Only email/password users can change password
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception("Password change not available for this account.");
    }

    try {
      // 🔐 Re-authenticate user (required by Firebase)
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 Update password
      await user.updatePassword(newPassword);
      AppSnackbar.show("Password changed successfully");
      Get.back();

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        AppSnackbar.show("Current password is incorrect.");
        throw Exception("Current password is incorrect.");
      } else if (e.code == 'weak-password') {
        AppSnackbar.show("New password is too weak.");
        throw Exception("New password is too weak.");
      } else if (e.code == 'requires-recent-login') {
        AppSnackbar.show("Please log in again and retry.");
        throw Exception("Please log in again and retry.");
      } else {
        AppSnackbar.show(e.message ?? "Password update failed.");
        throw Exception(e.message ?? "Password update failed.");
      }
    }
  }



}