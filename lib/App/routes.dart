import 'package:get/get.dart';
import '../Authentication/Login/View/login.dart';
import '../Presentation/Features/AddTransactions/View/AddTransactions.dart';
import '../Presentation/Splash/View/splash.dart';
import '../Presentation/navbar/View/navbar.dart';
import 'Binding.dart';

class routes {
  static const String navbar_screen = '/navbar';
  static const String addTranscations_screen = '/addTranscations';
  static const String splash_screen = '/splash';
  static const String login_screen = '/login';


  static final pages = [
    GetPage( name: navbar_screen, binding: InitialBinding(), page: () => navbar()),
    GetPage( name: addTranscations_screen, binding: InitialBinding(), page: () => addTranscations()),
    GetPage( name: splash_screen, binding: InitialBinding(), page: () => Splash()),
    GetPage( name: login_screen, binding: InitialBinding(), page: () => login()),



  ];
}


