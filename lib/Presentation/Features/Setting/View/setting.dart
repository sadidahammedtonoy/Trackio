import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';

class setting_page extends StatelessWidget {
  const setting_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: () async {
            final FirebaseAuth _auth = FirebaseAuth.instance;

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

              Get.offAllNamed(routes.login_screen);

              AppSnackbar.show("Logged out successfully");

            } catch (e, s) {
              AppLoader.hide();

              print("Logout error: $e");
              print(s);

              AppSnackbar.show(
                "Unable to logout. Please try again.",
              );
            }
          }, child: Text("Log Out", style: TextStyle(color: Colors.white),)),
        ],
      ),

    );
  }
}
