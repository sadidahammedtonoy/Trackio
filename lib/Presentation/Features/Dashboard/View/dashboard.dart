import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../../../App/AppColors.dart';
import '../../../../App/routes.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Widgets/monthlyExpenseCharts.dart';
import 'package:intl/intl.dart';
import '../../Budget/Controller/Controller.dart';

class dashboardPage extends StatelessWidget {
  dashboardPage({super.key});
  final dashboardController controller = Get.find<dashboardController>();
  final InsightsController insightsController = Get.put(InsightsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Dashboard".tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white.withOpacity(0.1),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final data = controller.thisMonthSummary;
        final income = data["income"] ?? 0.0;
        final expense = data["expense"] ?? 0.0;
        final savings = controller.thisMonthSavings.value;
        final remaining = income - expense - savings;

        return RefreshIndicator(
          onRefresh: () async {
            // Trigger sync when pulled down
            // Get.find<SyncService>().syncNow(); 
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                        icon: Icons.receipt_long_outlined,
                        color: Colors.orange,
                        label: "Today Expense".tr,
                        amount: controller.todayExpense.value,
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
                        amount: remaining / controller.daysLeftInCurrentMonth(),
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
                          amount: controller.totalSavingAllTime.value + controller.overallSavingOnly.value,
                        ),
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  final overBudget = insightsController.overBudgetCategories;
                  if (overBudget.isEmpty) return const SizedBox.shrink();
                  
                  return _BudgetWarningBanner(overBudget: overBudget);
                }),

                _sectionHeader("Weekly Overview".tr),
                _GlassCard(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.only(top: 20.h, bottom: 10.h, right: 16.w, left: 16.w),
                  child: _WeeklyChart(controller: controller),
                ),
                SizedBox(height: 15.h),
                _sectionHeader("Expense Calendar".tr),
                _GlassCalendar(controller: controller),
                _sectionHeader("Category Breakdown".tr),
                _GlassCard(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.all(12.r),
                  child: const CategoryPieChart(),
                ),
                SizedBox(height: 15.h),
                _sectionHeader("Today Transactions".tr),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Column(
                    children: [
                      if (controller.todayTransactions.isEmpty)
                        _GlassCard(
                          padding: EdgeInsets.all(20.r),
                          child: Center(child: Text("No transactions today".tr)),
                        )
                      else
                        ...controller.todayTransactions.map(
                          (t) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _TransactionTile(
                              item: t,
                              onDelete: () => controller.deleteTransaction(t),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
      borderColor: color.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

class _WeeklyChart extends StatelessWidget {
  final dashboardController controller;
  const _WeeklyChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final amounts = controller.weeklyAmounts;
    if (amounts.isEmpty) return const SizedBox.shrink();
    
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b) * 1.3 + 100;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxAmount,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  if (event is FlPanEndEvent || event is FlPanDownEvent || event is FlTapUpEvent || response == null || response.spot == null) {
                    controller.touchedValue.value = null;
                  } else {
                    final index = response.spot!.touchedBarGroupIndex;
                    if (index >= 0 && index < controller.weeklyAmounts.length) {
                      final amount = controller.weeklyAmounts[index];
                      controller.touchedValue.value = '৳${numberTranslation.toBnDigits(amount.toStringAsFixed(0))}';
                    }
                  }
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => null, // Correct: Disable default tooltip
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= controller.labels.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          controller.labels[index].tr,
                          style: TextStyle(fontSize: 10.sp, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(amounts.length, (i) {
                final amount = amounts[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: amount,
                      color: amount == 0 ? Colors.redAccent.withOpacity(0.5) : AppColors.primary,
                      width: 14.w,
                      borderRadius: BorderRadius.circular(6.r),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxAmount,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }),
            ),
            swapAnimationDuration: Duration.zero,
          ),
        ),
        Obx(() {
          if (controller.touchedValue.value == null) return const SizedBox.shrink();
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              controller.touchedValue.value!,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item, required this.onDelete});
  final TranItem item;
  final Future<void> Function() onDelete;

  Color _typeColor(String type) {
    if (type == "Expense") return Colors.red;
    if (type == "Income") return Colors.green;
    if (type == "Saving") return Colors.blue;
    if (type == "Lent") return Colors.orange;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(item.type);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildActionBg(Icons.edit, "Edit".tr, Colors.blue, Alignment.centerLeft),
      secondaryBackground: _buildActionBg(Icons.delete, "Delete".tr, Colors.red, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(editTransactions(model: item));
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          final confirm = await _showDeleteDialog(context);
          if (!confirm) return false;
          await onDelete();
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showDetailsDialog(context),
        child: _GlassCard(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.isEmpty ? "Uncategorized".tr : item.category.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.wallet.tr,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: typeColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date)) + 
                    ", " + 
                    numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date)),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 10.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBg(IconData icon, String text, Color color, Alignment alignment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [Icon(icon, color: color), SizedBox(width: 8.w), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))]
            : [Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)), SizedBox(width: 8.w), Icon(icon, color: color)],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    if (GetPlatform.isIOS) {
      return await Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text("Delete Transaction".tr),
          content: Text("Are you sure you want to delete this transaction?".tr),
          actions: [
            CupertinoDialogAction(onPressed: () => Get.back(result: false), child: Text("Cancel".tr)),
            CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Get.back(result: true), child: Text("Delete".tr)),
          ],
        ),
      ) ?? false;
    } else {
      return await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Delete Transaction".tr),
          content: Text("Are you sure you want to delete this transaction?".tr),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54))),
            TextButton(onPressed: () => Get.back(result: true), child: Text("Delete".tr, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ) ?? false;
    }
  }

  void _showDetailsDialog(BuildContext context) {
    final dateText = numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
    final typeColor = _typeColor(item.type);

    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: typeColor.withOpacity(0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${item.type.tr} Transaction".tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: typeColor),
                    ),
                    if (item.marked) Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                  ],
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
                const Divider(),
                _DetailRow(icon: Icons.category_outlined, label: "Category:".tr, value: item.category.isEmpty ? "Uncategorized".tr : item.category.tr),
                _DetailRow(icon: Icons.account_balance_wallet_outlined, label: "Wallet:".tr, value: item.wallet.tr),
                _DetailRow(icon: Icons.calendar_today_outlined, label: "Date:".tr, value: dateText),
                _DetailRow(icon: Icons.notes_outlined, label: "Remark:".tr, value: item.note.isEmpty ? "No Remark".tr : item.note),
                SizedBox(height: 20.h),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.black54),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(width: 6.w),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black87))),
        ],
      ),
    );
  }
}

class _GlassCalendar extends StatelessWidget {
  final dashboardController controller;
  const _GlassCalendar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      child: Obx(() {
        final selMonth = controller.selectedMonth.value;
        final dailyExp = controller.dailyExpenses;
        
        // Calendar logic
        final firstDayOfMonth = DateTime(selMonth.year, selMonth.month, 1);
        final lastDayOfMonth = DateTime(selMonth.year, selMonth.month + 1, 0);
        final daysInMonth = lastDayOfMonth.day;
        final firstWeekday = firstDayOfMonth.weekday % 7; // 0 for Sun, 1 for Mon...

        // Find max and lowest 3 for coloring
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
                    // Fade lowest to highest green
                    borderColor = Color.lerp(Colors.green.shade100, Colors.green.shade600, (rank + 1) / 3)!;
                  } else {
                    // Gradual color for others (Amber/Orange)
                    borderColor = Color.lerp(Colors.orange.shade200, Colors.orange.shade800, amount / maxExp)!;
                  }
                }

                return InkWell(
                  onTap: amount > 0 
                      ? () => _showDayAmountDialog(context, day, selMonth, amount)
                      : null,
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
                          ? AppColors.primary.withOpacity(0.1) 
                          : amount > 0 ? borderColor.withOpacity(0.05) : Colors.transparent,
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
    final dateStr = numberTranslation.formatDateBnFromString(DateFormat('dd MMMM yyyy').format(DateTime(month.year, month.month, day)));
    
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.85),
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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

class _BudgetWarningBanner extends StatelessWidget {
  final List<BudgetStatus> overBudget;
  const _BudgetWarningBanner({required this.overBudget});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      borderColor: Colors.red.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                "Budget Warning".tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...overBudget.map((s) => Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              "• ${s.category.tr}: ৳${numberTranslation.toBnDigits(s.spent.toStringAsFixed(0))} / ৳${numberTranslation.toBnDigits(s.limit.toStringAsFixed(0))}",
              style: TextStyle(fontSize: 13.sp, color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          )),
        ],
      ),
    );
  }
}
