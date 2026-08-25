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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class VisualRepresentationPage extends StatelessWidget {
  VisualRepresentationPage({super.key});

  final DashboardController controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    final data = controller.monthSummary;
    final income = data["income"] ?? 0.0;
    final expense = data["expense"] ?? 0.0;
    final remaining = income - expense;

    final summaryCards = [
      _SummaryCard(
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.blueAccent,
        label: "Remaining".tr,
        amount: remaining,
        isTablet: tablet,
      ),
      _SummaryCard(
        icon: Icons.trending_down_rounded,
        color: Colors.red,
        label: "Expense".tr,
        amount: expense,
        isTablet: tablet,
      ),
      _SummaryCard(
        icon: Icons.today_rounded,
        color: Colors.blueGrey,
        label: "Daily Limit".tr,
        amount: (remaining > 0 ? remaining : 0) / controller.daysLeftInCurrentMonth(),
        isTablet: tablet,
      ),
      _SummaryCard(
        icon: Icons.trending_up_outlined,
        color: Colors.green,
        label: "Income".tr,
        amount: income,
        isTablet: tablet,
      ),
      GestureDetector(
        onTap: () => Get.toNamed(routes.saving_screen),
        child: _SummaryCard(
          icon: Icons.savings_outlined,
          color: Colors.cyan,
          label: "Saving".tr,
          amount: controller.totalSavingAllTime.value,
          isTablet: tablet,
        ),
      ),
    ];

    return background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Visual Representation".tr,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: tablet ? 16.0 : 20.sp,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          titleSpacing: -10,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: tablet ? 60.0 : 100.h),
          child: tablet
              // ── Tablet: center constrained layout ───────────────────────
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // 3-column wrap grid for summary cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LayoutBuilder(
                            builder: (ctx, constraints) {
                              final cardW = (constraints.maxWidth - 2 * 12) / 3;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: summaryCards.map((card) =>
                                  SizedBox(width: cardW, child: card),
                                ).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _sectionHeader("Expense Calendar".tr, tablet: true),
                        _GlassCalendar(controller: controller, isTablet: true),
                        _sectionHeader("Category Breakdown".tr, tablet: true),
                        const SizedBox(height: 10),
                        const CategoryPieChart(),
                      ],
                    ),
                  ),
                )
              // ── Phone: original layout ────────────────────────────────
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          summaryCards[0],
                          SizedBox(width: 12.w),
                          summaryCards[1],
                          SizedBox(width: 12.w),
                          summaryCards[2],
                          SizedBox(width: 12.w),
                          summaryCards[3],
                          SizedBox(width: 12.w),
                          summaryCards[4],
                        ],
                      ),
                    ),
                    _sectionHeader("Expense Calendar".tr),
                    _GlassCalendar(controller: controller),
                    _sectionHeader("Category Breakdown".tr),
                    const SizedBox(height: 10),
                    const CategoryPieChart(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {bool tablet = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 20.0 : 18.w,
        vertical: tablet ? 6.0 : 4.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: tablet ? 14.0 : 16.sp,
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
    final tablet = _isTablet(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
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
        borderRadius: BorderRadius.circular(tablet ? 16.0 : 20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? EdgeInsets.all(tablet ? 14.0 : 16.r),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassCalendar extends StatelessWidget {
  final DashboardController controller;
  final bool isTablet;
  const _GlassCalendar({required this.controller, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return _GlassCard(
      margin: EdgeInsets.symmetric(
        horizontal: tablet ? 20.0 : 16.w,
        vertical: tablet ? 6.0 : 8.h,
      ),
      padding: EdgeInsets.all(tablet ? 14.0 : 16.r),
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
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.black54,
                    size: tablet ? 22.0 : 24.sp,
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(selMonth),
                  style: TextStyle(
                    fontSize: tablet ? 15.0 : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.changeMonth(1),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black54,
                    size: tablet ? 22.0 : 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: tablet ? 6.0 : 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d.tr,
                            style: TextStyle(
                              fontSize: tablet ? 11.0 : 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: tablet ? 6.0 : 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: tablet ? 6.0 : 8,
                crossAxisSpacing: tablet ? 6.0 : 8,
                childAspectRatio: tablet ? 1.6 : 1.0,
              ),
              itemCount: daysInMonth + firstWeekday,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox.shrink();

                final day = index - firstWeekday + 1;
                final amount = dailyExp[day] ?? 0.0;
                final now = DateTime.now();
                final isToday = now.day == day &&
                    now.month == selMonth.month &&
                    now.year == selMonth.year;

                Color borderColor = Colors.transparent;
                if (amount > 0) {
                  if (amount == maxExp) {
                    borderColor = Colors.red;
                  } else if (lowest3.contains(amount)) {
                    final rank = lowest3.indexOf(amount);
                    borderColor = Color.lerp(Colors.green.shade100,
                        Colors.green.shade600, (rank + 1) / 3)!;
                  } else {
                    borderColor = Color.lerp(Colors.orange.shade200,
                        Colors.orange.shade800, amount / maxExp)!;
                  }
                }

                return InkWell(
                  onTap: amount > 0
                      ? () => _showDayAmountDialog(context, day, selMonth, amount)
                      : null,
                  borderRadius: BorderRadius.circular(tablet ? 8.0 : 10.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(tablet ? 8.0 : 10.r),
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
                          fontSize: tablet ? 12.0 : 13.sp,
                          fontWeight: isToday || amount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? AppColors.primary
                              : amount > 0
                                  ? Colors.black87
                                  : Colors.black45,
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

  void _showDayAmountDialog(
      BuildContext context, int day, DateTime month, double amount) {
    final tablet = _isTablet(context);
    final dateStr = numberTranslation.formatDateBnFromString(
        DateFormat('dd MMMM yyyy')
            .format(DateTime(month.year, month.month, day)));

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withAlpha(217),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tablet ? 16.0 : 24.r)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: EdgeInsets.all(tablet ? 24.0 : 24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Daily Expense".tr,
                    style: TextStyle(
                        fontSize: tablet ? 14.0 : 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54),
                  ),
                  SizedBox(height: tablet ? 8.0 : 8.h),
                  Text(
                    dateStr,
                    style: TextStyle(
                        fontSize: tablet ? 18.0 : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: tablet ? 20.0 : 20.h),
                  Container(
                    padding: tablet 
                        ? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)
                        : EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(tablet ? 12.0 : 16.r),
                      border: Border.all(color: AppColors.primary.withAlpha(51)),
                    ),
                    child: Text(
                      "৳ ${numberTranslation.toBnDigits(amount.toStringAsFixed(0))}",
                      style: TextStyle(
                          fontSize: tablet ? 32.0 : 32.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary),
                    ),
                  ),
                  SizedBox(height: tablet ? 24.0 : 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text("Close".tr,
                          style: TextStyle(
                              color: Colors.black54, 
                              fontSize: tablet ? 14.0 : null)),
                    ),
                  ),
                ],
              ),
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
  final bool isTablet;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return _GlassCard(
      padding: EdgeInsets.all(tablet ? 12.0 : 15.r),
      borderColor: color.withAlpha(102),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(tablet ? 8.0 : 10.r),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: tablet ? 20.0 : 28.sp, color: color),
          ),
          SizedBox(height: tablet ? 10.0 : 16.h),
          Text(
            label,
            style: TextStyle(
              fontSize: tablet ? 12.0 : 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: tablet ? 2.0 : 4.h),
          Text(
            "৳${numberTranslation.toBnDigits(amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1))}",
            style: TextStyle(
              fontSize: tablet ? 15.0 : 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
