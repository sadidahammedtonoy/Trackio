import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sadid/App/routes.dart';

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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset("assets/json/3D Money Icon.json", height: 100),
                      Text("Trackio", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
                      Text("Keep a clear record of where your money goes.", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),)
                    ],
                  )),
              const SizedBox(height: 18,),
              Text("Email Address", style: TextStyle(fontWeight: FontWeight.w500),),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  } else if(GetUtils.isEmail(value) == false){
                    return 'Please enter a valid email address';
                  }
                  return null;
                }, controller: emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ),
              const SizedBox(height: 10,),
              Text("Password", style: TextStyle(fontWeight: FontWeight.w500),),
              Obx(() => TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  }, controller: passwordController,
                  obscureText: controller.passswprd.value,
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          onTap: (){
                            controller.passswprd.value = !controller.passswprd.value;
                          },
                          child: Icon(controller.passswprd.value ? Icons.visibility_off : Icons.visibility, color: Colors.black)),
                      hintText: "Enter your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  )
              ),),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: (){}, child: Text("Forget Password", style: TextStyle(color: Colors.red),))),
              ElevatedButton(onPressed: () async {
                if(_formKey.currentState!.validate()){
                  await controller.loginWithEmailPassword(
                  email: emailController.text,
                  password: passwordController.text
                  );

                }
              }, child: Text("Log In", style: TextStyle(color: Colors.white),)),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(routes.signup_screen);
                    },
                    child: const Text(
                      "Create One",
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
              Row(
                children: [
                  Expanded(child: Divider()),
                  Text("  OR  ", style: TextStyle(color: Colors.black),),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 10,),
              OutlinedButton(
                onPressed: () => controller.loginAsGuest(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48), // full width
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Continue as Guest",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.google,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [Color(0xFF4285F4), Color(0xFFDB4437), Color(0xFFF4B400), Color(0xFF0F9D58)],
                        ).createShader(bounds);
                      },
                      child: Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
        ],
          ),
        ),
      ),
    );
  }
}
