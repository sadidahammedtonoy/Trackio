import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/add_budget_controller.dart';

class AddBudgetScreen extends StatelessWidget {
  const AddBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddBudgetController controller = Get.put(AddBudgetController());

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Obx(() => Text(controller.budgetId.value.isEmpty ? 'Add Budget'.tr : 'Edit Budget'.tr)),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Amount".tr),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '৳',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextFormField(
                              controller: controller.amountController,
                              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: '0'.tr,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero, // Adjust alignment
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount'.tr;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                 _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Category (one or more)".tr),
                      SizedBox(height: 10.h),
                      _CategoryPicker(controller: controller),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() {
                  if (controller.selectedCategories.length > 1) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel("Group Name".tr),
                            TextFormField(
                              controller: controller.groupNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g., Monthly Utilities'.tr,
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (controller.selectedCategories.length > 1 && (value == null || value.isEmpty)) {
                                  return 'Please enter a group name'.tr;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel("Month".tr),
                      Obx(
                        () => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(DateFormat('MMMM yyyy').format(controller.selectedMonth.value)),
                          trailing: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
                          onTap: () => controller.selectMonth(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.saveOrUpdateBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Obx(() => Text(
                      controller.budgetId.value.isEmpty ? 'Save Budget'.tr : 'Update Budget'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black54),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.black.withOpacity(0.07), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final AddBudgetController controller;
  const _CategoryPicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text("No categories found".tr, style: const TextStyle(color: Colors.black26)),
        );
      }

      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: controller.categories.map((cat) {
          final name = (cat["name"] ?? "").toString();
          final isSelected = controller.selectedCategories.contains(name);

          return InkWell(
            onTap: () => controller.toggleCategory(name),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined, size: 16.sp, color: isSelected ? AppColors.primary : Colors.black45),
                  SizedBox(width: 6.w),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected ? AppColors.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
