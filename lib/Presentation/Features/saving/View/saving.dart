import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/App/assets_path.dart';
import 'package:sadid/Core/numberTranslation.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../calcolator/View/calculator.dart';
import '../Controller/Controller.dart';
import '../Model/savingModel.dart';
import 'history.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
class saving extends StatelessWidget {
  final controller = Get.put(savingController());
  saving({super.key});

  @override
  Widget build(BuildContext context) {
    final widgets = [allMonthSavingsList(), AllSavingsListWidget()];

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          titleSpacing: -10,
          title: Text(
            "Savings".tr,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.openAddSavingSheet(context),
          backgroundColor: Colors.white.withOpacity(0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(Icons.ads_click_rounded, color: Colors.black, size: 30.sp),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _GlassCard(
                padding: EdgeInsets.all(4.r),
                borderRadius: BorderRadius.circular(16.r),
                child: Obx(() {
                  return Row(
                    children: [
                      _tabButton(
                        label: "Overview".tr,
                        index: 0,
                        selectedIndex: controller.tabIndex.value,
                        onTap: () => controller.changeTab(0),
                      ),
                      _tabButton(
                        label: "History".tr,
                        index: 1,
                        selectedIndex: controller.tabIndex.value,
                        onTap: () => controller.changeTab(1),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 10),

              Obx(() => widgets[controller.tabIndex.value]),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _tabButton({
  required String label,
  required int index,
  required int selectedIndex,
  required VoidCallback onTap,
}) {
  final isSelected = selectedIndex == index;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    ),
  );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

Widget allMonthSavingsList() {
  final controller = Get.find<savingController>();

  String formatMonth(String mk) {
    final parts = mk.split('-');
    if (parts.length != 2) return mk;
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 1;
    final dt = DateTime(year, month, 1);
    return DateFormat('MMM yyyy').format(dt);
  }

  Widget buildList(List<MonthSaving> months) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: months.map((m) {
        final saving = m.saving;
        final isPositive = saving >= 0;

        return _GlassCard(
          margin: EdgeInsets.only(bottom: 20.h),
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  numberTranslation.formatMonthYearBnFromString(formatMonth(m.monthKey)),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(color: Colors.black.withOpacity(0.05)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SavingsStat(
                    icon: Icons.trending_up_outlined,
                    label: "Income".tr,
                    amount: m.income,
                    color: Colors.green,
                  ),
                  _SavingsStat(
                    icon: Icons.trending_down_rounded,
                    label: "Expense".tr,
                    amount: m.expense,
                    color: Colors.redAccent,
                  ),
                  _SavingsStat(
                    icon: Icons.account_balance_rounded,
                    label: "Balance".tr,
                    amount: saving,
                    color: isPositive ? Colors.blue : Colors.orange,
                    showSign: true,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  return StreamBuilder<List<MonthSaving>>(
    stream: controller.streamAllMonthSavings(),
    builder: (context, snap) {
      // ✅ Save new data into cache (silent updates)
      if (snap.hasData) {
        controller.cachedMonths.assignAll(snap.data!);
      }

      // ✅ Use cached data when waiting (no flicker)
      final months = controller.cachedMonths;

      // ✅ Show loader only on very first load (no cache yet)
      if (snap.connectionState == ConnectionState.waiting && months.isEmpty) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      if (snap.hasError && months.isEmpty) {
        return Center(child: Text("Error: ${snap.error}"));
      }

      if (months.isEmpty) {
        return Center(child: Text("No monthly data found".tr));
      }

      return Obx(() => buildList(controller.cachedMonths));
    },
  );
}

class _SavingsStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool showSign;

  const _SavingsStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          "${showSign && amount > 0 ? '+' : ''}${numberTranslation.toBnDigits(amount.toStringAsFixed(0))} ৳",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}