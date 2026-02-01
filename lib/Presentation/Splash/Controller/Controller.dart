import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';

class SplashController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoggedIn = false.obs;
  final RxBool isGuest = false.obs;
  final RxBool isNewUser = false.obs;

  @override
  void onInit() {
    super.onInit();

    final User? user = _auth.currentUser;

    if (user == null) {
      // 🆕 New user
      isNewUser.value = true;
      isLoggedIn.value = false;
      isGuest.value = false;
      print("User status: NEW USER");
    } else if (user.isAnonymous) {
      // 👤 Guest user
      isGuest.value = true;
      isLoggedIn.value = false;
      isNewUser.value = false;
      print("User status: GUEST USER");
    } else {
      // ✅ Logged-in user
      isLoggedIn.value = true;
      isGuest.value = false;
      isNewUser.value = false;
      print("User status: LOGGED IN USER");
    }

    // ⏱ Delay 1.5 seconds before next action
    Future.delayed(const Duration(milliseconds: 1700), _handleNextAction);
  }

  void _handleNextAction() {
    if (isLoggedIn.value) {
      // 👉 Go to Home
      Get.offAllNamed(routes.navbar_screen);
    } else if (isGuest.value) {
      // 👉 Go to Guest Home
      Get.offAllNamed(routes.navbar_screen);
    } else {
      // 👉 Go to Login / Onboarding
      Get.offAllNamed(routes.login_screen);
    }
  }
}
