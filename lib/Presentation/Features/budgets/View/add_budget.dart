import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../Controller/add_budget_controller.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class AddBudgetScreen extends StatelessWidget {
  const AddBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddBudgetController controller = Get.put(AddBudgetController());
    final tablet = _isTablet(context);

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 24.0 : 20.w,
        vertical: tablet ? 16.0 : 10.h,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              tablet: tablet,
              isFullWidth: true,
              icon: HugeIcons.strokeRoundedWallet01,
              label: "Amount".tr,
              content: Row(
                children: [
                  Text(
                    '৳',
                    style: TextStyle(
                      fontSize: tablet ? 24.0 : 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(width: tablet ? 8.0 : 8.w),
                  Expanded(
                    child: TextFormField(
                      controller: controller.amountController,
                      style: TextStyle(
                        fontSize: tablet ? 24.0 : 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '0'.tr,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
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
            ),
            SizedBox(height: tablet ? 16.0 : 16.h),
            _InfoCard(
              tablet: tablet,
              isFullWidth: true,
              icon: Icons.category_outlined,
              label: "Category (one or more)".tr,
              content: _CategoryPicker(controller: controller, tablet: tablet),
            ),
            SizedBox(height: tablet ? 16.0 : 16.h),
            Obx(() {
              if (controller.selectedCategories.length > 1) {
                return Padding(
                  padding: EdgeInsets.only(bottom: tablet ? 16.0 : 16.h),
                  child: _InfoCard(
                    tablet: tablet,
                    isFullWidth: true,
                    icon: HugeIcons.strokeRoundedUserGroup,
                    label: "Group Name".tr,
                    content: TextFormField(
                      controller: controller.groupNameController,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: tablet ? 16.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., Monthly Utilities'.tr,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (controller.selectedCategories.length > 1 &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter a group name'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            _InfoCard(
              tablet: tablet,
              isFullWidth: true,
              icon: HugeIcons.strokeRoundedCalendar03,
              label: "Month".tr,
              content: Obx(
                () => Text(
                  DateFormat('MMMM yyyy').format(controller.selectedMonth.value),
                  style: TextStyle(
                    color: Colors.black87, 
                    fontSize: tablet ? 16.0 : 16.sp, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              onTap: () => controller.selectMonth(context),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded, 
                size: tablet ? 14.0 : 14.sp, 
                color: Colors.black45
              ),
            ),
            SizedBox(height: tablet ? 32.0 : 30.h),
            SizedBox(
              width: double.infinity,
              height: tablet ? 48.0 : 56.h,
              child: ElevatedButton(
                onPressed: controller.saveOrUpdateBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tablet ? 14.0 : 16.r)
                  ),
                  elevation: 0,
                ),
                child: Obx(() => Text(
                      controller.budgetId.value.isEmpty ? 'Save Budget'.tr : 'Update Budget'.tr,
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: tablet ? 15.0 : 18.sp, 
                        fontWeight: FontWeight.bold
                      ),
                    )),
              ),
            ),
            SizedBox(height: tablet ? 24.0 : 20.h),
          ],
        ),
      ),
    );

    if (tablet) {
      body = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: body,
        ),
      );
    }

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Obx(() => Text(
            controller.budgetId.value.isEmpty ? 'Add Budget'.tr : 'Edit Budget'.tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          )),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: body,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool tablet;
  const _GlassCard({required this.child, this.padding, this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? EdgeInsets.all(tablet ? 16.0 : 16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic icon;
  final String label;
  final Widget content;
  final VoidCallback? onTap;
  final bool isFullWidth;
  final Widget? trailing;
  final bool tablet;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.content,
    this.onTap,
    this.isFullWidth = false,
    this.trailing,
    this.tablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = tablet ? 18.0 : 22.sp;
    final labelStyle = TextStyle(
      color: Colors.black45,
      fontSize: tablet ? 11.0 : 12.sp,
      fontWeight: FontWeight.w600,
    );

    Widget cardContent;
    if (isFullWidth) {
      cardContent = Row(
        children: [
          (icon is IconData)
              ? Icon(icon, size: iconSize, color: Colors.black54)
              : HugeIcon(icon: icon, size: iconSize, color: Colors.black54),
          SizedBox(width: tablet ? 12.0 : 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                SizedBox(height: tablet ? 2.0 : 4.h),
                content,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
    } else {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (icon is IconData)
              ? Icon(icon, size: iconSize, color: Colors.black54)
              : HugeIcon(icon: icon, size: iconSize, color: Colors.black54),
          const Spacer(),
          Text(label, style: labelStyle),
          SizedBox(height: tablet ? 2.0 : 4.h),
          content,
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        tablet: tablet,
        padding: EdgeInsets.all(tablet ? 16.0 : 16.r),
        child: cardContent,
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final AddBudgetController controller;
  final bool tablet;
  const _CategoryPicker({required this.controller, this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: tablet ? 10.0 : 12.h),
          child: Text("No categories found".tr, style: const TextStyle(color: Colors.black26)),
        );
      }

      return Wrap(
        spacing: tablet ? 8.0 : 10.w,
        runSpacing: tablet ? 8.0 : 10.h,
        children: controller.categories.map((cat) {
          final name = (cat["name"] ?? "").toString();
          final isSelected = controller.selectedCategories.contains(name);

          return InkWell(
            onTap: () => controller.toggleCategory(name),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: tablet ? 6.0 : 8.h, 
                horizontal: tablet ? 10.0 : 12.w
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(tablet ? 8.0 : 10.r),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined, 
                    size: tablet ? 14.0 : 16.sp, 
                    color: isSelected ? AppColors.primary : Colors.black45
                  ),
                  SizedBox(width: tablet ? 4.0 : 6.w),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: tablet ? 13.0 : 13.sp,
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
