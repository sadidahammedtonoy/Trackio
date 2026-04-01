import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';

import '../../../../App/assets_path.dart';
import '../../../../Core/numberTranslation.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddSavingSheet extends StatelessWidget {
  final savingController controller;
  const AddSavingSheet({super.key, required this.controller});

  String _dateTextBn(DateTime d) => numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(d));

  Future<void> _pickDate(BuildContext context) async {
    if (Platform.isIOS) {
      DateTime temp = controller.selectedDate.value;

      await showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 320,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Done".tr,
                        style: TextStyle(color: AppColors.primary),
                      ),
                      onPressed: () {
                        controller.selectedDate.value = temp;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: controller.selectedDate.value,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              dialogTheme: DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) controller.selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          title: Text(
            "Add Saving".tr,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input (Amount-First Design)
              _GlassCard(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  children: [
                    Text(
                      "How much did you save?".tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: controller.amountC,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.2)),
                        border: InputBorder.none,
                        prefixText: "৳ ",
                        prefixStyle: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
      
              // Motivation Summary
              Obx(() => _GlassCard(
                    padding: EdgeInsets.all(16.r),
                    borderColor: AppColors.primary.withOpacity(0.2),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.sp),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.motivationTitle.value.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                controller.motivationSubtitle.value.tr,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 20.h),
      
              // Date Selection
              _sectionLabel("When did you save?".tr),
              Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _GlassChip(
                          isSelected: true,
                          label: _dateTextBn(controller.selectedDate.value),
                          onTap: () => _pickDate(context),
                          icon: Icons.calendar_today_rounded,
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 20.h),
      
              // Wallet Selection
              _sectionLabel("Select Wallet".tr),
              Obx(() => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: controller.wallets.map((w) {
                      final isSelected = controller.selectedWallet.value == w;
                      return _GlassChip(
                        isSelected: isSelected,
                        label: w.tr,
                        onTap: () => controller.selectedWallet.value = w,
                      );
                    }).toList(),
                  )),
              SizedBox(height: 20.h),
      
              // Source & Note
              _sectionLabel("Details".tr),
              _GlassCard(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    _GlassTextField(
                      controller: controller.sourceC,
                      label: "Source".tr,
                      hint: "e.g., Salary, Gift".tr,
                      icon: Icons.source_rounded,
                    ),
                    SizedBox(height: 16.h),
                    _GlassTextField(
                      controller: controller.noteC,
                      label: "Note (Optional)".tr,
                      hint: "Notes about this saving...".tr,
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
      
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: controller.addSaving,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                    ),
                    child: Text(
                      "Save Now".tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
          backgroundColor: Colors.white,
          child: Lottie.asset(assets_path.calculator, width: 30.sp),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const _GlassCard({required this.child, this.padding, this.borderColor, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: borderRadius ?? BorderRadius.circular(24.r),
            border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _GlassChip({required this.isSelected, required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        borderRadius: BorderRadius.circular(14.r),
        borderColor: isSelected ? AppColors.primary : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.sp, color: isSelected ? AppColors.primary : Colors.black54),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54, fontSize: 13.sp),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black26, fontSize: 13.sp),
        prefixIcon: Icon(icon, size: 18.sp, color: AppColors.primary.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
