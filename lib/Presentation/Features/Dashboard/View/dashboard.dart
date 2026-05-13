import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../../../App/AppColors.dart';
import '../../../../App/routes.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart'; // Added for CupertinoAlertDialog
import 'package:flutter/foundation.dart'; // Added for defaultTargetPlatform

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});
  final DashboardController controller = Get.put(DashboardController());

  String getHighestSpendCategory() {
    if (controller.categorySummary.isEmpty) {
      return "N/A".tr;
    }
    final sortedCategories = controller.categorySummary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedCategories.first.key;
  }

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
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () => Get.toNamed(routes.visual_representation_screen),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedChartBubble01,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () => Get.toNamed(routes.addTranscations_screen),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedAddCircle,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final data = controller.monthSummary;
        final expense = data["expense"] ?? 0.0;
        final highestSpendCategory = getHighestSpendCategory();

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 115.h), // Adjusted padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: _NewHeader(
                  controller: controller,
                  expense: expense,
                  highestSpendCategory: highestSpendCategory,
                ),
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

class _NewHeader extends StatelessWidget {
  final DashboardController controller;
  final double expense;
  final String highestSpendCategory;

  const _NewHeader({
    required this.controller,
    required this.expense,
    required this.highestSpendCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlassCard(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total spent".tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "৳${numberTranslation.toBnDigits(expense.toStringAsFixed(0))}",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 150.h,
                child: _WeeklyChart(controller: controller),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendarLove01,
                  size: 24.sp,
                  color: AppColors.primary,
                ),
                label: "Today spend".tr,
                value: "৳${numberTranslation.toBnDigits(controller.todayExpense.value.toStringAsFixed(0))}",
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _InfoCard(
                icon: Icon(Icons.local_fire_department_outlined, color: Colors.redAccent, size: 24.sp),
                label: "Highest spend".tr,
                value: highestSpendCategory.tr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

class _WeeklyChart extends StatelessWidget {
  final DashboardController controller;
  const _WeeklyChart({required this.controller});

  @override
  Widget build(BuildContext context) {
    final amounts = controller.weeklyAmounts;
    if (amounts.isEmpty) return const SizedBox.shrink();

    final maxVal = amounts.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.3;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '৳${numberTranslation.toBnDigits(rod.toY.toStringAsFixed(0))}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= controller.labels.length) return const SizedBox.shrink();
                final today = DateFormat('EEE').format(DateTime.now());
                final isToday = controller.labels[index] == today;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.labels[index][0], // Use first letter for 'M', 'T', 'W' etc.
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: isToday ? Colors.red.shade300 : Colors.black54,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal),
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
          final today = DateFormat('EEE').format(DateTime.now());
          final isToday = controller.labels[i] == today;

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: amount,
                color: isToday ? Colors.red.shade300 : Colors.black87,
                width: 35.w,
                borderRadius: BorderRadius.circular(6.r),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: Colors.grey.shade200,
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
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
                  color: typeColor.withAlpha(26),
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
                    "${numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date))}, ${numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date))}",
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
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await Get.dialog<bool>(
        CupertinoAlertDialog(
          title: Text("Delete Transaction".tr),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("Are you sure you want to delete this transaction?".tr),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(result: false),
              child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54)),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Get.back(result: true),
              child: Text("Delete".tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        barrierDismissible: false,
      ) ?? false;
    } else { // Android and other platforms
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
          backgroundColor: Colors.white.withAlpha(217),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: typeColor.withAlpha(38)),
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
