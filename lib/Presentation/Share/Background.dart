import 'package:flutter/material.dart';
import '../../App/assets_path.dart';

class background extends StatelessWidget {
  Scaffold child;
  background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(),
        Image.asset(
          // assets_path.background,
          "assets/Cream and Beige Illustrative Background Portrait Document A4.png",
          fit: BoxFit.cover,
          height: double.infinity,
        ),
        child
      ],
    );
  }
}
