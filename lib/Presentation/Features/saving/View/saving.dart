import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sadid/App/AppColors.dart' hide AppColors;
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

  Future<double?> _showAddDialog() async {
    final c = TextEditingController();

    final result = await Get.dialog<double>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Add to Overall Saving".tr),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter amount".tr,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: Text("Cancel".tr, style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(c.text.trim());
              Get.back(result: amount);
            },
            child: Text("Add".tr, style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result;
  }

  Future<bool> _showResetDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Remove Overall Saving".tr),
        content: Text("This will set Overall Saving to 0. Continue?".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Cancel".tr, style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text("Remove".tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  Widget _card({ required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Overall Saving".tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                "Total History".tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgets = [allMonthSavingsList(), AllSavingsListWidget()];

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          title: Text(
            "Savings".tr,
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
          actions: [
            IconButton(
              onPressed: () => controller.openAddSavingSheet(context),
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            Get.dialog(CalculatorDialog(), barrierDismissible: true);
          },
          child: SizedBox(
            width: 50,
            height: 50,
            child: Lottie.asset(
              assets_path.calculator,
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
        ),
      
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ✅ 2) Overall Saving (stored separately)
              _GlassCard(
                padding: EdgeInsets.all(16.r),
                child: StreamBuilder<double>(
                  stream: controller.streamOverallSaving(),
                  builder: (context, snap) {
                    final overall = snap.data ?? 0.0;
      
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Overall Saving".tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "Total History".tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "৳${numberTranslation.toBnDigits(overall.toStringAsFixed(0))}",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
      
                            StreamBuilder<String>(
                              stream: controller.streamTotalSavingsText(),
                              builder: (context, snapshot) {
                                final totalText = snapshot.data ?? "0";
      
                                return Text(
                                  "৳${numberTranslation.toBnDigits(totalText)}",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(0.8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                onPressed: () async {
                                  final amount = await _showAddDialog();
                                  if (amount == null) return;
                                  if (amount <= 0) return;
      
                                  await controller.addToOverallSaving(amount);
                                },
                                child: Text("Add".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                                ),
                                onPressed: () async {
                                  final confirm = await _showResetDialog();
                                  if (!confirm) return;
      
                                  await controller.resetOverallSaving();
                                },
                                child: Text("Remove".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Remove means Overall Saving will be set to 0.".tr,
                          style: TextStyle(color: Colors.black38, fontSize: 11.sp, fontStyle: FontStyle.italic),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
