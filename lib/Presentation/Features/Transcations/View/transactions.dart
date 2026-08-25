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

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

// --- Main Page Widget ---
class transcations_page extends StatelessWidget {
  transcations_page({super.key});

  final controller = Get.put(transactionsController());

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(tablet),
      body: Obx(() => Stack(
        children: [
          Column(
            children: [
              if (controller.isSearchVisible.value) _SearchBar(isTablet: tablet),
              Expanded(child: _TransactionList(isTablet: tablet)),
            ],
          ),
          if (controller.showScrollToTop.value) _ScrollToTopButton(isTablet: tablet),
        ],
      )),
    );
  }

  AppBar _buildAppBar(bool tablet) {
    return AppBar(
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
            fontSize: tablet ? 16.0 : 20.sp,
          ),
        );
      }),
      actions: [
        Obx(() => IconButton(
          icon: controller.isSearchVisible.value
              ? const Icon(Icons.close, color: Colors.black)
              : HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch02,
                  color: Colors.black,
                  size: tablet ? 20.0 : 24.sp,
                ),
          onPressed: () => controller.toggleSearch(),
        )),
        IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedSortByDown01,
            color: Colors.black,
            size: tablet ? 20.0 : 24.sp,
          ),
          onPressed: () => _showMonthFilterSheet(Get.context!),
        ),
      ],
    );
  }
}

// --- Body Components ---
class _TransactionList extends StatelessWidget {
  final bool isTablet;
  final transactionsController controller = Get.find();

  _TransactionList({this.isTablet = false});

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
    final tablet = isTablet || _isTablet(context);
    return Obx(() {
      final items = controller.filteredItems;

      if (items.isEmpty) {
        final message = controller.searchQuery.isNotEmpty ||
                controller.selectedCategoryFilter.value != null
            ? "No results found".tr
            : "No transactions yet".tr;
        return Center(child: Text(message));
      }

      final grouped = _groupByDate(items);
      final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      final hPad = tablet ? 20.0 : 16.w;
      final vPad = tablet ? 8.0 : 8.h;
      final bottomPad = tablet ? 90.0 : 100.h;

      return Column(
        children: [
          _CategorySummary(items: items, isTablet: tablet),
          Expanded(
            child: ListView.separated(
              controller: controller.scrollController,
              padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
              itemCount: sortedDays.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: tablet ? 16.0 : 20.h),
              itemBuilder: (context, index) {
                final day = sortedDays[index];
                final dayItems = grouped[day]!;
                return _DaySection(
                  day: day,
                  items: dayItems,
                  isTablet: tablet,
                );
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
  final bool isTablet;
  final transactionsController controller = Get.find();

  _CategorySummary({required this.items, this.isTablet = false});

  Map<String, double> _calculateCategoryTotals() {
    final totals = <String, double>{};
    for (final t in items) {
      String key = (t.type == "Lent" || t.type == "Borrow")
          ? t.type
          : (t.category.isEmpty ? "Uncategorized" : t.category);
      totals[key] = (totals[key] ?? 0) + t.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    if (items.isEmpty) return const SizedBox.shrink();
    final totals = _calculateCategoryTotals();

    return Container(
      height: tablet ? 48.0 : 48.h,
      margin: EdgeInsets.symmetric(vertical: tablet ? 6.0 : 12.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: tablet ? 20.0 : 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: totals.length,
        separatorBuilder: (_, __) =>
            SizedBox(width: tablet ? 8.0 : 10.w),
        itemBuilder: (context, index) {
          final entry = totals.entries.elementAt(index);
          return Obx(() => GlassChip(
                isSelected: controller.selectedCategoryFilter.value == entry.key,
                label:
                    "${entry.key.tr}: ৳${numberTranslation.toBnDigits(entry.value.toStringAsFixed(0))}",
                onTap: () => controller.toggleCategoryFilter(entry.key),
                isTablet: tablet,
              ));
        },
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DateTime day;
  final List<TranItem> items;
  final bool isTablet;

  const _DaySection({
    required this.day,
    required this.items,
    this.isTablet = false,
  });

  String _titleForDay(DateTime day) {
    final now = DateTime.now();
    if (day.year == now.year &&
        day.month == now.month &&
        day.day == now.day) return "Today".tr;
    final yesterday = now.subtract(const Duration(days: 1));
    if (day.year == yesterday.year &&
        day.month == yesterday.month &&
        day.day == yesterday.day) return "Yesterday".tr;
    return numberTranslation
        .formatDateBnFromString(DateFormat('dd MMM yyyy').format(day));
  }

  double _sectionTotal(List<TranItem> list) {
    return list.fold(0.0, (sum, t) {
      if (t.type == "Lent" || t.type == "Borrow") return sum;
      return sum + (t.type == "Expense" ? -t.amount : t.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final total = _sectionTotal(items);
    final isPositive = total >= 0;

    final double headerFont = tablet ? 13.0 : 14.sp;
    final double headerBottom = tablet ? 10.0 : 12.h;
    final double tileGap = tablet ? 8.0 : 10.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header row
        Padding(
          padding: EdgeInsets.only(bottom: headerBottom, left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _titleForDay(day),
                style: TextStyle(
                  fontSize: headerFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                "${isPositive ? '+' : ''}${numberTranslation.toBnDigits(total.toStringAsFixed(0))}",
                style: TextStyle(
                  fontSize: headerFont,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Tablet: 2-column grid, Phone: single-column list
        if (tablet)
          _tabletGrid(items, tileGap)
        else
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: tileGap),
                child: _TransactionTile(item: item),
              )),
      ],
    );
  }

  Widget _tabletGrid(List<TranItem> items, double gap) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = (i + 1) < items.length ? items[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(
              child: _TransactionTile(item: left, isTablet: true),
            ),
            SizedBox(width: 10),
            Expanded(
              child: right != null
                  ? _TransactionTile(item: right, isTablet: true)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

// --- Reusable Widgets ---

class _SearchBar extends StatelessWidget {
  final bool isTablet;
  final transactionsController controller = Get.find();

  _SearchBar({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tablet ? 20.0 : 16.w,
        vertical: tablet ? 6.0 : 8.h,
      ),
      child: GlassTextField(
        key: Key(controller.searchQuery.value),
        controller: TextEditingController(text: controller.searchQuery.value)
          ..selection = TextSelection.fromPosition(
              TextPosition(offset: controller.searchQuery.value.length)),
        label: "",
        hint: "Search Category, remark, wallet or amount...".tr,
        icon: Icons.search_rounded,
        onChanged: (val) => controller.searchQuery.value = val,
        isTablet: tablet,
      ),
    );
  }
}

class _ScrollToTopButton extends StatelessWidget {
  final bool isTablet;
  final transactionsController controller = Get.find();

  _ScrollToTopButton({this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return Positioned(
      bottom: tablet ? 16.0 : 20.h,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: controller.scrollToTop,
          child: GlassCard(
            padding: EdgeInsets.symmetric(
              horizontal: tablet ? 14.0 : 16.w,
              vertical: tablet ? 6.0 : 8.h,
            ),
            borderRadius: BorderRadius.circular(tablet ? 30.0 : 30.r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward_rounded,
                    size: tablet ? 14.0 : 16.sp, color: AppColors.primary),
                SizedBox(width: tablet ? 6.0 : 8.w),
                Text(
                  "Scroll to top".tr,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: tablet ? 11.0 : 12.sp,
                    fontWeight: FontWeight.bold,
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

// --- Transaction Tile ---

class _TransactionTile extends StatelessWidget {
  final TranItem item;
  final bool isTablet;
  final transactionsController controller = Get.find();

  _TransactionTile({required this.item, this.isTablet = false});

  Color _typeColor(String type) {
    switch (type) {
      case "Expense":
        return Colors.red;
      case "Income":
        return Colors.green;
      case "Saving":
        return Colors.blue;
      case "Lent":
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    final color = _typeColor(item.type);

    // Tablet: compact fixed sizes (not ScreenUtil scaled)
    final double avatarSize = tablet ? 32.0 : 44.r;
    final double avatarFont = tablet ? 13.0 : 18.sp;
    final double hGap       = tablet ? 8.0  : 14.w;
    final double catFont    = tablet ? 13.0 : 15.sp;
    final double walletFont = tablet ? 11.0 : 12.sp;
    final double amtFont    = tablet ? 13.0 : 15.sp;
    final double dateFont   = tablet ? 9.0  : 10.sp;
    final double cardPad    = tablet ? 8.0  : 12.r;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _buildActionBackground(
          HugeIcons.strokeRoundedEdit02, "Edit".tr, Colors.blue,
          Alignment.centerLeft, tablet),
      secondaryBackground: _buildActionBackground(
          HugeIcons.strokeRoundedDelete04, "Delete".tr, Colors.red,
          Alignment.centerRight, tablet),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          Get.find<editTransactionsController>().assignValues(item);
          Get.to(() => editTransactions(model: item));
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          final confirm = await _showDeleteDialog(context);
          if (confirm) await controller.deleteTransaction(item);
          return confirm;
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () => _showDetailsDialog(context, item, color),
        child: GlassCard(
          padding: EdgeInsets.all(cardPad),
          child: Row(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    item.type.isNotEmpty ? item.type[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: color,
                        fontSize: avatarFont,
                        fontWeight: FontWeight.bold),
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
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2),
                    Text(
                      item.wallet.tr,
                      style: TextStyle(color: Colors.black54, fontSize: walletFont),
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
                        color: color),
                  ),
                  SizedBox(height: 2),
                  Text(
                    tablet
                        ? DateFormat('dd MMM, hh:mm a').format(item.date)
                        : "${numberTranslation.formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date))}, ${numberTranslation.toBnDigits(DateFormat('hh:mm a').format(item.date))}",
                    style: TextStyle(
                        color: Colors.black45,
                        fontSize: dateFont,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              SizedBox(width: tablet ? 8.0 : 12.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBackground(
      dynamic icon, String text, Color color, Alignment alignment, bool tablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tablet ? 16.0 : 20.w),
      alignment: alignment,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(tablet ? 14.0 : 14.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                HugeIcon(icon: icon, color: color, size: tablet ? 18.0 : 22.sp),
                SizedBox(width: tablet ? 6.0 : 8.w),
                Text(text,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: tablet ? 12.0 : null))
              ]
            : [
                Text(text,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: tablet ? 12.0 : null)),
                SizedBox(width: tablet ? 6.0 : 8.w),
                HugeIcon(icon: icon, color: color, size: tablet ? 18.0 : 22.sp)
              ],
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
              CupertinoDialogAction(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel'.tr)),
              CupertinoDialogAction(
                  onPressed: () => Navigator.pop(ctx, true),
                  isDestructiveAction: true,
                  child: Text('Delete'.tr)),
            ],
          ),
        ) ??
        false;
  }
  return await Get.dialog<bool>(
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            title: Text("Delete Transaction".tr),
            content: Text("Are you sure you want to delete this transaction?".tr),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text("Cancel".tr,
                      style: const TextStyle(color: Colors.black54))),
              TextButton(
                  onPressed: () => Get.back(result: true),
                  child: Text("Delete".tr,
                      style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ) ??
      false;
}

void _showDetailsDialog(BuildContext context, TranItem item, Color typeColor) {
  final dateText = numberTranslation
      .formatDateBnFromString(DateFormat('dd MMM yyyy').format(item.date));
  final tablet = _isTablet(context);
  Get.dialog(
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.white.withAlpha(217),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tablet ? 20.0 : 24.r),
            side: BorderSide(color: typeColor.withAlpha(38))),
        child: Padding(
          padding: EdgeInsets.all(tablet ? 20.0 : 20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${item.type.tr} Transaction".tr,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: tablet ? 16.0 : 20.sp,
                          color: typeColor)),
                  if (item.marked)
                    Icon(Icons.check_circle,
                        color: Colors.green,
                        size: tablet ? 20.0 : 24.sp),
                ],
              ),
              SizedBox(height: tablet ? 12.0 : 15.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    "৳ ${numberTranslation.toBnDigits("${item.amount}")}",
                    style: TextStyle(
                        fontSize: tablet ? 22.0 : 28.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ),
              const Divider(),
              _DetailRow(
                  icon: Icons.category_outlined,
                  label: "Category:".tr,
                  value: item.category.isEmpty
                      ? "Uncategorized".tr
                      : item.category.tr,
                  isTablet: tablet),
              _DetailRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: "Wallet:".tr,
                  value: item.wallet.tr,
                  isTablet: tablet),
              _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: "Date:".tr,
                  value: dateText,
                  isTablet: tablet),
              _DetailRow(
                  icon: Icons.notes_outlined,
                  label: "Remark:".tr,
                  value: item.note.isEmpty ? "No Remark".tr : item.note,
                  isTablet: tablet),
              SizedBox(height: tablet ? 16.0 : 20.h),
              SizedBox(
                  width: double.infinity,
                  child: TextButton(
                      onPressed: Get.back,
                      child: Text("Close".tr,
                          style: const TextStyle(color: Colors.black54)))),
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
  final bool isTablet;
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tablet ? 5.0 : 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: tablet ? 14.0 : 16.sp, color: Colors.black54),
          SizedBox(width: tablet ? 6.0 : 8.w),
          Text(label,
              style: TextStyle(
                  fontSize: tablet ? 12.0 : 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(width: tablet ? 4.0 : 6.w),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: tablet ? 12.0 : 14.sp,
                      color: Colors.black87))),
        ],
      ),
    );
  }
}

void _showMonthFilterSheet(BuildContext context) {
  final controller = Get.find<transactionsController>();
  final tablet = _isTablet(context);
  Get.bottomSheet(
    ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(tablet ? 20.0 : 24.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(bottom: tablet ? 24.0 : 30.h),
          decoration:
              BoxDecoration(color: Colors.white.withOpacity(0.85)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: tablet ? 10.0 : 12.h,
                    bottom: tablet ? 16.0 : 20.h),
                width: tablet ? 36.0 : 40.w,
                height: tablet ? 3.0 : 4.h,
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: tablet ? 24.0 : 24.w),
                child: Column(
                  children: [
                    Text("Filter by Month".tr,
                        style: TextStyle(
                            fontSize: tablet ? 16.0 : 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5)),
                    SizedBox(height: tablet ? 2.0 : 4.h),
                    Text(
                        "Select a month to filter your transactions".tr,
                        style: TextStyle(
                            fontSize: tablet ? 12.0 : 13.sp,
                            color: Colors.black54)),
                  ],
                ),
              ),
              SizedBox(height: tablet ? 12.0 : 16.h),
              const Divider(height: 1),
              SizedBox(height: tablet ? 6.0 : 8.h),
              Flexible(
                  child: Obx(() => SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MonthTile(
                                label: "All Months".tr,
                                isSelected:
                                    controller.selectedMonthKey.value == null,
                                onTap: () => controller.selectMonth(null),
                                isTablet: tablet),
                            ...controller.availableMonthKeys.map((key) =>
                                _MonthTile(
                                    label: numberTranslation
                                        .formatMonthYearBnFromKey(key),
                                    isSelected:
                                        controller.selectedMonthKey.value ==
                                            key,
                                    onTap: () => controller.selectMonth(key),
                                    isTablet: tablet)),
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
  final bool isTablet;
  const _MonthTile(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final tablet = isTablet || _isTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: tablet ? 16.0 : 16.w,
          vertical: tablet ? 3.0 : 4.h),
      child: InkWell(
        onTap: () {
          onTap();
          Get.back();
        },
        borderRadius: BorderRadius.circular(tablet ? 12.0 : 14.r),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: tablet ? 14.0 : 16.w,
              vertical: tablet ? 10.0 : 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tablet ? 12.0 : 14.r),
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: tablet ? 13.0 : 15.sp,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.black87)),
              ),
              if (isSelected)
                HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkBadge03,
                    size: tablet ? 18.0 : 20.sp,
                    color: AppColors.primary)
              else
                Icon(Icons.chevron_right_rounded,
                    size: tablet ? 16.0 : 18.sp, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}
