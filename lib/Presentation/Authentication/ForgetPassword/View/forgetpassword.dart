import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/Controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final c = Get.put(ForgotPasswordController());
  TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    "Reset your password".tr,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Enter your email and we’ll send a password reset link.".tr,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Text("Email Address".tr, style: TextStyle(fontWeight: FontWeight.w500),),
      
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Enter your email address..".tr,
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final mail = (v ?? '').trim();
                      if (mail.isEmpty) return "Email is required".tr;
                      final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(mail);
                      if (!ok) return "Enter a valid email".tr;
                      return null;
                    },
                  ),
      
                  const SizedBox(height: 18),
      
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (){
                          c.resetPasswordWithProviderCheck(emailController.text);
                        },
                        child: c.isLoading.value
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator.adaptive(),
                        )
                            : Text(
                          "Send Reset Link".tr,
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    );
                  }),
      
                  const SizedBox(height: 16),
      
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(), // or Get.to(LoginScreen())
                      child: Text(
                        "Back to Login".tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
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
    );
  }
}
