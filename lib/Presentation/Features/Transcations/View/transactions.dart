import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sadid/App/AppColors.dart';
import 'package:sadid/App/routes.dart';
import '../../../../Core/numberTranslation.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../../../../App/assets_path.dart';
import '../../../Share/GlassWidgets.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import '../Model/tranModel.dart';
import '../Controller/ExportController.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class transcations_page extends StatelessWidget {
  final controller = Get.put(transactionsController());
  final exportController = Get.put(ExportController());

  transcations_page({super.key});

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  double _sectionTotal(List<TranItem> list) {
    return list.fold(0.0, (sum, t) {
      if (t.type == "Lent" || t.type == "Borrow") {
        return sum;
      }

      if (t.type == "Expense") {
        return sum - t.amount;
      }

      return sum + t.amount;
    });
  }

  Map<DateTime, List<TranItem>> _groupByDate(List<TranItem> items) {
    final map = <DateTime, List<TranItem>>{};
    for (final t in items) {
      final key = _dayKey(t.date);
      map.putIfAbsent(key, () => <TranItem>[]).add(t);
    }
    return map;
  }

  Map<String, double> _calculateCategoryTotals(List<TranItem> items) {
    final totals = <String, double>{};
    for (final t in items) {
      String key;
      if (t.type == "Lent" || t.type == "Borrow") {
        key = t.type;
      } else {
        key = t.category.isEmpty ? "Uncategorized" : t.category;
      }
      totals[key] = (totals[key] ?? 0.0) + t.amount;
    }
    return totals;
  }

  Widget _buildSummary(List<TranItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    final totals = _calculateCategoryTotals(items);

    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 12.h, top: 12.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: totals.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final entry = totals.entries.elementAt(index);
          return Obx(() {
            final isSelected = controller.selectedCategoryFilter.value == entry.key;
            return GlassChip(
              isSelected: isSelected,
              label: "${entry.key.tr}: ৳${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}",
              onTap: () => controller.toggleCategoryFilter(entry.key),
            );
          });
        },      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.setMonthFromDate(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Obx(() {
          final selected = controller.selectedMonthKey.value;
          final title = selected == null
              ? "All Transactions".tr
              : numberTranslation.formatMonthYearBnFromKey(selected);

          return Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          );
        }),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedPdf01, color: AppColors.primary, size: 24.sp),
            onPressed: () {
              final monthKey = controller.selectedMonthKey.value ?? "All";
              exportController.generatePDFReport(controller.filteredItems, monthKey);
            },
          ),
          Obx(() => IconButton(
                icon: controller.isSearchVisible.value
                    ? const Icon(Icons.close, color: Colors.black)
                    : HugeIcon(icon: HugeIcons.strokeRoundedSearch02, color: Colors.black, size: 24.sp),
                onPressed: () => controller.toggleSearch(),
              )),
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSortByDown01, color: Colors.black, size: 24.sp),
            onPressed: () => _showMonthFilterSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                if (controller.isSearchVisible.value)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: GlassTextField(
                      controller: TextEditingController(text: controller.searchQuery.value)
                        ..selection = TextSelection.fromPosition(TextPosition(offset: controller.searchQuery.value.length)),
                      label: "Search".tr,
                      hint: "Category, remark, wallet or amount...".tr,
                      icon: Icons.search_rounded,
                      onChanged: (val) => controller.setSearchQuery(val),
                    ),
                  ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final items = controller.filteredItems;

                      if (items.isEmpty && controller.searchQuery.isEmpty && controller.selectedCategoryFilter.value == null) {
                        return Center(child: Text("No transactions yet".tr));
                      }

                      if (items.isEmpty) {
                        return Center(child: Text("No results found".tr));
                      }

                      final isMonthSelected = controller.selectedMonthKey.value != null;
                      final grouped = _groupByDate(items);
                      final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                      return Column(
                        children: [
                          if (isMonthSelected) _buildSummary(controller.filteredItems), // Corrected here
                          Expanded(
                            child: ListView.separated(
                              controller: controller.scrollController,
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h), // Adjusted padding
                              itemCount: days.length,
                              separatorBuilder: (_, __) => SizedBox(height: 20.h),
                              itemBuilder: (context, dayIndex) {
                                final day = days[dayIndex];
                                final list = grouped[day]!;
                                final total = _sectionTotal(list);
                                final isPositive = total >= 0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _titleForDay(day),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            "${isPositive ? '+' : ''}${numberTranslation.toBnDigits(total.toStringAsFixed(0))}",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isPositive ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...list.map((t) => Padding(
                                          padding: EdgeInsets.only(bottom: 10.h),
                                          child: _TransactionTile(
                                            item: t,
                                            onDelete: () => controller.deleteTransaction(t),
                                          ),
                                        )),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            if (controller.showScrollToTop.value)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: controller.scrollToTop,
                    child: GlassCard(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      borderRadius: BorderRadius.circular(30.r),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 16.sp, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            "Scroll to top".tr,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  String _titleForDay(DateTime day) {
    final now = DateTime.now();
    if (_isSameDay(day, now)) return "Today".tr;
    if (_isSameDay(day, now.subtract(const Duration(days: 1)))) return "Yesterday".tr;
    return numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(day));
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
          final confirm = await _showDeleteDialog();
          if (!confirm) return false;
          await onDelete();
          return true;
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showDetailsDialog(context),
        child: GlassCard(
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

  Future<bool> _showDeleteDialog() async {
    final result = await Get.dialog<bool>(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text("Delete Transaction".tr),
          content: Text("Are you sure you want to delete this transaction?".tr),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: Text("Cancel".tr, style: const TextStyle(color: Colors.black54))),
            TextButton(onPressed: () => Get.back(result: true), child: Text("Delete".tr, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
    return result ?? false;
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

void _showMonthFilterSheet(BuildContext context) {
  final controller = Get.find<transactionsController>();
  final months = controller.getMonthKeys();

  Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(bottom: 30.h),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      "Filter by Month".tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Select a month to filter your transactions".tr,
                      style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1),
              SizedBox(height: 8.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MonthTile(
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedSortByDown01, size: 18.sp, color: Colors.black45),
                        label: "All Months".tr,
                        isSelected: controller.selectedMonthKey.value == null,
                        onTap: () {
                          controller.selectMonth(null);
                          Get.back();
                        },
                      ),
                      ...months.map((key) => _MonthTile(
                            icon: HugeIcon(icon: HugeIcons.strokeRoundedSortByDown01, size: 18.sp, color: Colors.black45),
                            label: numberTranslation.formatMonthYearBnFromKey(key),
                            isSelected: controller.selectedMonthKey.value == key,
                            onTap: () {
                              controller.selectMonth(key);
                              Get.back();
                            },
                          )),
                    ],
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

class _MonthTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [

              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkBadge03,
                  size: 20.sp,
                  color: AppColors.primary,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
