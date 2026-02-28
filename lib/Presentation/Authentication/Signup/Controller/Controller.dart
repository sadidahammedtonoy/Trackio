import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';
import '../../../Features/caregories/Controller/Controller.dart';
import '../Model/signupModel.dart';

class signupController extends GetxController {
  var password = true.obs;
  var confirmPassword = true.obs;

  void togglePassword() => password.value = !password.value;
  void toggleConfirmPassword() =>
      confirmPassword.value = !confirmPassword.value;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  Future<UserCredential?> createAccountWithEmail(signUpModel model) async {
    isLoading.value = true;

    try {
      AppLoader.show(message: "Creating account...".tr);
      final name = model.name.trim();
      final email = model.email.trim().toLowerCase();
      final pass = model.password;

      if (name.isEmpty) throw Exception("Name is required");
      if (email.isEmpty) throw Exception("Email is required");
      if (pass.isEmpty) throw Exception("Password is required");

      // ✅ Create auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final user = credential.user;
      if (user == null) {
        AppSnackbar.show("Account creation failed. Please try again.".tr);
        throw Exception("Account creation failed. Please try again.");
      }

      // ✅ Update auth profile (optional)
      await user.updateDisplayName(name);

      // ✅ Save extra info in Firestore
      await _db.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "provider": "password",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      AppLoader.hide();

      // ✅ Optional: send email verification
      // await user.sendEmailVerification();
      AppSnackbar.show("Account created successfully.".tr);
      Get.offAllNamed(routes.navbar_screen);
      Get.find<caregoriesController>().addDefaultCategories();

      return credential;
    } on FirebaseAuthException catch (e) {
      AppLoader.hide();
      final msg = _firebaseAuthErrorMessage(e);
      AppSnackbar.show(msg.tr);
      return null;
    } on FirebaseException {
      AppLoader.hide();
      // Firestore related errors
      AppSnackbar.show("Could not save user info. Please try again.".tr);
      return null;
    } catch (e) {
      AppLoader.hide();
      Get.snackbar(
        "Error",
        e.toString().replaceFirst("Exception: ", ""),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String _firebaseAuthErrorMessage(FirebaseAuthException e) {
    // Common Firebase Auth error codes
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered. Try logging in.".tr;
      case 'invalid-email':
        return "Please enter a valid email address.".tr;
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.".tr;
      case 'operation-not-allowed':
        return "Email/password accounts are not enabled in Firebase Console."
            .tr;
      case 'network-request-failed':
        return "No internet connection. Please check your network.".tr;
      case 'too-many-requests':
        return "Too many attempts. Please wait and try again later.".tr;
      case 'user-disabled':
        return "This account has been disabled. Contact support.".tr;
      default:
        // Fallback to message if available
        return e.message ?? "Something went wrong. Please try again.".tr;
    }
  }
}
