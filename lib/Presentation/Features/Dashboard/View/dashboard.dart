import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sadid/Core/numberTranslation.dart';
import '../../../../App/AppColors.dart';
import '../../../../App/routes.dart';
import '../../Transcations/Model/tranModel.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Returns true if the current device is a tablet / iPad
bool _isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}

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
    final isTab = _isTablet(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Dashboard".tr,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isTab ? 18.0 : 20.sp,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(routes.visual_representation_screen),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedChartBubble01,
              color: Colors.black,
              size: isTab ? 22.0 : 24.sp,
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(routes.addTranscations_screen),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAddCircle,
              color: Colors.black,
              size: isTab ? 22.0 : 24.sp,
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

        return Builder(
          builder: (context) {
            final tablet = _isTablet(context);
            final hPad = tablet ? 24.0 : 16.w;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 115.h),
              child: tablet
                  // ── iPad layout: two-column grid ──────────────────────────
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: hPad,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NewHeader(
                            controller: controller,
                            expense: expense,
                            highestSpendCategory: highestSpendCategory,
                            isTablet: true,
                          ),
                          const SizedBox(height: 20),
                          _BudgetsSection(
                            controller: controller,
                            isTablet: true,
                          ),
                          const SizedBox(height: 15),
                          if (controller.todayTransactions.isNotEmpty) ...[
                            _sectionHeader(
                              "Today Transactions".tr,
                              isTablet: true,
                            ),
                            const SizedBox(height: 8),
                            // Tablet: 2-column grid with fixed item height
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  (controller.todayTransactions.length / 2)
                                      .ceil(),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, rowIdx) {
                                final left =
                                    controller.todayTransactions[rowIdx * 2];
                                final hasRight =
                                    (rowIdx * 2 + 1) <
                                    controller.todayTransactions.length;
                                final right = hasRight
                                    ? controller.todayTransactions[rowIdx * 2 +
                                          1]
                                    : null;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _TransactionTile(
                                        item: left,
                                        onDelete: () =>
                                            controller.deleteTransaction(left),
                                        isTablet: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: right != null
                                          ? _TransactionTile(
                                              item: right,
                                              onDelete: () => controller
                                                  .deleteTransaction(right),
                                              isTablet: true,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    )
                  // ── Phone layout: original single-column ─────────────────
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: _NewHeader(
                            controller: controller,
                            expense: expense,
                            highestSpendCategory: highestSpendCategory,
                          ),
                        ),
                        _BudgetsSection(controller: controller),
                        SizedBox(height: 15.h),
                        if (controller.todayTransactions.isNotEmpty) ...[
                          _sectionHeader("Today Transactions".tr),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Column(
                              children: [
                                ...controller.todayTransactions.map(
                                  (t) => Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: _TransactionTile(
                                      item: t,
                                      onDelete: () =>
                                          controller.deleteTransaction(t),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
            );
          },
        );
      }),
    );
  }

  Widget _sectionHeader(String title, {bool isTablet = false}) {
    final tablet = isTablet || _isTablet(Get.context!);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 0 : 18.w,
        vertical: tablet ? 4 : 4.h,
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

class _BudgetsSection extends StatelessWidget {
  final DashboardController controller;
  final bool isTablet;
  const _BudgetsSection({required this.controller, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return Obx(() {
      if (controller.budgets.isEmpty) {
        return const SizedBox.shrink();
      }

      final totalBudget = controller.totalBudget.value;
      final totalSpent = controller.totalSpent.value;

      // On tablet, show a wrap grid instead of a horizontal list
      if (tablet) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalBudgetCard(totalBudget: totalBudget, totalSpent: totalSpent),
            if (controller.budgets.length > 1 ||
                (controller.budgets.length == 1 &&
                    controller.budgets.first.groupName != "Total")) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.budgets.map((budget) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
                    child: _BudgetCategoryCard(
                      name: budget.groupName.tr,
                      spent: budget.spent,
                      total: budget.budget,
                      isTablet: true,
                      controller: controller,
                      rawName: budget.groupName,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _TotalBudgetCard(
              totalBudget: totalBudget,
              totalSpent: totalSpent,
            ),
          ),
          if (controller.budgets.length > 1 ||
              (controller.budgets.length == 1 &&
                  controller.budgets.first.groupName != "Total"))
            SizedBox(height: 16.h),
          SizedBox(
            height: 90.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.budgets.length,
              itemBuilder: (context, index) {
                final budget = controller.budgets[index];
                return _BudgetCategoryCard(
                  name: budget.groupName.tr,
                  spent: budget.spent,
                  total: budget.budget,
                  controller: controller,
                  rawName: budget.groupName,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _TotalBudgetCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;

  const _TotalBudgetCard({required this.totalBudget, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    // suppress unused variable warnings from commented-out code
    final _ = totalBudget - totalSpent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monthly Budget".tr,
          style: TextStyle(
            fontSize: tablet ? 14.0 : 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  final String name;
  final double spent;
  final double total;
  final bool isTablet;
  final DashboardController? controller;
  final String? rawName;

  const _BudgetCategoryCard({
    required this.name,
    required this.spent,
    required this.total,
    this.isTablet = false,
    this.controller,
    this.rawName,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final percentage = total > 0 ? (spent / total) : 0.0;
    final color = percentage > 1.0
        ? Colors.red
        : (percentage >= 0.8 ? Colors.orange : AppColors.primary);

    final double nameFontSize = tablet ? 15 : 14.sp;
    final double totalFontSize = tablet ? 13 : 14.sp;
    final double spentFontSize = tablet ? 16 : 15.sp;
    final double pctFontSize = tablet ? 12 : 11.sp;
    final double cardPadding = tablet ? 10 : 10.r;
    final double cardRadius = tablet ? 16 : 16.r;

    return GestureDetector(
      onLongPress: () {
        if (controller != null && rawName != null) {
          _showBudgetTransactionsDialog(
            context,
            rawName!,
            name,
            color,
            controller!,
          );
        }
      },
      child: Container(
        width: tablet ? null : 140.w,
        height: tablet ? null : null,
        margin: EdgeInsets.only(right: tablet ? 0 : 12.w),
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: nameFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: tablet ? 4 : 0),
            if (!tablet) const Spacer(),
            Text(
              "৳${numberTranslation.toBnDigits(total.toStringAsFixed(0))}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: totalFontSize, color: Colors.black45),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "৳${numberTranslation.toBnDigits(spent.toStringAsFixed(0))}",
                    style: TextStyle(
                      fontSize: spentFontSize,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: tablet ? 4 : 4.w,
                      bottom: tablet ? 1 : 1.h,
                    ),
                    child: Text(
                      "(${(percentage * 100).toStringAsFixed(0)}%)",
                      style: TextStyle(
                        fontSize: pctFontSize,
                        color: color.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
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
  }
}

void _showBudgetTransactionsDialog(
  BuildContext context,
  String rawCategory,
  String displayName,
  Color color,
  DashboardController controller,
) {
  final tablet = _isTablet(context);
  final transactions = controller.allMonthTransactions
      .where((tx) => tx.category == rawCategory && tx.type == 'Expense')
      .toList();

  Get.dialog(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: tablet ? 160 : 16,
          vertical: 24,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${transactions.length} ${'transactions'.tr}",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${'Spent'.tr}",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "৳${numberTranslation.toBnDigits(transactions.fold(0.0, (s, t) => s + t.amount).toStringAsFixed(0))}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Transaction List
              if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No transactions found".tr,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 60,
                      color: Colors.grey.shade100,
                    ),
                    itemBuilder: (context, i) {
                      final tx = transactions[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: color,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          tx.note.isEmpty ? displayName : tx.note,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM, hh:mm a').format(tx.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        trailing: Text(
                          "৳${numberTranslation.toBnDigits(tx.amount.toStringAsFixed(0))}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Close".tr,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NewHeader extends StatelessWidget {
  final DashboardController controller;
  final double expense;
  final String highestSpendCategory;
  final bool isTablet;

  const _NewHeader({
    required this.controller,
    required this.expense,
    required this.highestSpendCategory,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final labelFontSize = tablet ? 16.0 : 16.sp;
    final amountFontSize = tablet ? 30.0 : 32.sp;
    final chartHeight = tablet ? 200.0 : 150.h;
    final infoIconSize = tablet ? 24.0 : 24.sp;
    final cardPad = tablet ? 20.0 : 16.r;
    final gap = tablet ? 16.0 : 16.h;

    if (tablet) {
      // iPad: chart on left, info cards on right side-by-side
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: total + chart
              Expanded(
                flex: 3,
                child: _GlassCard(
                  padding: EdgeInsets.all(cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total spent".tr,
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "৳${numberTranslation.toBnDigits(expense.toStringAsFixed(0))}",
                        style: TextStyle(
                          fontSize: amountFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: chartHeight,
                        child: _WeeklyChart(
                          controller: controller,
                          isTablet: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right: Today & Highest stacked — IntrinsicHeight keeps both cards same height
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoCard(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendarLove01,
                        size: 28,
                        color: AppColors.primary,
                      ),
                      label: "Today spend".tr,
                      value:
                          "৳${numberTranslation.toBnDigits(controller.todayExpense.value.toStringAsFixed(0))}",
                      isTablet: true,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      label: "Highest spend".tr,
                      value: highestSpendCategory.tr,
                      isTablet: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Phone layout
    return Column(
      children: [
        _GlassCard(
          padding: EdgeInsets.all(cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total spent".tr,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "৳${numberTranslation.toBnDigits(expense.toStringAsFixed(0))}",
                style: TextStyle(
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: chartHeight,
                child: _WeeklyChart(controller: controller),
              ),
            ],
          ),
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendarLove01,
                  size: infoIconSize,
                  color: AppColors.primary,
                ),
                label: "Today spend".tr,
                value:
                    "৳${numberTranslation.toBnDigits(controller.todayExpense.value.toStringAsFixed(0))}",
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _InfoCard(
                icon: Icon(
                  Icons.local_fire_department_outlined,
                  color: Colors.redAccent,
                  size: infoIconSize,
                ),
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
  final bool isTablet;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);

    // On tablet use fixed logical pixel sizes — NOT ScreenUtil scaled
    final double pad = tablet ? 16.0 : 16.r;
    final double gap1 = tablet ? 10.0 : 8.h;
    final double gap2 = tablet ? 6.0 : 4.h;
    final double lFSize = tablet ? 15.0 : 14.sp;
    final double vFSize = tablet ? 20.0 : 18.sp;

    return _GlassCard(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: gap1),
          Text(
            label,
            style: TextStyle(fontSize: lFSize, color: Colors.black54),
          ),
          SizedBox(height: gap2),
          Text(
            value,
            style: TextStyle(
              fontSize: vFSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
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
  final bool isTablet;
  const _WeeklyChart({required this.controller, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final amounts = controller.weeklyAmounts;
    if (amounts.isEmpty) return const SizedBox.shrink();

    final maxVal = amounts.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal == 0 ? 100.0 : maxVal * 1.3;

    // Clamp bar width: on iPad 35.w becomes absurdly wide; cap it
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = tablet
        ? (screenWidth * 0.3 / amounts.length).clamp(16.0, 36.0)
        : 35.w.clamp(10.0, 40.0);
    final labelFontSize = tablet ? 13.0 : 12.sp;

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
                  fontSize: labelFontSize,
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
                if (index < 0 || index >= controller.labels.length)
                  return const SizedBox.shrink();
                final today = DateFormat('EEE').format(DateTime.now());
                final isToday = controller.labels[index] == today;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    controller.labels[index][0],
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: isToday ? Colors.red.shade300 : Colors.black54,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
                width: barWidth,
                borderRadius: BorderRadius.circular(tablet ? 6 : 6.r),
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
  const _TransactionTile({
    required this.item,
    required this.onDelete,
    this.isTablet = false,
  });
  final TranItem item;
  final Future<void> Function() onDelete;
  final bool isTablet;

  Color _typeColor(String type) {
    if (type == "Expense") return Colors.red;
    if (type == "Income") return Colors.green;
    if (type == "Saving") return Colors.blue;
    if (type == "Lent") return Colors.orange;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final typeColor = _typeColor(item.type);

    // Compact sizes for tablet grid cells
    final double avatarSize = tablet ? 32.0 : 44.r;
    final double avatarFont = tablet ? 13.0 : 18.sp;
    final double hGap = tablet ? 8.0 : 14.w;
    final double catFont = tablet ? 13.0 : 15.sp;
    final double walletFont = tablet ? 11.0 : 12.sp;
    final double amtFont = tablet ? 13.0 : 15.sp;
    final double dateFont = tablet ? 9.0 : 10.sp;
    final double cardPad = tablet ? 8.0 : 12.r;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildActionBg(
        HugeIcons.strokeRoundedEdit02,
        "Edit".tr,
        Colors.blue,
        Alignment.centerLeft,
      ),
      secondaryBackground: _buildActionBg(
        HugeIcons.strokeRoundedDelete04,
        "Delete".tr,
        Colors.red,
        Alignment.centerRight,
      ),
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
          padding: EdgeInsets.all(cardPad),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: typeColor.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: avatarFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: hGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.category.isEmpty
                          ? "Uncategorized".tr
                          : item.category.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: catFont,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.wallet.tr,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: walletFont,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: amtFont,
                      color: typeColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    tablet
                        ? DateFormat('dd MMM').format(item.date)
                        : "${numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date))}, ${numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date))}",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: dateFont,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(width: tablet ? 8.0 : 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBg(
    dynamic icon,
    String text,
    Color color,
    Alignment alignment,
  ) {
    final tablet = isTablet;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tablet ? 16.0 : 20.w),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(tablet ? 14.0 : 14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                HugeIcon(icon: icon, color: color, size: tablet ? 18.0 : 22.sp),
                SizedBox(width: tablet ? 6.0 : 8.w),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: tablet ? 12.0 : null,
                  ),
                ),
              ]
            : [
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: tablet ? 12.0 : null,
                  ),
                ),
                SizedBox(width: tablet ? 6.0 : 8.w),
                HugeIcon(icon: icon, color: color, size: tablet ? 18.0 : 22.sp),
              ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext ctx) {
              return CupertinoAlertDialog(
                title: Text("Delete Transaction".tr),
                content: Text(
                  "Are you sure you want to delete this transaction?".tr,
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text("Cancel".tr),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text("Delete".tr),
                  ),
                ],
              );
            },
          ) ??
          false;
    } else {
      final result =
          await Get.dialog<bool>(
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: Colors.white,
                title: Text("Delete Transaction".tr),
                content: Text(
                  "Are you sure you want to delete this transaction?".tr,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      "Cancel".tr,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(
                      "Delete".tr,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ) ??
          false;
      return result;
    }
  }

  void _showDetailsDialog(BuildContext context) {
    final dateText = numberTranslation.formatDateBnFromString(
      DateFormat('dd MMM yyyy').format(item.date),
    );
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: typeColor,
                      ),
                    ),
                    if (item.marked)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24.sp,
                      ),
                  ],
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: "Category:".tr,
                  value: item.category.isEmpty
                      ? "Uncategorized".tr
                      : item.category.tr,
                ),
                _DetailRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Wallet:".tr,
                  value: item.wallet.tr,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: "Date:".tr,
                  value: dateText,
                ),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: "Remark:".tr,
                  value: item.note.isEmpty ? "No Remark".tr : item.note,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Close".tr,
                      style: const TextStyle(color: Colors.black54),
                    ),
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
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.black54),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
