import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../../App/AppColors.dart';
import '../../../../Core/numberTranslation.dart';
import '../../../Share/GlassWidgets.dart';
import '../../editTransactions/Controller/Controller.dart';
import '../../editTransactions/View/editTransactions.dart';
import '../Controller/Controller.dart';
import '../Model/tranModel.dart';

// --- Main Page Widget ---
class transcations_page extends StatelessWidget {
  transcations_page({super.key});

  final controller = Get.put(transactionsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Obx(() => Stack(
        children: [
          Column(
            children: [
              if (controller.isSearchVisible.value) _SearchBar(),
              Expanded(child: _TransactionList()),
            ],
          ),
          if (controller.showScrollToTop.value) _ScrollToTopButton(),
        ],
      )),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Obx(() {
        final selected = controller.selectedMonthKey.value;
        final title = selected == null ? "All Transactions".tr : numberTranslation.formatMonthYearBnFromKey(selected);
        return Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.sp));
      }),
      actions: [
        Obx(() => IconButton(
          icon: controller.isSearchVisible.value
              ? const Icon(Icons.close, color: Colors.black)
              : HugeIcon(icon: HugeIcons.strokeRoundedSearch02, color: Colors.black, size: 24.sp),
          onPressed: () => controller.toggleSearch(),
        )),
        IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedSortByDown01, color: Colors.black, size: 24.sp),
          onPressed: () => _showMonthFilterSheet(Get.context!),
        ),
      ],
    );
  }
}

// --- Body Components ---
class _TransactionList extends StatelessWidget {
  final transactionsController controller = Get.find();

  // Helper to group items by day for the list
  Map<DateTime, List<TranItem>> _groupByDate(List<TranItem> items) {
    final map = <DateTime, List<TranItem>>{};
    for (final item in items) {
      final dayKey = DateTime(item.date.year, item.date.month, item.date.day);
      map.putIfAbsent(dayKey, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.filteredItems;

      if (items.isEmpty) {
        // Show a message depending on why the list is empty
        final message = controller.searchQuery.isNotEmpty || controller.selectedCategoryFilter.value != null
            ? "No results found".tr
            : "No transactions yet".tr;
        return Center(child: Text(message));
      }

      final grouped = _groupByDate(items);
      final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      return Column(
        children: [
          // Show summary chips only when a month is selected
          if (controller.selectedMonthKey.value != null) _CategorySummary(items: items),
          Expanded(
            child: ListView.separated(
              controller: controller.scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              itemCount: sortedDays.length,
              separatorBuilder: (_, __) => SizedBox(height: 20.h),
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                final dayItems = grouped[day]!;
                return _DaySection(day: day, items: dayItems);
              },
            ),
          ),
        ],
      );
    });
  }
}

class _CategorySummary extends StatelessWidget {
  final List<TranItem> items;
  final transactionsController controller = Get.find();

  _CategorySummary({required this.items});

  // Helper to calculate totals for the summary chips
  Map<String, double> _calculateCategoryTotals() {
    final totals = <String, double>{};
    for (final t in items) {
      String key = (t.type == "Lent" || t.type == "Borrow") ? t.type : (t.category.isEmpty ? "Uncategorized" : t.category);
      totals[key] = (totals[key] ?? 0) + t.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final totals = _calculateCategoryTotals();

    return Container(
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: totals.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final entry = totals.entries.elementAt(index);
          return Obx(() => GlassChip(
            isSelected: controller.selectedCategoryFilter.value == entry.key,
            label: "${entry.key.tr}: ৳${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}",
            onTap: () => controller.toggleCategoryFilter(entry.key),
          ));
        },
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<TranItem> items;

  const _DaySection({required this.day, required this.items});

  String _titleForDay(DateTime day) {
    final now = DateTime.now();
    if (day.year == now.year && day.month == now.month && day.day == now.day) return "Today".tr;
    final yesterday = now.subtract(const Duration(days: 1));
    if (day.year == yesterday.year && day.month == yesterday.month && day.day == yesterday.day) return "Yesterday".tr;
    return numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(day));
  }

  double _sectionTotal(List<TranItem> list) {
    return list.fold(0.0, (sum, t) {
      if (t.type == "Lent" || t.type == "Borrow") return sum;
      return sum + (t.type == "Expense" ? -t.amount : t.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _sectionTotal(items);
    final isPositive = total >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_titleForDay(day), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black54)),
              Text(
                "${isPositive ? '+' : ''}${numberTranslation.toBnDigits(total.toStringAsFixed(0))}",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _TransactionTile(item: item),
        )),
      ],
    );
  }
}

// --- Reusable Widgets ---

class _SearchBar extends StatelessWidget {
  final transactionsController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GlassTextField(
        // Use a key to re-create the TextEditingController when the query changes externally
        key: Key(controller.searchQuery.value),
        controller: TextEditingController(text: controller.searchQuery.value)
          ..selection = TextSelection.fromPosition(TextPosition(offset: controller.searchQuery.value.length)),
        label: "Search".tr,
        hint: "Category, remark, wallet or amount...".tr,
        icon: Icons.search_rounded,
        onChanged: (val) => controller.searchQuery.value = val,
      ),
    );
  }
}

class _ScrollToTopButton extends StatelessWidget {
  final transactionsController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.h, left: 0, right: 0,
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
                Text("Scroll to top".tr, style: TextStyle(color: Colors.black87, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Transaction Tile & Dialogs ---

class _TransactionTile extends StatelessWidget {
  final TranItem item;
  final transactionsController controller = Get.find();

  _TransactionTile({required this.item});

  Color _typeColor(String type) {
    switch (type) {
      case "Expense": return Colors.red;
      case "Income": return Colors.green;
      case "Saving": return Colors.blue;
      case "Lent": return Colors.orange;
      default: return Colors.purple; // Borrow
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildActionBackground(HugeIcons.strokeRoundedEdit02, "Edit".tr, Colors.blue, Alignment.centerLeft),
      secondaryBackground: _buildActionBackground(HugeIcons.strokeRoundedDelete04, "Delete".tr, Colors.red, Alignment.centerRight),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) { // Edit
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(() => editTransactions(model: item));
          return false; // Don't dismiss
        }
        if (direction == DismissDirection.endToStart) { // Delete
          final confirm = await _showDeleteDialog(context);
          if (confirm) await controller.deleteTransaction(item);
          return confirm;
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showDetailsDialog(context, item, color),
        child: GlassCard(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                width: 44.r, height: 44.r,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(color: color, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.category.isEmpty ? "Uncategorized".tr : item.category.tr,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.black87)),
                    SizedBox(height: 2.h),
                    Text(item.wallet.tr, style: TextStyle(color: Colors.black54, fontSize: 12.sp)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("৳${numberTranslation.toBnDigits(item.amount.toStringAsFixed(0))}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: color)),
                  SizedBox(height: 4.h),
                  Text(
                    "${numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date))}, ${numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date))}",
                    style: TextStyle(color: Colors.black45, fontSize: 10.sp, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBackground(dynamic icon, String text, Color color, Alignment alignment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      alignment: alignment,
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
          ? [HugeIcon(icon: icon, color: color, size: 22.sp), SizedBox(width: 8.w), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold))]
          : [Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)), SizedBox(width: 8.w), HugeIcon(icon: icon, color: color, size: 22.sp)],
      ),
    );
  }
}

// --- Dialog & Bottom Sheet Functions ---

Future<bool> _showDeleteDialog(BuildContext context) async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('Delete Transaction'.tr),
        content: Text('Are you sure you want to delete this?'.tr),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel'.tr)),
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, true), isDestructiveAction: true, child: Text('Delete'.tr)),
        ],
      ),
    ) ?? false;
  }
  return await Get.dialog<bool>(
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
  ) ?? false;
}

void _showDetailsDialog(BuildContext context, TranItem item, Color typeColor) {
  final dateText = numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
  Get.dialog(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white.withAlpha(217),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r), side: BorderSide(color: typeColor.withAlpha(38))),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item.type.tr} Transaction".tr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: typeColor)),
                  if (item.marked) Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                ],
              ),
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text("৳ ${numberTranslation.toBnDigits("${item.amount}")}", style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              ),
              const Divider(),
              _DetailRow(icon: Icons.category_outlined, label: "Category:".tr, value: item.category.isEmpty ? "Uncategorized".tr : item.category.tr),
              _DetailRow(icon: Icons.account_balance_wallet_outlined, label: "Wallet:".tr, value: item.wallet.tr),
              _DetailRow(icon: Icons.calendar_today_outlined, label: "Date:".tr, value: dateText),
              _DetailRow(icon: Icons.notes_outlined, label: "Remark:".tr, value: item.note.isEmpty ? "No Remark".tr : item.note),
              SizedBox(height: 20.h),
              SizedBox(width: double.infinity, child: TextButton(onPressed: Get.back, child: Text("Close".tr, style: const TextStyle(color: Colors.black54)))),
            ],
          ),
        ),
      ),
    ),
  );
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
                margin: EdgeInsets.only(top: 12.h, bottom: 20.h), width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text("Filter by Month".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
                    SizedBox(height: 4.h),
                    Text("Select a month to filter your transactions".tr, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(height: 1),
              SizedBox(height: 8.h),
              Flexible(child: Obx(() => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MonthTile(label: "All Months".tr, isSelected: controller.selectedMonthKey.value == null, onTap: () => controller.selectMonth(null)),
                    ...controller.availableMonthKeys.map((key) => _MonthTile(
                      label: numberTranslation.formatMonthYearBnFromKey(key),
                      isSelected: controller.selectedMonthKey.value == key,
                      onTap: () => controller.selectMonth(key),
                    )),
                  ],
                ),
              ))),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _MonthTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _MonthTile({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: InkWell(
        onTap: () {
          onTap();
          Get.back(); // Close the bottom sheet
        },
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppColors.primary : Colors.black87)),
              ),
              if (isSelected) HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge03, size: 20.sp, color: AppColors.primary)
              else Icon(Icons.chevron_right_rounded, size: 18.sp, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
