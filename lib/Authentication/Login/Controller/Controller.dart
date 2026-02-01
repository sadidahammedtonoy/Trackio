import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../Core/loading.dart';
import '../../../Core/snakbar.dart';

class loginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      print("Guest login success: ${user.uid}");

      // Small delay to avoid navigation race condition
      await Future.delayed(const Duration(milliseconds: 100));

      AppLoader.hide();

      // Navigate safely
      if (Get.routeTree.matchRoute('/guest-home').route != null) {
        Get.offAllNamed('/guest-home');
      } else {
        Get.offAllNamed('/home');
      }

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

  Future<void> logout() async {
    try {
      AppLoader.show(message: "Logging out...");

      final user = _auth.currentUser;

      // If guest, delete anonymous account
      if (user != null && user.isAnonymous) {
        await user.delete();
      } else {
        await _auth.signOut();
      }

      await Future.delayed(const Duration(milliseconds: 100));

      AppLoader.hide();

      Get.offAllNamed('/login');

      AppSnackbar.show("Logged out successfully");

    } catch (e, s) {
      AppLoader.hide();

      print("Logout error: $e");
      print(s);

      AppSnackbar.show(
        "Unable to logout. Please try again.",
      );
    }
  }
}
