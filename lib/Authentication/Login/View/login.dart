import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/Controller.dart';
class login extends StatelessWidget {
  login({super.key});
  final controller = Get.find<loginController>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            ElevatedButton(onPressed: () => controller.loginAsGuest(), child: Text("Continue as Guest", style: TextStyle(color: Colors.white),)),
          ],
        ),
      ),
    );
  }
}
