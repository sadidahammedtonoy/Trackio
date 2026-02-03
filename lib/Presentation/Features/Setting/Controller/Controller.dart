import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../App/routes.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';

class settingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> logout() async {
    try {
      AppLoader.show(message: "Logging out...".tr);

      final user = _auth.currentUser;

      // If guest, delete anonymous account
      if (user != null && user.isAnonymous) {
        await user.delete();
      } else {
        await _auth.signOut();
      }

      await Future.delayed(const Duration(milliseconds: 100));

      AppLoader.hide();

      Get.offAllNamed(routes.login_screen);

      AppSnackbar.show("Logged out successfully".tr);
    } catch (e, s) {
      AppLoader.hide();

      AppSnackbar.show(
        "Unable to logout. Please try again.".tr,
      );
    }
  }

  Future<void> showLogoutDialog({
    required VoidCallback onConfirm,
  }) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Logout".tr),
        content: Text("Are you sure you want to logout?".tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          Row(
            spacing: 15,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(), // close dialog
                  child: Text("Cancel".tr, style: TextStyle(color: Colors.black),),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    onConfirm(); // run logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Log Out".tr),
                ),
              ),
            ],
          )

        ],
      ),
      barrierDismissible: false,
    );
  }

  String getUserName() {
    final User? user = FirebaseAuth.instance.currentUser;

    // Not logged in at all
    if (user == null) {
      return "Guest";
    }

    // Anonymous (guest) user
    if (user.isAnonymous) {
      return "Guest User";
    }

    // Logged-in user with display name
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }

    // Fallbacks
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@').first;
    }

    return "User";
  }

  String? getUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;

    // Not logged in or anonymous user → no email
    if (user == null || user.isAnonymous) {
      return "anonymous@trackio.com";
    }

    // Email-based login
    if (user.email != null && user.email!.trim().isNotEmpty) {
      return user.email!;
    }

    // Some providers store email in providerData
    for (final info in user.providerData) {
      if (info.email != null && info.email!.trim().isNotEmpty) {
        return info.email;
      }
    }

    return null;
  }

  String? getUserProfileImage() {
    final User? user = FirebaseAuth.instance.currentUser;

    // No user at all
    if (user == null) {
      return null;
    }

    // Anonymous (guest) users usually have no photo
    if (user.isAnonymous) {
      return null;
    }

    // Primary photoURL (most common)
    if (user.photoURL != null && user.photoURL!.trim().isNotEmpty) {
      return user.photoURL;
    }

    // Fallback: check provider data (Google, Apple, etc.)
    for (final provider in user.providerData) {
      if (provider.photoURL != null && provider.photoURL!.trim().isNotEmpty) {
        return provider.photoURL;
      }
    }

    return null;
  }

  bool isEmailPasswordUser() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    // Anonymous users are not email/password users
    if (user.isAnonymous) return false;

    // Check provider list
    for (final provider in user.providerData) {
      if (provider.providerId == EmailAuthProvider.PROVIDER_ID) {
        return true;
      }
    }

    return false;
  }

  Future<void> confirmDeleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) {
      AppSnackbar.show("No user found.".tr);
      return;
    }

    final isEmailUser = user.providerData.any(
          (p) => p.providerId == EmailAuthProvider.PROVIDER_ID,
    );

    final passCtrl = TextEditingController();

    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Account".tr),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⚠️ Warning".tr,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "This action is permanent.\n\n"
                    "• Your account will be deleted.\n"
                    "• Your saved data may be removed.\n"
                    "• You cannot recover this account after deletion.\n",
              ),
              const SizedBox(height: 12),

              // Only ask password if email/password user
              if (isEmailUser) ...[
                Text(
                  "To confirm, enter your current password:".tr,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Current password".tr,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Note: Password is required to delete an email/password account.".tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ] else if (user.isAnonymous) ...[
                Text(
                  "You are using a Guest account. Deleting will remove this guest profile.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ] else ...[
                Text(
                  "You are signed in with Google/Apple/other provider.\n"
                      "If deletion fails, you may need to re-login and try again.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel".tr, style: TextStyle(color: Colors.black),),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Get.back(); // close dialog first

                    final password = passCtrl.text.trim();
                    await deleteAccount(currentPassword: password);
                  },
                  child: Text("Delete".tr),
                ),
              ),
            ],
          )

        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> deleteAccount({String currentPassword = ""}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppSnackbar.show("No user found.".tr);
        return;
      }

      AppLoader.show(message: "Deleting account...".tr);

      // 👤 Guest account: delete directly
      if (user.isAnonymous) {
        await user.delete();
        AppLoader.hide();
        AppSnackbar.show("Guest account deleted.".tr);
        Get.offAllNamed(routes.login_screen);
        return;
      }

      // 🔐 Email/Password account: re-auth required
      final isEmailUser = user.providerData.any(
            (p) => p.providerId == EmailAuthProvider.PROVIDER_ID,
      );

      if (isEmailUser) {
        final email = user.email ?? "";
        if (email.isEmpty) {
          throw FirebaseAuthException(
            code: "no-email",
            message: "Email not found for this account.",
          );
        }

        if (currentPassword.isEmpty) {
          AppLoader.hide();
          AppSnackbar.show("Please enter your current password.".tr);
          return;
        }

        final cred = EmailAuthProvider.credential(
          email: email,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(cred);
        await user.delete();

        AppLoader.hide();
        AppSnackbar.show("Account deleted successfully.".tr);
        Get.offAllNamed(routes.login_screen);
        return;
      }

      // 🌐 Other providers (Google/Apple/etc.)
      // Try delete; if requires recent login, show message.
      await user.delete();

      AppLoader.hide();
      AppSnackbar.show("Account deleted successfully.".tr);
      Get.offAllNamed(routes.login_screen);
    } on FirebaseAuthException catch (e) {
      AppLoader.hide();

      // Common Firebase cases
      if (e.code == 'wrong-password') {
        AppSnackbar.show("Current password is incorrect.".tr);
      } else if (e.code == 'requires-recent-login') {
        AppSnackbar.show(
                "For security, please login again and then delete your account.".tr,
        );
      } else {
        AppSnackbar.show(e.message ?? "Account deletion failed.".tr);
      }
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Account deletion failed. Please try again.".tr);
    }
  }

  bool isGuestUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.isAnonymous ?? true;
  }

  final Rx<Locale> currentLocale = const Locale('bn', 'BD').obs;

  DocumentReference<Map<String, dynamic>> _docRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('app');
  }

  void _applyLocale(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  // ✅ Local change first, firebase save later (no await needed from UI)
  void changeLanguageInstant(Locale locale) {
    _applyLocale(locale); // instant UI update

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // guest -> only local

    // fire-and-forget save (silent)
    _saveLocaleToFirebase(user.uid, locale);
  }

  Future<void> _saveLocaleToFirebase(String uid, Locale locale) async {
    try {
      await _docRef(uid).set({
        "languageCode": locale.languageCode,
        "countryCode": locale.countryCode,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // keep silent (no UI block)
    }
  }

  final nameC = TextEditingController();

  Future<void> changeName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      AppSnackbar.show("No user found.");
      return;
    }

    if (!isEmailPasswordUser()) {
      AppSnackbar.show("Name change is available for email/password accounts only.".tr);
      return;
    }

    final newName = nameC.text.trim();
    if (newName.isEmpty) {
      AppSnackbar.show("Please enter your name.");
      return;
    }
    Get.back();

    AppLoader.show(message: "Updating name...");

    try {
      // ✅ Update Firebase Auth
      await user.updateDisplayName(newName);

      // ✅ Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        "name": newName,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLoader.hide();
      Get.offAllNamed(routes.navbar_screen);
      AppSnackbar.show("Name updated successfully.");
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed. Try again.");
    }
  }




}