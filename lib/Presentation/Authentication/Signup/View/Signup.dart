import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/Controller.dart';
import '../Model/signupModel.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class signup extends StatelessWidget {
  signup({super.key});

  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<signupController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Create your account".tr,
          style: TextStyle(fontSize: tablet ? 26 : 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: tablet ? 10 : 6),
        Text(
          "Sign up to start tracking your expenses.".tr,
          style: TextStyle(color: Colors.grey, fontSize: tablet ? 16 : 14),
        ),
        SizedBox(height: tablet ? 32 : 24),
        Text("Your Name".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),),
        SizedBox(height: tablet ? 8 : 4),
        
        // Name
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: tablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: "Enter your name".tr,
            contentPadding: EdgeInsets.symmetric(
              vertical: tablet ? 18 : 16, 
              horizontal: tablet ? 16 : 12
            ),
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Name is required".tr;
            if (v.trim().length < 2) return "Enter a valid name".tr;
            return null;
          },
        ),
        SizedBox(height: tablet ? 18 : 14),
        Text("Email Address".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),),
        SizedBox(height: tablet ? 8 : 4),

        // Email
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(fontSize: tablet ? 16 : 14),
          decoration:  InputDecoration(
            hintText: "Enter your email".tr,
            contentPadding: EdgeInsets.symmetric(
              vertical: tablet ? 18 : 16, 
              horizontal: tablet ? 16 : 12
            ),
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return "Email is required".tr;
            final email = v.trim();
            final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
            if (!ok) return "Enter a valid email".tr;
            return null;
          },
        ),
        SizedBox(height: tablet ? 18 : 14),
        Text("Password".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),),
        SizedBox(height: tablet ? 8 : 4),

        // Password
        Obx(() {
          return TextFormField(
            controller: passwordController,
            obscureText: controller.password.value,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: tablet ? 16 : 14),
            decoration: InputDecoration(
              hintText: "Password".tr,
              contentPadding: EdgeInsets.symmetric(
                vertical: tablet ? 18 : 16, 
                horizontal: tablet ? 16 : 12
              ),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: controller.togglePassword,
                icon: Icon(
                  controller.password.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: tablet ? 24 : 20,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Password is required".tr;
              if (v.length < 6) return "Password must be at least 6 characters".tr;
              return null;
            },
          );
        }),
        SizedBox(height: tablet ? 18 : 14),
        Text("Confirm Password".tr, style: TextStyle(fontWeight: FontWeight.w500, fontSize: tablet ? 16 : 14),),
        SizedBox(height: tablet ? 8 : 4),

        // Confirm Password
        Obx(() {
          return TextFormField(
            controller: confirmPasswordController,
            obscureText: controller.confirmPassword.value,
            textInputAction: TextInputAction.done,
            style: TextStyle(fontSize: tablet ? 16 : 14),
            decoration: InputDecoration(
              hintText: "Confirm Password".tr,
              contentPadding: EdgeInsets.symmetric(
                vertical: tablet ? 18 : 16, 
                horizontal: tablet ? 16 : 12
              ),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPassword,
                icon: Icon(
                  controller.confirmPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: tablet ? 24 : 20,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Confirm your password".tr;
              if (v != passwordController.text) return "Passwords do not match".tr;
              return null;
            },
          );
        }),
        SizedBox(height: tablet ? 28 : 20),

        // Create Account Button (Full width)
        SizedBox(
          width: double.infinity,
          height: tablet ? 54 : 50,
          child: ElevatedButton(
            onPressed: () {
              final valid = _formKey.currentState?.validate() ?? false;
              if (!valid) return;
              signUpModel model = signUpModel(name: nameController.text, email: emailController.text, password: passwordController.text);
              controller.createAccountWithEmail(model);
            },
            child: Text(
              "Create Account".tr,
              style: TextStyle(fontSize: tablet ? 17 : 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: tablet ? 24 : 16),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ".tr,
              style: TextStyle(color: Colors.grey, fontSize: tablet ? 15 : 14),
            ),
            GestureDetector(
              onTap: () {
                Get.back(); // or Get.to(LoginPage());
              },
              child: Text(
                "Login".tr,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: tablet ? 15 : 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: tablet ? 24 : 16),
        Align(
          alignment: Alignment.center,
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                "By creating an account, you agree to our ".tr,
                style: TextStyle(fontSize: tablet ? 14 : 12, color: Colors.grey),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(routes.TermsConditionsPage_screen);
                },
                child: Text(
                  "Terms & Conditions".tr,
                  style: TextStyle(
                    fontSize: tablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                " and ".tr,
                style: TextStyle(fontSize: tablet ? 14 : 12, color: Colors.grey),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(routes.PrivacyPolicyPage_screen);
                },
                child: Text(
                  "Privacy Policy".tr,
                  style: TextStyle(
                    fontSize: tablet ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ".",
                style: TextStyle(fontSize: tablet ? 14 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
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
