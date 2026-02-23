import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/assets_path.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Presentation/Share/Background.dart';

import '../Controller/Controller.dart';
import 'package:lottie/lottie.dart';

class login extends StatelessWidget {
  login({super.key});
  final controller = Get.find<loginController>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
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
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            )
                          ),
                          child: Obx(() => Center(child: Text(controller.language.value))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            // Lottie.asset("assets/json/3D Money Icon.json", height: 100),
                            Image.asset("assets/logo.jpeg", width: 150,),
                            // Text("Trackio", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
                            Text("Keep a clear record of where your money goes.".tr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),)
                          ],
                        )),
                    const SizedBox(height: 35,),
                    Text("Email Address".tr, style: TextStyle(fontWeight: FontWeight.w500),),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address'.tr;
                        } else if(GetUtils.isEmail(value) == false){
                          return 'Please enter a valid email address'.tr;
                        }
                        return null;
                      }, controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email address".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                    ),
                    const SizedBox(height: 10,),
                    Text("Password".tr, style: TextStyle(fontWeight: FontWeight.w500),),
                    Obx(() => TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password'.tr;
                          }
                          return null;
                        }, controller: passwordController,
                        obscureText: controller.password.value,
                        decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: (){
                                  controller.password.value = !controller.password.value;
                                },
                                child: Icon(controller.password.value ? Icons.visibility_off : Icons.visibility, color: Colors.black)),
                            hintText: "Enter your password".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        )
                    ),),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () => Get.toNamed(routes.ForgotPasswordScreen_screen), child: Text("Forget Password".tr, style: TextStyle(color: Colors.red),))),
                    ElevatedButton(onPressed: () async {
                      if(_formKey.currentState!.validate()){
                        await controller.loginWithEmailPassword(
                        email: emailController.text,
                        password: passwordController.text
                        );
                
                      }
                    }, child: Text("Log In".tr, style: TextStyle(color: Colors.white),)),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account? ".tr,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(routes.signup_screen);
                          },
                          child: Text(
                            "Create One".tr,
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80.0),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Text("  OR  ".tr, style: TextStyle(color: Colors.black),),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 10,),
                    // OutlinedButton(
                    //   onPressed: () => controller.loginAsGuest(),
                    //   style: OutlinedButton.styleFrom(
                    //     minimumSize: const Size(double.infinity, 48), // full width
                    //     side: const BorderSide(color: Colors.black),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     "Continue as Guest",
                    //     style: TextStyle(color: Colors.black),
                    //   ),
                    // ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () => controller.loginAsGuest(),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Continue as Guest".tr,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.signInWithGoogle(),
                      child: Card(
                        elevation: 3,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(assets_path.google, width: 30,),
                              const SizedBox(width: 10),
                              Text(
                                "Continue with Google".tr,
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
