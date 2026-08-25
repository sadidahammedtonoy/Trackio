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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

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
                        style: const TextStyle(color: Colors.black),
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
              dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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
    final tablet = _isTablet(context);

    Widget body = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 24.0 : 20.w,
        vertical: tablet ? 10.0 : 10.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSection(tablet),
          SizedBox(height: tablet ? 16.0 : 20.h),
          _buildMotivationSection(tablet),
          SizedBox(height: tablet ? 20.0 : 30.h),
          _buildDetailFields(context, tablet),
          SizedBox(height: tablet ? 20.0 : 30.h),
          _buildSaveButton(tablet, isEditing),
          SizedBox(height: tablet ? 16.0 : 20.h),
        ],
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
          title: Text(
            isEditing ? "Edit Saving".tr : "Add Saving".tr,
            style: tablet ? const TextStyle(fontSize: 18.0) : null,
          ),
          centerTitle: false,
          titleSpacing: -10,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        body: body,
        floatingActionButton: _buildCalculatorButton(tablet),
      ),
    );
  }

  Widget _buildMotivationSection(bool tablet) {
    return Obx(
      () => _GlassCard(
        tablet: tablet,
        padding: EdgeInsets.all(tablet ? 16.0 : 16.r),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.motivationTitle.value.tr,
                style: TextStyle(
                  fontSize: tablet ? 16.0 : 15.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: tablet ? 4.0 : 4.h),
              Text(
                controller.motivationSubtitle.value.tr,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: tablet ? 14.0 : 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection(bool tablet) {
    return Center(
      child: Column(
        children: [
          Text(
            "How much?".tr,
            style: TextStyle(
              fontSize: tablet ? 14.0 : 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: tablet ? 8.0 : 10.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tablet ? 12.0 : 16.w,
              vertical: tablet ? 6.0 : 8.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "৳",
                  style: TextStyle(
                    fontSize: tablet ? 24.0 : 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: tablet ? 8.0 : 10.w),
                SizedBox(
                  width: tablet ? 180.0 : 200.w,
                  child: TextField(
                    controller: controller.amountC,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: tablet ? 40.0 : 48.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
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

  Widget _buildDetailFields(BuildContext context, bool tablet) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(
                  () => _InfoCard(
                    tablet: tablet,
                    icon: HugeIcons.strokeRoundedCalendar01,
                    label: "Date".tr,
                    content: Text(
                      DateFormat('dd MMM, yyyy').format(controller.selectedDate.value),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: tablet ? 14.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _pickDate(context),
                  ),
                ),
              ),
              SizedBox(width: tablet ? 12.0 : 16.w),
              Expanded(
                child: Obx(
                  () => _InfoCard(
                    tablet: tablet,
                    icon: HugeIcons.strokeRoundedWallet01,
                    label: "Wallet".tr,
                    content: Text(
                      controller.selectedWallet.value.tr,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: tablet ? 14.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _showWalletPicker(context, tablet),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tablet ? 12.0 : 16.h),
        _InfoCard(
          tablet: tablet,
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
              fontSize: tablet ? 13.0 : 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SizedBox(height: tablet ? 12.0 : 16.h),
        _InfoCard(
          tablet: tablet,
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
              fontSize: tablet ? 13.0 : 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool tablet, bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: tablet ? 48.0 : 56.h,
      child: ElevatedButton(
        onPressed: controller.saveSaving,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tablet ? 14.0 : 16.r),
          ),
          elevation: 0,
        ),
        child: Text(
          isEditing ? "Update Saving".tr : "Add Saving".tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: tablet ? 15.0 : 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(bool tablet) {
    return FloatingActionButton(
      onPressed: () => Get.dialog(CalculatorDialog(), barrierDismissible: true),
      backgroundColor: Colors.white.withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tablet ? 12.0 : 15.r),
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Lottie.asset(assets_path.calculator, height: tablet ? 26.0 : 30.h, repeat: false),
    );
  }

  void _showWalletPicker(BuildContext context, bool tablet) {
    final sheet = _PickerSheet(
      title: "Select Wallet".tr,
      tablet: tablet,
      items: controller.wallets
          .map((w) => PickerItem(
                icon: _getWalletIcon(w),
                label: w.tr,
                isSelected: controller.selectedWallet.value == w,
                tablet: tablet,
                onTap: () {
                  controller.selectedWallet.value = w;
                  Get.back();
                },
              ))
          .toList(),
    );

    if (tablet) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 480),
            child: sheet,
          ),
        ),
      );
    } else {
      Get.bottomSheet(sheet, isScrollControlled: true);
    }
  }

  dynamic _getWalletIcon(String wallet) {
    switch (wallet) {
      case "Cash":          return Icons.money_outlined;
      case "Mobile Banking": return Icons.phone_android_outlined;
      case "Bank":          return Icons.account_balance_outlined;
      default:              return Icons.account_balance_wallet_outlined;
    }
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
          padding: padding ?? EdgeInsets.all(tablet ? 14.0 : 16.r),
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
        padding: EdgeInsets.all(tablet ? 14.0 : 16.r),
        child: cardContent,
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<PickerItem> items;
  final bool tablet;
  const _PickerSheet({required this.title, required this.items, this.tablet = false});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: tablet ? 20.0 : 16.h,
          horizontal: tablet ? 16.0 : 12.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: tablet
              ? BorderRadius.circular(20)
              : BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!tablet)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                fontSize: tablet ? 16.0 : 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: tablet ? 16.0 : 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: tablet ? 6.0 : 8.h),
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
  final bool tablet;

  const PickerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.tablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = tablet ? 18.0 : 20.sp;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tablet ? 10.0 : 12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tablet ? 14.0 : 16.w,
          vertical: tablet ? 10.0 : 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(tablet ? 10.0 : 12.r),
        ),
        child: Row(
          children: [
            (icon is IconData)
                ? Icon(icon, size: iconSize, color: isSelected ? AppColors.primary : Colors.black54)
                : HugeIcon(icon: icon, size: iconSize, color: isSelected ? AppColors.primary : Colors.black54),
            SizedBox(width: tablet ? 10.0 : 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: tablet ? 14.0 : 15.sp,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: iconSize),
          ],
        ),
      ),
    );
  }
}