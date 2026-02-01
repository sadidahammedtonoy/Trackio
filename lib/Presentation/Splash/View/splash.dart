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
      body: Center(
        child: Lottie.asset("assets/json/Wallet Essentials_ Money & Savings.json", repeat: false),
      ),
    );
  }
}
