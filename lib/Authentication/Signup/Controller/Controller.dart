import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';

import '../Model/signupModel.dart';

class signupController extends GetxController {
  var password = true.obs;
  var confirmPassword = true.obs;

  void togglePassword() => password.value = !password.value;
  void toggleConfirmPassword() => confirmPassword.value = !confirmPassword.value;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  Future<UserCredential?> createAccountWithEmail(signUpModel model) async {
    isLoading.value = true;

    try {
      AppLoader.show(message: "Creating account...");
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
      if (user == null){
        AppSnackbar.show("Account creation failed. Please try again.");
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
      AppSnackbar.show("Account created successfully 🎉");
      Get.offAllNamed(routes.navbar_screen);

      return credential;
    } on FirebaseAuthException catch (e) {
      AppLoader.hide();
      final msg = _firebaseAuthErrorMessage(e);
      print(msg);
      AppSnackbar.show(msg);
      return null;
    } on FirebaseException catch (e) {
      AppLoader.hide();
      // Firestore related errors
      Get.snackbar(
        "Database error",
        e.message ?? "Could not save user info. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
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
        return "This email is already registered. Try logging in.";
      case 'invalid-email':
        return "Please enter a valid email address.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters.";
      case 'operation-not-allowed':
        return "Email/password accounts are not enabled in Firebase Console.";
      case 'network-request-failed':
        return "No internet connection. Please check your network.";
      case 'too-many-requests':
        return "Too many attempts. Please wait and try again later.";
      case 'user-disabled':
        return "This account has been disabled. Contact support.";
      default:
      // Fallback to message if available
        return e.message ?? "Something went wrong. Please try again.";
    }
  }

}