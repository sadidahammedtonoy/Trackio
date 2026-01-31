import 'package:get/get.dart';

class navbar_controller extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

}