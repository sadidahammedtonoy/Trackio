import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Authentication/Signup/Model/signupModel.dart';
import '../Controller/Controller.dart';

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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sign up to start tracking your expenses.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Text("Your Name", style: TextStyle(fontWeight: FontWeight.w500),),

                // Name
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Enter your name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Name is required";
                    if (v.trim().length < 2) return "Enter a valid name";
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text("Email Address", style: TextStyle(fontWeight: FontWeight.w500),),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Email is required";
                    final email = v.trim();
                    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
                    if (!ok) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text("Password", style: TextStyle(fontWeight: FontWeight.w500),),

                // Password
                Obx(() {
                  return TextFormField(
                    controller: passwordController,
                    obscureText: controller.password.value,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: controller.togglePassword,
                        icon: Icon(
                          controller.password.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Password is required";
                      if (v.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  );
                }),
                const SizedBox(height: 14),
                Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.w500),),


                // Confirm Password
                Obx(() {
                  return TextFormField(
                    controller: confirmPasswordController,
                    obscureText: controller.confirmPassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: controller.toggleConfirmPassword,
                        icon: Icon(
                          controller.confirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Confirm your password";
                      if (v != passwordController.text) return "Passwords do not match";
                      return null;
                    },
                  );
                }),
                const SizedBox(height: 20),

                // Create Account Button (Full width)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final valid = _formKey.currentState?.validate() ?? false;
                      if (!valid) return;
                      signUpModel model = signUpModel(name: nameController.text, email: emailController.text, password: passwordController.text);
                      controller.createAccountWithEmail(model);
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back(); // or Get.to(LoginPage());
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        "By creating an account, you agree to our ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(routes.TermsConditionsPage_screen);
                        },
                        child: const Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text(
                        " and ",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(routes.PrivacyPolicyPage_screen);
                        },
                        child: const Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text(
                        ".",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
