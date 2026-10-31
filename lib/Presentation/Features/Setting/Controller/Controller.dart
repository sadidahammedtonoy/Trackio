import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../App/routes.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';

class settingController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;
  StreamSubscription? _userSub;

  @override
  void onInit() {
    super.onInit();
    listenToUserData();
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  void listenToUserData() {
    final user = _auth.currentUser;
    if (user == null) return;

    _userSub?.cancel();
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snap) {
      if (snap.exists) {
        userData.value = snap.data() ?? {};
      }
    });
  }

  Future<void> logout() async {
    try {
      AppLoader.show(message: "Logging out...".tr);

      final user = _auth.currentUser;

      if (user != null && user.isAnonymous) {
        await user.delete();
      } else {
        await _auth.signOut();
      }

      await Future.delayed(const Duration(milliseconds: 100));
      AppLoader.hide();
      Get.offAllNamed(routes.login_screen);
      AppSnackbar.show("Logged out successfully".tr);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Unable to logout. Please try again.".tr);
    }
  }

  Future<void> showLogoutDialog({required VoidCallback onConfirm}) async {
    if (GetPlatform.isIOS) {
      await Get.dialog(
        CupertinoAlertDialog(
          title: Text("Logout".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isGuestUser()
                  ? "You’re using a guest account. Logging out will permanently remove access to your data. Make your account permanent to keep your data safe."
                        .tr
                  : "Are you sure you want to logout?".tr,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Get.back();
                onConfirm();
              },
              child: Text("Log Out".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Logout".tr),
          content: Text(
            isGuestUser()
                ? "You’re using a guest account. Logging out will permanently remove access to your data. Make your account permanent to keep your data safe."
                      .tr
                : "Are you sure you want to logout?".tr,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel".tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Log Out".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Stream<String> userNameStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value("Guest");
    }

    if (user.isAnonymous) {
      return Stream.value("Guest User");
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists &&
          doc.data() != null &&
          doc.data()!['name'] != null &&
          doc.data()!['name'].toString().isNotEmpty) {
        return doc.data()!['name'];
      }

      return "User";
    });
  }

  String? getUserEmail() {
    if (userData.isNotEmpty && userData['email'] != null && userData['email'].toString().isNotEmpty) {
      return userData['email'];
    }
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return "guest@trackio.com";
    return user.email ?? "User";
  }


  bool isEmailPasswordUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return false;
    for (final provider in user.providerData) {
      if (provider.providerId == EmailAuthProvider.PROVIDER_ID) return true;
    }
    return false;
  }

  bool isGuestUser() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.isAnonymous ?? true;
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

    Widget buildContent() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "⚠️ Warning".tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${"delete_warning_title".tr}\n\n"
              "${"delete_warning_1".tr}\n"
              "${"delete_warning_2".tr}\n"
              "${"delete_warning_3".tr}",
            ),
            const SizedBox(height: 12),
            if (isEmailUser) ...[
              Text(
                "To confirm, enter your current password:".tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GetPlatform.isIOS
                  ? CupertinoTextField(
                      controller: passCtrl,
                      obscureText: true,
                      placeholder: "Current password".tr,
                    )
                  : TextField(
                      controller: passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Current password".tr,
                      ),
                    ),
              const SizedBox(height: 6),
              Text(
                "Note: Password is required to delete an email/password account."
                    .tr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else if (user.isAnonymous) ...[
              Text(
                "You are using a Guest account. Deleting will remove this guest profile."
                    .tr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ] else ...[
              Text(
                "${"You are signed in with Google/Apple/other provider.".tr}\n"
                        "If deletion fails, you may need to re-login and try again."
                    .tr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }

    if (GetPlatform.isIOS) {
      await Get.dialog(
        CupertinoAlertDialog(
          title: Text("Delete Account".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: buildContent(),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Get.back();
                final password = passCtrl.text.trim();
                await deleteAccount(currentPassword: password);
              },
              child: Text("Delete".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Account".tr),
          content: buildContent(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel".tr,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Get.back();
                final password = passCtrl.text.trim();
                await deleteAccount(currentPassword: password);
              },
              child: Text("Delete".tr),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> deleteAccount({String currentPassword = ""}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppSnackbar.show("No user found.".tr);
        return;
      }

      AppLoader.show(message: "Deleting account...".tr);

      if (user.isAnonymous) {
        await user.delete();
        AppLoader.hide();
        AppSnackbar.show("Guest account deleted.".tr);
        Get.offAllNamed(routes.login_screen);
        return;
      }

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

      await user.delete();
      AppLoader.hide();
      AppSnackbar.show("Account deleted successfully.".tr);
      Get.offAllNamed(routes.login_screen);
    } on FirebaseAuthException catch (e) {
      AppLoader.hide();
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

  void changeLanguageInstant(Locale locale) {
    _applyLocale(locale);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _saveLocaleToFirebase(user.uid, locale);
  }

  Future<void> _saveLocaleToFirebase(String uid, Locale locale) async {
    try {
      await _docRef(uid).set({
        "languageCode": locale.languageCode,
        "countryCode": locale.countryCode,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  final nameC = TextEditingController();

  Future<void> changeName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppSnackbar.show("No user found.".tr);
      return;
    }
    if (user.isAnonymous) {
      AppSnackbar.show("Name change is not available for guest accounts.".tr);
      return;
    }

    final newName = nameC.text.trim();
    if (newName.isEmpty) {
      AppSnackbar.show("Please enter your name.".tr);
      return;
    }
    Get.back();

    AppLoader.show(message: "Updating name...".tr);

    try {
      await user.updateDisplayName(newName);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "name": newName,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLoader.hide();
      AppSnackbar.show("Name updated successfully.".tr);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed. Try again.".tr);
    }
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = "dagym82bv";
    const uploadPreset = "trackio";
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest("POST", uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = jsonDecode(respStr);
      return jsonResp['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (user.isAnonymous) {
      AppSnackbar.show("Profile image upload is for permanent accounts only.".tr);
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      AppLoader.show(message: "Uploading image...".tr);
      final String? downloadUrl = await uploadImageToCloudinary(File(image.path));

      if (downloadUrl == null) {
        AppLoader.hide();
        AppSnackbar.show("Failed to upload image to server.".tr);
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "photoUrl": downloadUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      await user.updatePhotoURL(downloadUrl);
      AppLoader.hide();
      AppSnackbar.show("Profile image updated successfully.".tr);
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed to upload image. Please try again.".tr);
    }
  }

  void showImageSourceDialog() {
    final context = Get.context!;
    if (GetPlatform.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (ctx) => CupertinoActionSheet(
          title: Text("Select Image Source".tr),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                pickAndUploadImage(ImageSource.camera);
              },
              child: Text("Camera".tr),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                pickAndUploadImage(ImageSource.gallery);
              },
              child: Text("Gallery".tr),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            isDestructiveAction: false,
            child: Text("Cancel".tr),
          ),
        ),
      );
    } else {
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4, width: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Select Image Source".tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _imageSourceTile(
                icon: Icons.camera_alt_outlined,
                label: "Camera".tr,
                onTap: () { Get.back(); pickAndUploadImage(ImageSource.camera); },
              ),
              const SizedBox(height: 10),
              _imageSourceTile(
                icon: Icons.photo_library_outlined,
                label: "Gallery".tr,
                onTap: () { Get.back(); pickAndUploadImage(ImageSource.gallery); },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: Get.back,
                  child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54)),
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    }
  }

  Widget _imageSourceTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: Colors.black87),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
