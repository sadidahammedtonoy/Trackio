import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/App/AppColors.dart';
import '../../../../Core/snakbar.dart';
import '../../permanentAccount/View/permanentAccount.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class setting_page extends StatelessWidget {
  setting_page({super.key});
  final controller = Get.find<settingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                children: [
                   _buildProfileSection(),
                  SizedBox(height: 20.h),
                  _buildGeneralSection(),
                  SizedBox(height: 20.h),
                  _buildSecuritySection(),
                  SizedBox(height: 20.h),
                  _buildAccountSection(),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileSection() {
    return _GlassCard(
      child: GetBuilder<settingController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Profile".tr,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  _buildAvatar(),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StreamBuilder<String>(
                          stream: controller.userNameStream(),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "User",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        Text(
                          controller.getUserEmail() ?? "",
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showEditNameDialog(),
                    icon: Icon(Icons.edit_note_rounded,
                        color: AppColors.primary, size: 28.sp),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String imageUrl =
            "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['photoUrl'] != null &&
              data['photoUrl'].toString().isNotEmpty) {
            imageUrl = data['photoUrl'];
          }
        }

        return GestureDetector(
          onTap: () => controller.showImageSourceDialog(),
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 35.r,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("General".tr),
          _SettingItem(
            icon: Icons.palette_outlined,
            title: "Theme".tr,
            onTap: () => Get.toNamed(routes.backgroundSelection_screen),
            iconColor: Colors.blueAccent,
          ),
          _SettingItem(
            icon: Icons.savings_outlined,
            title: "Savings".tr,
            onTap: () => Get.toNamed(routes.saving_screen),
            iconColor: AppColors.yellow,
          ),
          _SettingItem(
            icon: Icons.insights_rounded,
            title: "Insights".tr,
            onTap: () => Get.toNamed(routes.insights_screen),
            iconColor: Colors.blue,
          ),
           _SettingItem(
            icon: Icons.repeat_rounded,
            title: "Automation".tr,
            onTap: () => Get.toNamed(routes.recurring_screen),
            iconColor: AppColors.primary,
          ),
          _SettingItem(
            icon: Icons.category_outlined,
            title: "Categories".tr,
            onTap: () => Get.toNamed(routes.categories_screen),
            iconColor: AppColors.purple,
          ),
          _SettingItem(
            icon: Icons.language_outlined,
            title: "Language".tr,
            onTap: () => _showLanguageSelector(),
            iconColor: AppColors.sky,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Security & Support".tr),
          _SettingItem(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy".tr,
            onTap: () => Get.toNamed(routes.PrivacyPolicyPage_screen),
            iconColor: AppColors.green,
          ),
          _SettingItem(
            icon: Icons.description_outlined,
            title: "Terms & Conditions".tr,
            onTap: () => Get.toNamed(routes.TermsConditionsPage_screen),
            iconColor: Colors.amber,
          ),
          _SettingItem(
            icon: Icons.support_agent_outlined,
            title: "Help & Support".tr,
            onTap: () => Get.toNamed(routes.HelpSupportPage_screen),
            iconColor: Colors.orangeAccent,
          ),
          _SettingItem(
            icon: Icons.lock_reset_outlined,
            title: "Change Password".tr,
            onTap: () => Get.toNamed(routes.changePassword_screen),
            iconColor: AppColors.red,
            showDivider: false,
            visible: controller.isEmailPasswordUser(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Account".tr),
          _SettingItem(
            icon: Icons.verified_outlined,
            title: "Make permanent account".tr,
            onTap: () => Get.dialog(MakePermanentDialog()),
            iconColor: Colors.green,
            textColor: Colors.green,
            visible: controller.isGuestUser(),
          ),
          _SettingItem(
            icon: Icons.logout_rounded,
            title: "Log Out".tr,
            onTap: () => controller.showLogoutDialog(
                onConfirm: () => controller.logout()),
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
          ),
          _SettingItem(
            icon: Icons.delete_forever_outlined,
            title: "Delete Account".tr,
            onTap: () => controller.confirmDeleteAccount(),
            iconColor: Colors.red,
            textColor: Colors.red,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showEditNameDialog() async {
    if (controller.isGuestUser()) {
      AppSnackbar.show(
          "Name change is available for permanent accounts only.".tr);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        controller.nameC.text = doc.data()!['name'] ?? "";
      }
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title:
            Text("Update Name".tr, style: const TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller.nameC,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Enter your name".tr,
            hintStyle: const TextStyle(color: Colors.black38),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                Text("Cancel".tr, style: const TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: controller.changeName,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child:
                Text("Update".tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  height: 4.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Language".tr,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Select your preferred language".tr,
                    style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _SettingItem(
              icon: Icons.language,
              title: "বাংলা",
              onTap: () {
                controller.changeLanguageInstant(const Locale('bn', 'BD'));
                Get.back();
              },
              iconColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            ),
            _SettingItem(
              icon: Icons.language,
              title: "English",
              onTap: () {
                controller.changeLanguageInstant(const Locale('en', 'US'));
                Get.back();
              },
              iconColor: AppColors.primary,
              showDivider: false,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const _GlassCard({required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2), // Frosted white opacity
        borderRadius: BorderRadius.circular(24.r),
        // border: Border.all(color: Colors.white.withOpacity(0.5)),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;
  final bool showDivider;
  final bool visible;
  final EdgeInsetsGeometry? padding;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.black87,
    this.textColor = Colors.black,
    this.showDivider = true,
    this.visible = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.black12, size: 24.sp),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
              color: Colors.black.withOpacity(0.05),
              height: 1.h,
              indent: 45.w),
      ],
    );
  }
}
