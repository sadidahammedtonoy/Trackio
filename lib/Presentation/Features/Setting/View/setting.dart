import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class setting_page extends StatelessWidget {
  setting_page({super.key});
  final controller = Get.find<settingController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 15,
          children: [
            ListTile(
              leading: controller.getUserProfileImage() == null ? Icon(Icons.person, size: 30,) : CircleAvatar(
                backgroundImage: NetworkImage(controller.getUserProfileImage() ?? ""),
              ),
              title: Text(controller.getUserName(), style: TextStyle(fontSize: 18.sp)),
              subtitle: Text(controller.getUserEmail() ?? "", style: TextStyle(fontSize: 16.sp),),
            ),

            Text("Money Management", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
            GestureDetector(
              onTap: () => Get.toNamed(routes.saving_screen),
              child: Row(
                children: [
                  Icon(Icons.savings_outlined, size: 30,),
                  SizedBox(width: 10,),
                  Text("Savings", style: TextStyle(fontSize: 18.sp)),
                  Spacer(),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),

            GestureDetector(
              onTap: () => Get.toNamed(routes.categories_screen),
              child: Row(
                children: [
                  Icon(Icons.category_outlined, size: 30,),
                  SizedBox(width: 10,),
                  Text("Categories", style: TextStyle(fontSize: 18.sp),),
                  Spacer(),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            const SizedBox(height: 0,),
            Text("Security", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),
            GestureDetector(
              onTap: () => Get.toNamed(routes.PrivacyPolicyPage_screen),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, size: 30,),
                  SizedBox(width: 10,),
                  Text("Privacy Policy", style: TextStyle(fontSize: 18.sp),),
                  Spacer(),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(routes.TermsConditionsPage_screen),
              child: Row(
                children: [
                  Icon(Icons.description, size: 30,),
                  SizedBox(width: 10,),
                  Text("Terms & Conditions", style: TextStyle(fontSize: 18.sp),),
                  Spacer(),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(routes.HelpSupportPage_screen),
              child: Row(
                children: [
                  Icon(Icons.support_agent_outlined, size: 30,),
                  SizedBox(width: 10,),
                  Text("Help & Support", style: TextStyle(fontSize: 18.sp),),
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
                    Icon(Icons.password, size: 30,),
                    SizedBox(width: 10,),
                    Text("Change Password", style: TextStyle(fontSize: 18.sp)),
                    Spacer(),
                    Icon(Icons.arrow_right)
                  ],
                ),
              ),
            ),
            Text("Account", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),),


            GestureDetector(
              onTap: () => controller.showLogoutDialog(onConfirm: () => controller.logout()),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 30,),
                  SizedBox(width: 10,),
                  Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 18.sp),),
                ],
              ),
            ),

            GestureDetector(
              onTap: () => controller.confirmDeleteAccount(),
              child: Row(
                children: [
                  Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 30,),
                  SizedBox(width: 10,),
                  Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 18.sp),),
                ],
              ),
            ),
            SizedBox(height: 10,)


          ],
        ),
      ),

    );
  }
}
