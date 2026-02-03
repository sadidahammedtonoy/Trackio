import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sadid/App/routes.dart';
import '../../../Core/loading.dart';
import '../../../Core/snakbar.dart';

class loginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var passswprd = true.obs;


  Future<void> loginAsGuest() async {
    try {
      AppLoader.show(message: "Signing in as guest...");

      final UserCredential credential =
      await _auth.signInAnonymously();

      final User? user = credential.user;

      if (user == null) {
        throw Exception("Anonymous user is null");
      }

      if (!user.isAnonymous) {
        throw Exception("User is not anonymous");
      }
      AppSnackbar.show("Guest login success");

      print("Guest login success: ${user.uid}");

      // Small delay to avoid navigation race condition
      await Future.delayed(const Duration(milliseconds: 100));

      AppLoader.hide();

      // Navigate safely
      Get.offAllNamed(routes.navbar_screen);

      AppSnackbar.show("Logged in as guest");
    } catch (e, s) {
      AppLoader.hide();

      print("Guest login error: $e");
      print(s);

      AppSnackbar.show(
        "Unable to continue as guest. Please try again.",
      );
    }
  }

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

      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: e,
        password: p,
      );

      final user = result.user;
      if (user == null) {
        AppLoader.hide();
        AppSnackbar.show("Login failed. Please try again.");
        return null;
      }

      AppSnackbar.show("Logged in successfully");
      Get.offAllNamed(routes.navbar_screen);
      return user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AppLoader.hide();
        AppSnackbar.show("No user found with this email.");
        return null;
      }

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS') {
        AppLoader.hide();
        AppSnackbar.show("Incorrect password.");
        return null;
      }

      if (e.code == 'invalid-email') {
        AppLoader.hide();
        AppSnackbar.show("Invalid email address.");
        return null;
      }

      if (e.code == 'user-disabled') {
        AppLoader.hide();
        AppSnackbar.show("This account has been disabled.");
        return null;
      }

      if (e.code == 'too-many-requests') {
        AppLoader.hide();
        AppSnackbar.show("Too many attempts. Try again later.");
        return null;
      }

      if (e.code == 'network-request-failed') {
        AppLoader.hide();
        AppSnackbar.show("No internet connection.");
        return null;
      }

      AppLoader.hide();
      AppSnackbar.show(e.message ?? "Login failed.");
      return null;

    } catch (_) {
      AppLoader.hide();
      AppSnackbar.show("Something went wrong. Please try again.");
      return null;

    } finally {
      AppLoader.hide();
      AppLoader.hide();
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final isLoading = false.obs;

  Future<UserCredential?> signInWithGoogle() async {
    isLoading.value = true;

    try {
      // 1️⃣ Trigger Google Sign-In
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        // Get.snackbar("Cancelled", "Google sign-in cancelled");
        return null;
      }

      // 2️⃣ Get auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3️⃣ Sign in to Firebase
      final userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        AppSnackbar.show("Google sign-in failed");
        throw Exception("Google sign-in failed");
      }

      // 4️⃣ Save / update user in Firestore
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
      Get.offAllNamed(routes.navbar_screen);


      return userCredential;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Google Sign-In Failed", _authError(e));
      return null;
    } catch (e) {
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
