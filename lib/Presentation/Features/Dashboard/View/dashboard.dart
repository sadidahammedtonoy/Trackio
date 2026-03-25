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

class dashboardPage extends StatelessWidget {
  dashboardPage({super.key});
  final dashboardController controller = Get.find<dashboardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard".tr), centerTitle: false),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        spacing: 18,
                        children: [
                          _SummaryCard(
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.blueAccent,
                            label: "Remaining".tr,
                            amount: remaining,
                          ),
                          _SummaryCard(
                            icon: Icons.receipt_long_outlined,
                            color: Colors.orange,
                            label: "Today Expense".tr,
                            amount: controller.todayExpense.value,
                          ),
                          _SummaryCard(
                            icon: Icons.trending_down,
                            color: Colors.red,
                            label: "Expense".tr,
                            amount: expense,
                          ),
                          _SummaryCard(
                            icon: Icons.today,
                            color: Colors.blueGrey,
                            label: "Daily Limit".tr,
                            amount: remaining / controller.daysLeftInCurrentMonth(),
                          ),
                          _SummaryCard(
                            icon: Icons.trending_up_outlined,
                            color: Colors.green,
                            label: "Income".tr,
                            amount: income,
                          ),
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
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Weekly Overview".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
                _WeeklyChart(controller: controller),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    "Category Breakdown".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CategoryPieChart(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(routes.addTranscations_screen),
                    child: Text(
                      "Today Transactions".tr,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: Column(
                    children: [
                      if (controller.todayTransactions.isEmpty)
                        Center(child: Text("No transactions today".tr))
                      else
                        ...controller.todayTransactions.map(
                          (t) => _TransactionTile(
                            item: t,
                            onDelete: () => controller.deleteTransaction(t),
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            offset: const Offset(4, 1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(150),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 20, width: 110),
          Text(label, style: TextStyle(fontSize: 16.sp)),
          Text(
            "৳${numberTranslation.toBnDigits(amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1))}",
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w500),
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
    
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b) + 1;
    
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.cyan,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final amount = controller.weeklyAmounts[group.x.toInt()];
                return BarTooltipItem(
                  '৳${numberTranslation.toBnDigits(amount.toStringAsFixed(0))}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  if (index < 0 || index >= controller.labels.length) return const SizedBox();
                  return Text(
                    controller.labels[index].tr,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
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
                  color: amount == 0 ? Colors.redAccent : Colors.cyan.withOpacity(0.7),
                  width: 18,
                  borderRadius: BorderRadius.circular(50),
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
    final dateText = numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
    final typeColor = _typeColor(item.type);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [const Icon(Icons.edit, color: Colors.blue), const SizedBox(width: 8), Text("Edit".tr, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w700))]),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(editTransactions(model: item));
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDeleteTransactionDialog();
          if (!confirm) return false;
          await onDelete();
          return true;
        }
        return false;
      },
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, 
          children: [
            Text("Delete".tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700)), 
            const SizedBox(width: 8), 
            const Icon(Icons.delete, color: Colors.red)
          ]
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onLongPress: () {
            _showDetailsDialog(context);
          },
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(color: typeColor.withOpacity(0.5), shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: typeColor.withOpacity(0.08), blurRadius: 15, spreadRadius: 1, offset: const Offset(4, 1))]),
                    child: Text(item.type.isNotEmpty ? item.type[0].toUpperCase() : '?', style: TextStyle(color: typeColor, fontSize: 20.sp, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 5,
                      children: [
                        Text(item.category.isEmpty ? "Uncategorized".tr : item.category.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (item.marked) const Icon(Icons.check_circle, color: Colors.green, size: 15),
                      ],
                    ),
                    Text(item.wallet.tr, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}", style: TextStyle(fontWeight: FontWeight.w800, color: typeColor)),
                  Text(dateText, style: const TextStyle(color: Colors.black54, fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    final typeColor = _typeColor(item.type);
    final dateText = numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 5,
                children: [
                  Text(
                    item.type.tr,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.sp, color: typeColor),
                  ),
                  Text(
                    "Transaction".tr,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22.sp, color: Colors.black),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                  style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w800, color: Colors.black),
                ),
              ),
              const Divider(),
              item.type == "Lent" || item.type == "Borrow"
                  ? Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.person, color: Colors.black, size: 15),
                        Text("Person Name:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        Text(item.category, style: TextStyle(fontSize: 16.sp)),
                      ],
                    )
                  : Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.category, color: Colors.black, size: 15),
                        Text("Category:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        Text(item.category.isEmpty ? "Uncategorized".tr : item.category.tr, style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
              Row(
                spacing: 5,
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.black, size: 15),
                  Text("Wallet:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  Text(item.wallet.tr, style: TextStyle(fontSize: 16.sp)),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  const Icon(Icons.date_range_rounded, color: Colors.black, size: 15),
                  Text("Date:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  Text(dateText, style: TextStyle(fontSize: 16.sp)),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  const Icon(Icons.edit_note_outlined, color: Colors.black, size: 15),
                  Text("Remark:".tr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  Expanded(
                    child: Text(item.note.isEmpty ? "No Remark".tr : item.note, style: TextStyle(fontSize: 16.sp)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text("Close".tr, style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showDeleteTransactionDialog() async {
  if (GetPlatform.isIOS) {
    final result = await Get.dialog<bool>(
      CupertinoAlertDialog(
        title: Text("Delete Transaction".tr),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("Are you sure you want to delete this transaction?".tr),
        ),
        actions: [
          CupertinoDialogAction(onPressed: () => Get.back(result: false), child: Text("Cancel".tr)),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () => Get.back(result: true), child: Text("Delete".tr)),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  } else {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Delete Transaction".tr),
        content: Text("Are you sure you want to delete this transaction?".tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel".tr)),
          TextButton(onPressed: () => Get.back(result: true), child: Text("Delete".tr, style: const TextStyle(color: Colors.red))),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}
