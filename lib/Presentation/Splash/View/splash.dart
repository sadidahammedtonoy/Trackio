import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/AppColors.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class Splash extends StatelessWidget {
  Splash({super.key});
  final controller = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tablet ? 0 : 50.0),
              child: Image.asset(
                "assets/logo.jpeg",
                width: tablet ? 240 : null, // Prevent stretching on tablets by giving a fixed width
              ),
            ),
          ),
          Positioned(
            bottom: tablet ? 80 : 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
