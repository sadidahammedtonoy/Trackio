import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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


}
