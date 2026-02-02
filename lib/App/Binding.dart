import 'package:get/get.dart';
import '../Authentication/Login/Controller/Controller.dart';
import '../Presentation/Features/AddTransactions/Controller/Controller.dart';
import '../Presentation/Features/Change Password/Controller/Controller.dart';
import '../Presentation/Features/Dashboard/Controller/Controller.dart';
import '../Presentation/Features/Setting/Controller/Controller.dart';
import '../Presentation/Features/Transcations/Controller/Controller.dart';
import '../Presentation/Features/caregories/Controller/Controller.dart';
import '../Presentation/Features/debts/Controller/Controller.dart';
import '../Presentation/Features/saving/Controller/Controller.dart';
import '../Presentation/Splash/Controller/Controller.dart';
import '../Presentation/helpSupport/Controller/Controller.dart';
import '../Presentation/navbar/Controller/Controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<navbar_controller>(() => navbar_controller(), fenix: true);
    Get.lazyPut<transactionsController>(() => transactionsController(), fenix: true);
    Get.lazyPut<settingController>(() => settingController(), fenix: true);
    Get.lazyPut<debtsController>(() => debtsController(), fenix: true);
    Get.lazyPut<dashboardController>(() => dashboardController(), fenix: true);
    Get.lazyPut<addTranscationsController>(() => addTranscationsController(), fenix: true);
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<loginController>(() => loginController(), fenix: true);
    Get.lazyPut<changePasswordController>(() => changePasswordController(), fenix: true);
    Get.lazyPut<HelpSupportController>(() => HelpSupportController(), fenix: true);
    Get.lazyPut<caregoriesController>(() => caregoriesController(), fenix: true);
    Get.lazyPut<savingController>(() => savingController(), fenix: true);


  }
}
