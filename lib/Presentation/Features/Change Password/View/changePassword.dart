import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/Controller.dart';

class changePassword extends StatelessWidget {
  changePassword({super.key});
  final controller = Get.find<changePasswordController>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Current Password"),
              Obx(() => TextFormField(
                obscureText: controller.oldPassword.value,
                controller: currentPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: (){
                        controller.oldPassword.value = !controller.oldPassword.value;
                      },
                      child: Icon(controller.oldPassword.value ? Icons.visibility_off : Icons.remove_red_eye)),
                  hintText: "Current password"
                ),
              ),),
              const SizedBox(height: 10,),
              Text("New Password"),
              Obx(() => TextFormField(
                obscureText: controller.newPassword.value,
                controller: newPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: (){
                        controller.newPassword.value = !controller.newPassword.value;
                      },
                      child: Icon(controller.newPassword.value ? Icons.visibility_off : Icons.remove_red_eye)),
                  hintText: "New password"
                ),
              ),),
              const SizedBox(height: 10,),
              Text("Confirm New Password"),
              Obx(() => TextFormField(
                obscureText: controller.confirmPassword.value,
                controller: confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  } else if(value != newPasswordController.text){
                    return 'Passwords do not match';
                  }
                  else if(value == newPasswordController){
                    return 'Passwords must be different';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: (){
                        controller.confirmPassword.value = !controller.confirmPassword.value;
                      },
                      child: Icon(controller.confirmPassword.value ? Icons.visibility_off : Icons.remove_red_eye)),
                  hintText: "Confirm password"
                ),
              ),),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                controller.changePassword(currentPassword: currentPasswordController.text, newPassword: newPasswordController.text);
              }, child: Text("Change Password", style: TextStyle(color: Colors.white),))
            ],
          ),
        ),
      ),
    );
  }
}
