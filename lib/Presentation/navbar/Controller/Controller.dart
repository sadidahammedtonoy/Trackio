import 'package:get/get.dart';

import '../../../Core/NotificationService.dart';
import '../../../Core/TrackioReminderManager.dart';

class navbar_controller extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    await NotificationService.init();
    TrackioReminderManager.scheduleDailyReminders();
  }

}