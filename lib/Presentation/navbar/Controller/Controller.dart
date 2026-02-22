import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:get/get.dart';

class navbar_controller extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
  final NotchBottomBarController notchController = NotchBottomBarController(index: 0);


}