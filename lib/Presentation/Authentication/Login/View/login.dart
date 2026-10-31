import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/App/assets_path.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Presentation/Share/Background.dart';

import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class login extends StatelessWidget {
  login({super.key});
  final controller = Get.find<loginController>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => controller.toggleLanguage(),
            child: Container(
              height: 40,
              width: 90,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Obx(
                () => Center(child: Text(controller.language.value)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Image.asset("assets/logo.jpeg", width: tablet ? 180 : 150),
              Text(
                "Keep a clear record of where your money goes.".tr,
                style: TextStyle(
                  fontSize: tablet ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tablet ? 45 : 35),
        Text(
          "Email Address".tr,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),
        ),
        SizedBox(height: tablet ? 8 : 4),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address'.tr;
            } else if (GetUtils.isEmail(value) == false) {
              return 'Please enter a valid email address'.tr;
            }
            return null;
          },
          controller: emailController,
          style: TextStyle(fontSize: tablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: "Enter your email address".tr,
            contentPadding: EdgeInsets.symmetric(
              vertical: tablet ? 18 : 16, 
              horizontal: tablet ? 16 : 12
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: tablet ? 16 : 10),
        Text(
          "Password".tr,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),
        ),
        SizedBox(height: tablet ? 8 : 4),
        Obx(
          () => TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password'.tr;
              }
              return null;
            },
            controller: passwordController,
            obscureText: controller.password.value,
            style: TextStyle(fontSize: tablet ? 16 : 14),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: tablet ? 18 : 16, 
                horizontal: tablet ? 16 : 12
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  controller.password.value = !controller.password.value;
                },
                child: Icon(
                  controller.password.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.black,
                  size: tablet ? 24 : 20,
                ),
              ),
              hintText: "Enter your password".tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.toNamed(routes.ForgotPasswordScreen_screen),
            child: Text(
              "Forget Password".tr,
              style: TextStyle(color: Colors.red, fontSize: tablet ? 15 : 14),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: tablet ? 54 : 48,
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await controller.loginWithEmailPassword(
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "Log In".tr,
              style: TextStyle(color: Colors.white, fontSize: tablet ? 16 : 14),
            ),
          ),
        ),
        SizedBox(height: tablet ? 16 : 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don’t have an account? ".tr,
              style: TextStyle(color: Colors.grey, fontSize: tablet ? 15 : 14),
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(routes.signup_screen);
              },
              child: Text(
                "Create One".tr,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: tablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: tablet ? 16 : 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80.0),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Text(
                "  OR  ".tr,
                style: TextStyle(color: Colors.black, fontSize: tablet ? 15 : 14),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        SizedBox(height: tablet ? 16 : 10),
        GestureDetector(
          onTap: () => controller.loginAsGuest(),
          child: Card(
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(tablet ? 16.0 : 13.0),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    "Continue as Guest".tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: tablet ? 15 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: tablet ? 12 : 8),
        GestureDetector(
          onTap: () => controller.signInWithGoogle(),
          child: Card(
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(tablet ? 14.0 : 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(assets_path.google, width: tablet ? 34 : 30),
                  const SizedBox(width: 10),
                  Text(
                    "Continue with Google".tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: tablet ? 15 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Apple Sign-In Button (Visible only on iOS)
        if (Get.theme.platform == TargetPlatform.iOS) ...[
          SizedBox(height: tablet ? 12 : 8),
          GestureDetector(
            onTap: () => controller.signInWithApple(),
            child: Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(tablet ? 14.0 : 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedApple, 
                      color: Colors.black, 
                      size: tablet ? 28.0 : 24.0
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Continue with Apple".tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: tablet ? 15 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        SizedBox(height: tablet ? 40 : 20),
      ],
    );

    if (tablet) {
      content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: content,
        ),
      );
    }

    return background(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
