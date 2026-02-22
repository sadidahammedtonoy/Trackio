import 'package:get/get.dart';
import '../Presentation/Authentication/ForgetPassword/View/forgetpassword.dart';
import '../Presentation/Authentication/Login/View/login.dart';
import '../Presentation/Authentication/Signup/View/Signup.dart';
import '../Presentation/Documentation/privacy.dart';
import '../Presentation/Documentation/terms.dart';
import '../Presentation/Features/AddTransactions/View/AddTransactions.dart';
import '../Presentation/Features/Change Password/View/changePassword.dart';
import '../Presentation/Features/caregories/View/categories.dart';
import '../Presentation/Features/helpSupport/View/helpSupport.dart';
import '../Presentation/Features/permanentAccount/View/permanentAccount.dart';
import '../Presentation/Features/saving/View/saving.dart';
import '../Presentation/Splash/View/splash.dart';
import '../Presentation/navbar/View/navbar.dart';
import 'Binding.dart';

class routes {
  static const String navbar_screen = '/navbar';
  static const String addTranscations_screen = '/addTranscations';
  static const String splash_screen = '/splash';
  static const String login_screen = '/login';
  static const String changePassword_screen = '/changePassword';
  static const String PrivacyPolicyPage_screen = '/PrivacyPolicyPage';
  static const String TermsConditionsPage_screen = '/TermsConditionsPage';
  static const String HelpSupportPage_screen = '/HelpSupportPage';
  static const String categories_screen = '/categories';
  static const String saving_screen = '/saving';
  static const String signup_screen = '/signup';
  static const String ForgotPasswordScreen_screen = '/ForgotPasswordScreen';
  static const String MakePermanentDialog_screen = '/MakePermanentDialog';


  static final pages = [
    GetPage( name: navbar_screen, binding: InitialBinding(), page: () => navbar()),
    GetPage( name: addTranscations_screen, binding: InitialBinding(), page: () => addTranscations()),
    GetPage( name: splash_screen, binding: InitialBinding(), page: () => Splash()),
    GetPage( name: login_screen, binding: InitialBinding(), page: () => login()),
    GetPage( name: changePassword_screen, binding: InitialBinding(), page: () => changePassword()),
    GetPage( name: PrivacyPolicyPage_screen, binding: InitialBinding(), page: () => PrivacyPolicyPage()),
    GetPage( name: TermsConditionsPage_screen, binding: InitialBinding(), page: () => TermsConditionsPage()),
    GetPage( name: HelpSupportPage_screen, binding: InitialBinding(), page: () => HelpSupportPage()),
    GetPage( name: categories_screen, binding: InitialBinding(), page: () => categories()),
    GetPage( name: saving_screen, binding: InitialBinding(), page: () => saving()),
    GetPage( name: signup_screen, binding: InitialBinding(), page: () => signup()),
    GetPage( name: ForgotPasswordScreen_screen, binding: InitialBinding(), page: () => ForgotPasswordScreen()),
    GetPage( name: MakePermanentDialog_screen, binding: InitialBinding(), page: () => MakePermanentDialog()),



  ];
}


