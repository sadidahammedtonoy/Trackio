import 'package:get/get.dart';
import '../Presentation/Features/AddTransactions/View/AddTransactions.dart';
import '../Presentation/navbar/View/navbar.dart';
import 'Binding.dart';

class routes {
  static const String navbar_screen = '/navbar';
  static const String addTranscations_screen = '/addTranscations';


  static final pages = [
    GetPage( name: navbar_screen, binding: InitialBinding(), page: () => navbar()),
    GetPage( name: addTranscations_screen, binding: InitialBinding(), page: () => addTranscations()),


  ];
}


