import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/Controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final c = Get.put(ForgotPasswordController());
  TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Reset your password".tr,
          style: TextStyle(fontSize: tablet ? 26 : 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tablet ? 10 : 6),
        Text(
          "Enter your email and we’ll send a password reset link.".tr,
          style: TextStyle(color: Colors.grey, fontSize: tablet ? 16 : 14),
        ),
        SizedBox(height: tablet ? 32 : 24),
        Text("Email Address".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),),
        SizedBox(height: tablet ? 8 : 4),

        TextFormField(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          controller: emailController,
          style: TextStyle(fontSize: tablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: "Enter your email address..".tr,
            contentPadding: EdgeInsets.symmetric(
              vertical: tablet ? 18 : 16, 
              horizontal: tablet ? 16 : 12
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: (v) {
            final mail = (v ?? '').trim();
            if (mail.isEmpty) return "Email is required".tr;
            final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(mail);
            if (!ok) return "Enter a valid email".tr;
            return null;
          },
        ),

        SizedBox(height: tablet ? 24 : 18),

        Obx(() {
          return SizedBox(
            width: double.infinity,
            height: tablet ? 54 : 48,
            child: ElevatedButton(
              onPressed: (){
                c.resetPasswordWithProviderCheck(emailController.text);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: c.isLoading.value
                  ? SizedBox(
                height: tablet ? 22 : 18,
                width: tablet ? 22 : 18,
                child: const CircularProgressIndicator.adaptive(),
              )
                  : Text(
                "Send Reset Link".tr,
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: tablet ? 16 : 14),
              ),
            ),
          );
        }),

        SizedBox(height: tablet ? 24 : 16),

        Center(
          child: GestureDetector(
            onTap: () => Get.back(), // or Get.to(LoginScreen())
            child: Text(
              "Back to Login".tr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: tablet ? 15 : 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
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
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tablet ? 24 : 16),
            child: Form(
              key: _formKey,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
