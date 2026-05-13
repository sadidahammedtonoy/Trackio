import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/App/routes.dart';
import 'package:sadid/Core/numberTranslation.dart';
import 'package:sadid/Presentation/Share/Background.dart';
import '../../../../App/AppColors.dart';
import '../Controller/Controller.dart';
import '../Widgets/monthlyExpenseCharts.dart';

class VisualRepresentationPage extends StatelessWidget {
  VisualRepresentationPage({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final data = controller.monthSummary;
    final income = data["income"] ?? 0.0;
    final expense = data["expense"] ?? 0.0;
    final remaining = income - expense;
    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Visual Representation".tr,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    _SummaryCard(
                      icon: Icons.account_balance_wallet_outlined,
                      color: Colors.blueAccent,
                      label: "Remaining".tr,
                      amount: remaining,
                    ),
                    SizedBox(width: 12.w),
                    _SummaryCard(
                      icon: Icons.trending_down_rounded,
                      color: Colors.red,
                      label: "Expense".tr,
                      amount: expense,
                    ),
                    SizedBox(width: 12.w),
                    _SummaryCard(
                      icon: Icons.today_rounded,
                      color: Colors.blueGrey,
                      label: "Daily Limit".tr,
                      amount: (remaining > 0 ? remaining : 0) / controller.daysLeftInCurrentMonth(),
                    ),
                    SizedBox(width: 12.w),
                    _SummaryCard(
                      icon: Icons.trending_up_outlined,
                      color: Colors.green,
                      label: "Income".tr,
                      amount: income,
                    ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => Get.toNamed(routes.saving_screen),
                      child: _SummaryCard(
                        icon: Icons.savings_outlined,
                        color: Colors.cyan,
                        label: "Saving".tr,
                        amount: controller.totalSavingAllTime.value,
                      ),
                    ),
                  ],
                ),
              ),
              _sectionHeader("Expense Calendar".tr),
              _GlassCalendar(controller: controller),
              _sectionHeader("Category Breakdown".tr),
              _GlassCard(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.all(12.r),
                child: const CategoryPieChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.margin,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor ?? Colors.grey.withAlpha(77)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
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

class _GlassCalendar extends StatelessWidget {
  final DashboardController controller;
  const _GlassCalendar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      child: Obx(() {
        final selMonth = controller.selectedMonth.value;
        final dailyExp = controller.dailyExpenses;

        final firstDayOfMonth = DateTime(selMonth.year, selMonth.month, 1);
        final lastDayOfMonth = DateTime(selMonth.year, selMonth.month + 1, 0);
        final daysInMonth = lastDayOfMonth.day;
        final firstWeekday = firstDayOfMonth.weekday % 7;

        final expenses = dailyExp.values.where((e) => e > 0).toList()..sort();
        final maxExp = expenses.isNotEmpty ? expenses.last : 0.0;
        final lowest3 = expenses.take(3).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => controller.changeMonth(-1),
                  icon: Icon(Icons.chevron_left_rounded, color: Colors.black54, size: 24.sp),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(selMonth),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.changeMonth(1),
                  icon: Icon(Icons.chevron_right_rounded, color: Colors.black54, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                  .map((d) => SizedBox(
                        width: 35.w,
                        child: Center(
                          child: Text(
                            d.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: daysInMonth + firstWeekday,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox.shrink();

                final day = index - firstWeekday + 1;
                final amount = dailyExp[day] ?? 0.0;
                final now = DateTime.now();
                final isToday = now.day == day && now.month == selMonth.month && now.year == selMonth.year;

                Color borderColor = Colors.transparent;
                if (amount > 0) {
                  if (amount == maxExp) {
                    borderColor = Colors.red;
                  } else if (lowest3.contains(amount)) {
                    final rank = lowest3.indexOf(amount);
                    borderColor = Color.lerp(Colors.green.shade100, Colors.green.shade600, (rank + 1) / 3)!;
                  } else {
                    borderColor = Color.lerp(Colors.orange.shade200, Colors.orange.shade800, amount / maxExp)!;
                  }
                }

                return InkWell(
                  onTap: amount > 0 ? () => _showDayAmountDialog(context, day, selMonth, amount) : null,
                  borderRadius: BorderRadius.circular(10.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isToday ? AppColors.primary : borderColor,
                        width: isToday || amount > 0 ? 1.5 : 0,
                      ),
                      color: isToday
                          ? AppColors.primary.withAlpha(26)
                          : amount > 0
                              ? borderColor.withAlpha(13)
                              : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: isToday || amount > 0 ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? AppColors.primary : amount > 0 ? Colors.black87 : Colors.black45,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _showDayAmountDialog(BuildContext context, int day, DateTime month, double amount) {
    final dateStr =
        numberTranslation.formatDateBnFromString(DateFormat('dd MMMM yyyy').format(DateTime(month.year, month.month, day)));

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withAlpha(217),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Daily Expense".tr,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                SizedBox(height: 8.h),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primary.withAlpha(51)),
                  ),
                  child: Text(
                    "৳ ${numberTranslation.toBnDigits(amount.toStringAsFixed(0))}",
                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text("Close".tr, style: const TextStyle(color: Colors.black54)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double amount;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.all(15.r),
      borderColor: color.withAlpha(102),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.sp, color: color),
          ),
          SizedBox(height: 16.h, width: 120.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "৳${numberTranslation.toBnDigits(amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1))}",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
