import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';

class Splash extends StatelessWidget {
  Splash({super.key});
  final controller = Get.find<SplashController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // child: Lottie.asset("assets/json/Wallet animation.json",),
        // child: Lottie.asset("assets/json/Wallet Essentials_ Money & Savings.json", repeat: false),
        child: Center(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Image.asset("assets/logo.jpeg"),
        ),),

      ),
    );
  }
}
