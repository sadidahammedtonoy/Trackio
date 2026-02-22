import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/snakbar.dart';
import '../../../Share/Background.dart';
import '../../permanentAccount/View/permanentAccount.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class setting_page extends StatelessWidget {
  setting_page({super.key});
  final controller = Get.find<settingController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings".tr,),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              const SizedBox(height: 0,),
              Row(
                spacing: 10,
                children: [
                  controller.getUserProfileImage() == null ? Icon(Icons.person, size: 30,) : CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(controller.getUserProfileImage() ?? ""),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.getUserName(), style: TextStyle(fontSize: 25.sp)),
                      Text(controller.getUserEmail() ?? "", style: TextStyle(fontSize: 16.sp),),
                    ],
                  )
                ],
              ),

              Text("Manage Profile".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
              GestureDetector(
                onTap: () {
                  if (!controller.isEmailPasswordUser()) {
                    AppSnackbar.show(
                      "Name change is available for email/password accounts only.".tr,
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  controller.nameC.text = user?.displayName ?? "";

                  Get.dialog(
                    barrierDismissible: false,
                    AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text("Your Name".tr),
                      content: TextField(
                        controller: controller.nameC,
                        decoration: InputDecoration(
                          hintText: "Enter your name".tr,
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Get.back(),
                                child: Text("Cancel".tr, style: TextStyle(color: Colors.black),),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.changeName,
                                child: Text("Done".tr, style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        )

                      ],
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 25),
                    const SizedBox(width: 10),
                    Text("Your Name".tr, style: TextStyle(fontSize: 18.sp)),
                    const Spacer(),
                    const Icon(Icons.arrow_right),
                  ],
                ),
              ),

              Text("Money Management".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
              GestureDetector(
                onTap: () => Get.toNamed(routes.saving_screen),
                child: Row(
                  children: [
                    Icon(Icons.savings_outlined, size: 25,),
                    SizedBox(width: 10,),
                    Text("Savings".tr, style: TextStyle(fontSize: 18.sp)),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => Get.toNamed(routes.categories_screen),
                child: Row(
                  children: [
                    Icon(Icons.category_outlined, size: 25,),
                    SizedBox(width: 10,),
                    Text("Categories".tr, style: TextStyle(fontSize: 18.sp),),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),

              const SizedBox(height: 0,),
              Text("Security".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
              GestureDetector(
                onTap: () => Get.toNamed(routes.PrivacyPolicyPage_screen),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, size: 25,),
                    SizedBox(width: 10,),
                    Text("Privacy Policy".tr, style: TextStyle(fontSize: 18.sp),),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(routes.TermsConditionsPage_screen),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 25,),
                    SizedBox(width: 10,),
                    Text("Terms & Conditions".tr, style: TextStyle(fontSize: 18.sp),),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(routes.HelpSupportPage_screen),
                child: Row(
                  children: [
                    Icon(Icons.support_agent_outlined, size: 25,),
                    SizedBox(width: 10,),
                    Text("Help & Support".tr, style: TextStyle(fontSize: 18.sp),),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
              Visibility(
                visible: controller.isEmailPasswordUser(),
                child: GestureDetector(
                  onTap: () => Get.toNamed(routes.changePassword_screen),
                  child: Row(
                    children: [
                      Icon(Icons.password, size: 25,),
                      SizedBox(width: 10,),
                      Text("Change Password".tr, style: TextStyle(fontSize: 18.sp)),
                      Spacer(),
                      Icon(Icons.arrow_right)
                    ],
                  ),
                ),
              ),
              Text("Language".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: Container(
                            height: 5,
                            width: 50,
                            decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(50),
                          ),),),
                          const SizedBox(height: 10,),
                          Text("Choose Language".tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),),
                          Text("Choose your preferred language for the app".tr),
                          Divider(),
                          ListTile(
                            title: const Text("বাংলা"),
                            onTap: () {
                              controller
                                  .changeLanguageInstant(const Locale('bn', 'BD'));
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: const Text("English"),
                            onTap: () {
                              controller
                                  .changeLanguageInstant(const Locale('en', 'US'));
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.language_outlined, size: 25),
                    SizedBox(width: 10),
                    // keep your .tr label
                    Expanded(
                      child: Text(
                        "Language".tr,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),



              Text("Account".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),

              Visibility(
                visible: controller.isGuestUser(),
                child: GestureDetector(
                  onTap: () {
                    Get.dialog(
                        MakePermanentDialog()
                    );

                  },
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 25, color: Colors.green,),
                      SizedBox(width: 10,),
                      Text("Make permanent account".tr, style: TextStyle(fontSize: 18.sp, color: Colors.green),),
                    ],
                  ),
                ),
              ),


              GestureDetector(
                onTap: () => controller.showLogoutDialog(onConfirm: () => controller.logout()),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 25,),
                    SizedBox(width: 10,),
                    Text("Log Out".tr, style: TextStyle(color: Colors.red, fontSize: 18.sp),),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => controller.confirmDeleteAccount(),
                child: Row(
                  children: [
                    Icon(Icons.supervisor_account_rounded, color: Colors.redAccent, size: 25,),
                    SizedBox(width: 10,),
                    Text("Delete Account".tr, style: TextStyle(color: Colors.red, fontSize: 18.sp),),
                  ],
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),

    );
  }
}
