import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../../../App/assets_path.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';

class AddSavingSheet extends StatelessWidget {
  final savingController controller;
  const AddSavingSheet({super.key, required this.controller});

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
    final isEditing = controller.editingItemId != null;

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEditing ? "Edit Saving".tr : "Add Saving".tr),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountSection(),
              SizedBox(height: 20.h),
              _buildMotivationSection(),
              SizedBox(height: 30.h),
              _buildDetailFields(context),
              SizedBox(height: 30.h),
              _buildSaveButton(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        floatingActionButton: _buildCalculatorButton(),
      ),
    );
  }

  Widget _buildMotivationSection() {
    return Obx(
      () => _GlassCard(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.motivationTitle.value.tr,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              controller.motivationSubtitle.value.tr,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Center(
      child: Column(
        children: [
          Text(
            "How much?".tr,
            style: TextStyle(fontSize: 16.sp, color: Colors.black54),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "৳",
                  style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 200.w,
                  child: TextField(
                    controller: controller.amountC,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w900, color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailFields(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(
                  () => _InfoCard(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    label: "Date".tr,
                    content: Text(
                      DateFormat('dd MMM, yyyy').format(controller.selectedDate.value),
                      style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _pickDate(context),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Obx(
                  () => _InfoCard(
                    icon: HugeIcons.strokeRoundedWallet01,
                    label: "Wallet".tr,
                    content: Text(
                      controller.selectedWallet.value.tr,
                      style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _showWalletPicker(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _InfoCard(
          isFullWidth: true,
          icon: Icons.source_outlined,
          label: "Source".tr,
          content: TextField(
            controller: controller.sourceC,
            decoration: InputDecoration(
              hintText: "From where this money came from".tr,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _InfoCard(
          isFullWidth: true,
          icon: HugeIcons.strokeRoundedStickyNote01,
          label: "Note (optional)".tr,
          content: TextField(
            controller: controller.noteC,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Anything you want to remember...".tr,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final isEditing = controller.editingItemId != null;
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.saveSaving,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 0,
        ),
        child: Text(
          isEditing ? "Update Saving".tr : "Add Saving".tr,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCalculatorButton() {
    return FloatingActionButton(
      onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
      backgroundColor: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Lottie.asset(assets_path.calculator, height: 30.h, repeat: false),
    );
  }

  void _showWalletPicker(BuildContext context) {
    Get.bottomSheet(
      _PickerSheet(
        title: "Select Wallet".tr,
        items: controller.wallets
            .map((w) => PickerItem(
                  icon: _getWalletIcon(w),
                  label: w.tr,
                  isSelected: controller.selectedWallet.value == w,
                  onTap: () {
                    controller.selectedWallet.value = w;
                    Get.back();
                  },
                ))
            .toList(),
      ),
      isScrollControlled: true,
    );
  }

  dynamic _getWalletIcon(String wallet) {
    switch (wallet) {
      case "Cash":
        return Icons.money_outlined;
      case "Mobile Banking":
        return Icons.phone_android_outlined;
      case "Bank":
        return Icons.account_balance_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20.r),
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

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.content,
    this.onTap,
    this.isFullWidth = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent;
    if (isFullWidth) {
      cardContent = Row(
        children: [
          (icon is IconData) ? Icon(icon, size: 22.sp, color: Colors.black54) : HugeIcon(icon: icon, size: 22.sp, color: Colors.black54),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
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
          (icon is IconData) ? Icon(icon, size: 22.sp, color: Colors.black54) : HugeIcon(icon: icon, size: 22.sp, color: Colors.black54),
          const Spacer(),
          Text(label, style: TextStyle(color: Colors.black45, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          content,
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: EdgeInsets.all(16.r),
        child: cardContent,
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<PickerItem> items;
  const _PickerSheet({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, index) => items[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PickerItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PickerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            (icon is IconData)
                ? Icon(icon, size: 20.sp, color: isSelected ? AppColors.primary : Colors.black54)
                : HugeIcon(icon: icon, size: 20.sp, color: isSelected ? AppColors.primary : Colors.black54),
            SizedBox(width: 12.w),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15.sp))),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}