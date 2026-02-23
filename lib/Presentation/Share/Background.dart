import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Features/Background/Controller/Controller.dart';

class background extends StatelessWidget {
  final Widget child;
  const background({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: Get.find<backgroundController>().userBackgroundStream(),
      builder: (context, snapshot) {
        try {
          final data = snapshot.data;

          // Default white background if no data or error
          if (data == null || data['source'] == null || data['isColor'] == null) {
            return Stack(
              children: [
                const SizedBox.expand(child: ColoredBox(color: Colors.white)),
                child,
              ],
            );
          }

          // If it's a color
          if (data['isColor'] == true) {
            final colorCode = data['source'] as String;
            final color = Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
            return Stack(
              children: [
                SizedBox.expand(child: Container(color: color)),
                child,
              ],
            );
          }

          // If it's an image
          final imagePath = data['source'] as String;
          return Stack(
            children: [
              SizedBox.expand(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
              child,
            ],
          );
        } catch (e) {
          // On any error, fallback to white background
          return Stack(
            children: [
              const SizedBox.expand(child: ColoredBox(color: Colors.white)),
              child,
            ],
          );
        }
      },
    );
  }
}